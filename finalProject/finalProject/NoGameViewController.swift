//
//  NoGameViewController.swift
//  finalProject
//  This VC is showed when the selected playground doesn't have any games
//  Created by Shakthi  Prashanth champaka on 9/5/2022.
//

import UIKit
import MapKit

class NoGameViewController: UIViewController, MKMapViewDelegate {
    
    //attributes required
    var recordid: String?
    var postcode: String?
    var playground_name: String?
    var suburb_name: String?
    var latitude: Double?
    var longitude: Double?
    
    //variables associated to the view
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSpinner: UIActivityIndicatorView!
    @IBOutlet weak var segmentValue: UISegmentedControl!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adding the acitivity spinner to the current.
        view.addSubview(mapSpinner)
        
        //spin when loading the maps
        mapSpinner.startAnimating()
        

        //Wait untial user has logged in
        let seconds = 2.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            //Do nothing and wait for the map to load properly.
            if let latitude = self.latitude, let longitude = self.longitude{
                
                let location = CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
                self.mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
                
                //set the delegate
                self.mapView.delegate = self
                
                if let playground_name = self.playground_name, let suburb_name = self.suburb_name, let postcode = self.postcode {
                    let myAnnotation = CustomPin()
                    myAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                    myAnnotation.title = playground_name
                    myAnnotation.subtitle = suburb_name + " - " + postcode
                       
                    //add the annotation to the map
                    self.mapView.addAnnotation(myAnnotation)
                }
                
            }
            
            //once everything is loaded stop the spinner
            self.mapSpinner.stopAnimating()

        }
            
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //method used to create a view for the anootation on the map
        guard annotation is MKPointAnnotation else {
            return nil
            
        }

         let identifier = "Annotation"
         var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
         if annotationView == nil {
             annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
             annotationView!.canShowCallout = true
             annotationView?.sizeToFit()
         }
        
         else {
             annotationView!.annotation = annotation
         }

         return annotationView
        

    }
    
    @IBAction func onClick(_ sender: Any) {
        //selecting based on the user click
        if segmentValue.selectedSegmentIndex == 0{
            
            self.performSegue(withIdentifier: "createGameSegue", sender: self)
            
        }
        else{
            navigationController?.popViewController(animated: true)
        }
        
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createGameSegue"{
            
            let destination = segue.destination as! CreateGameViewController
            
            destination.suburb_name = self.suburb_name!
            destination.recordid = self.recordid!
            destination.playground_name = self.playground_name!
            destination.postcode = self.postcode!
        }

    }

}
