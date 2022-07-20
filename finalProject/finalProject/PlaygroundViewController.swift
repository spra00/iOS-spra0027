//
//  PlaygroundViewController.swift
//  finalProject
//  THis class is used to create the VC for the playground and the map
//  Created by Shakthi  Prashanth champaka on 4/5/2022.
//

import UIKit
import MapKit

class PlaygroundViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSpinner: UIActivityIndicatorView!
    
    //the playgrounds obtained from the API
    var playgroundObtained = [PlaygroundData]()
    
    //the currently selected pin
    var currentPin: CustomPin?
    
    weak var databaseController: DatabaseProtocol?
    
    var allGames = [[String : Any]]()
    let game = GameData()
    var myPinCode: String?
    
    //reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favGround: [FavrouiteGround]?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playgroundObtained = [PlaygroundData]()
            
        // Load the firebaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        //adding the acitivity spinner to the current.
        view.addSubview(mapSpinner)
        
        mapSpinner.startAnimating()
            
        
        //carry out the API querying in a non main thread
        Task {
            
         URLSession.shared.invalidateAndCancel()
         await requestPlaygrounds()
        }
        
        Task{
            await game.getGamesList()
        }
        
        let seconds = 3.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            //Do nothing and wait for the map to load properly.
            
            //pan the location
            self.fetchFavrouiteGround()

            
            if self.myPinCode != "0000" {
                
                let myPinCode = self.myPinCode
                
                if let latitude = self.playgroundObtained[0].latitude, let longitude = self.playgroundObtained[0].longitude{
                    
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    self.mapView.delegate = self
                    
                    
                    self.mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)), animated: true)
                    
                }
                
                var status_check = false
                
                for playground in self.playgroundObtained{
                    if myPinCode == playground.postcode{
                        
                        let myAnnotation = CustomPin()
                        status_check = true
                        
                        //first we need to unwrap the optional values
                        if let postcode = playground.postcode, let playground_name = playground.playground_name, let recordid = playground.recordid, let suburb_name = playground.suburb_name, let latitude = playground.latitude, let longitude = playground.longitude{
                        
                            //add the annotation details
                            myAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                            myAnnotation.title = playground_name
                            myAnnotation.subtitle = suburb_name + " - " + postcode
                            myAnnotation.pinTintColor = .red
                            
                            if self.favGround!.count > 0{
                                if self.favGround![0].recordid == playground.recordid{
                                    myAnnotation.pinTintColor = .green
                                }
                            }
                            
                            else{
                                myAnnotation.pinTintColor = .red
                            }
                            
                            //add the data of the playground that is needed later
                            myAnnotation.postcode = postcode
                            myAnnotation.playground_name = playground_name
                            myAnnotation.recordid = recordid
                            myAnnotation.suburb_name = suburb_name
                            myAnnotation.latitude = latitude
                            myAnnotation.longitude = longitude

                            
                        }
                        //add the annotations to the map
                        
                        self.mapView.addAnnotation(myAnnotation)
                        
                    }
                    

                }
                //stop the spinning
                self.mapSpinner.stopAnimating()
                
                if status_check == false{
                    self.displayMessage(title: "Invalid Pin", message: "The Pin Code must be from the City of Casey Council")
                }
                
                return
                
            }
            

            let location = CLLocationCoordinate2D(latitude: -38.02,longitude: 145.349)
            
            self.mapView.delegate = self
            
            //set the zoom level and initial co-ordinates
            self.mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)), animated: true)
            
            
                        
            //then add the playgrounds as annotations
            for playground in self.playgroundObtained{
                
                let myAnnotation = CustomPin()
                
                //first we need to unwrap the optional values
                if let postcode = playground.postcode, let playground_name = playground.playground_name, let recordid = playground.recordid, let suburb_name = playground.suburb_name, let latitude = playground.latitude, let longitude = playground.longitude{
                    
                    myAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                    myAnnotation.title = playground_name
                    myAnnotation.subtitle = suburb_name + " - " + postcode
                    myAnnotation.pinTintColor = .red
                    
                    
                    if self.favGround!.count > 0{
                        if self.favGround![0].recordid == playground.recordid{
                            myAnnotation.pinTintColor = .green
                        }
                    }
                    
                    else{
                        myAnnotation.pinTintColor = .red
                    }
                    
                    //add the data of the playground that is needed later
                    myAnnotation.postcode = postcode
                    myAnnotation.playground_name = playground_name
                    myAnnotation.recordid = recordid
                    myAnnotation.suburb_name = suburb_name
                    myAnnotation.latitude = latitude
                    myAnnotation.longitude = longitude
                    
                }
                //add the annotations to the map
                self.mapView.addAnnotation(myAnnotation)
            }
            self.mapSpinner.stopAnimating()
            
        }
    }
    
    //this function is used to print any alerts to the user.
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    
    //method used to obtain the API data in async.
    public func requestPlaygrounds() async{
        
        //method used to obtain the playground details
        // CREDITS: ALL THE DATA HAS BEEN OBTAINED FROM CITY OF CASEY OPEN DATA's API
        //https://www.casey.vic.gov.au/
        
        let requestURL = URL(string: "https://data.casey.vic.gov.au/api/records/1.0/search/?dataset=playgrounds&q=&rows=50")!
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, _) =
         try await URLSession.shared.data(for: urlRequest)
            
            do{
                //Decode using the RecoredData which is created
                let decoder = JSONDecoder()
                let recordData = try decoder.decode(RecordData.self, from: data)
                
                if let playground = recordData.playgrounds{
                    
                    //store the obtained data in this list.
                    self.playgroundObtained = playground
                }

            }
            //if any errors are caught
            catch let error {
             print(error)
            }
        
        }
        catch let error {
         print(error)
        }


    }
    
    //this method is used to create a view for the annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else {
            return nil
            
        }
        
        //get the current pin
        let myCurrentPin = annotation as? CustomPin

         let identifier = "Annotation"
        
         var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

         if annotationView == nil {
             annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
             annotationView?.tintColor = myCurrentPin?.pinTintColor
             annotationView!.canShowCallout = true
             let callButton = UIButton(type: .contactAdd)
             annotationView?.rightCalloutAccessoryView = callButton
             annotationView?.sizeToFit()
         }
        
         else {
             annotationView!.annotation = annotation
         }
        
        if myCurrentPin?.pinTintColor == .green{
            annotationView?.image = UIImage(named: "favGround")
            annotationView?.frame.size = CGSize(width: 25, height: 35)
        }
        
         return annotationView

    }
    
    func fetchFavrouiteGround(){
         //Fetch the data from the core data
        do{
            self.favGround = try context.fetch(FavrouiteGround.fetchRequest())
            
        }
        catch{
            print(error)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if view.annotation is CustomPin{
            self.allGames = game.gameDict
            
            //assign the value
            self.currentPin = view.annotation as? CustomPin
            
            for game in allGames{
                
                guard let recordid = game["recordid"] else{
                    return
                }
                
                if recordid as? String == self.currentPin?.recordid{
                    self.performSegue(withIdentifier: "containsGamesSegue", sender: self)
                    return
                }
            }
            self.performSegue(withIdentifier: "noGameSegue", sender: self)
            return 
            
        }
        
        
    }
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //check if it is the required segue for us.
        if segue.identifier == "noGameSegue"{
            
            let destination = segue.destination as! NoGameViewController
            
            //send the selected playground information to the next view controller
            destination.suburb_name = self.currentPin?.suburb_name
            destination.recordid = self.currentPin?.recordid
            destination.playground_name = self.currentPin?.playground_name
            destination.postcode = self.currentPin?.postcode
            destination.latitude = self.currentPin?.latitude
            destination.longitude = self.currentPin?.longitude
        }
        
        if segue.identifier == "containsGamesSegue"{
            
            let destination = segue.destination as! GamesTableViewController

            //send the selected playground information to the next view controller
            destination.suburb_name = self.currentPin?.suburb_name
            destination.recordid = self.currentPin?.recordid
            destination.playground_name = self.currentPin?.playground_name
            destination.postcode = self.currentPin?.postcode
            destination.latitude = self.currentPin?.latitude
            destination.longitude = self.currentPin?.longitude
        }

    }
    

}
