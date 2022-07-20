//
//  UpcomingGameDetailViewController.swift
//  finalProject
//  This VC is used for showing the upcoming game's details
//  Created by Shakthi  Prashanth champaka on 23/5/2022.
//

import UIKit
import MapKit


class UpcomingGameDetailViewController: UIViewController, MKMapViewDelegate {
    
    //variables used in the view
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSpinner: UIActivityIndicatorView!
    @IBOutlet weak var gameAddress: UILabel!
    @IBOutlet weak var gamecoord: UILabel!
        
    //attributes associated with the game are required
    var recordid: String?
    var postcode: String?
    var playground_name: String?
    var suburb_name: String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var coordinator: String?

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
        
        //this method is used for creating a view for the annotation that has been created in the map.
        //this method will return the exsiting view or create a new one and return the view.
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
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //once the view has appeared show the required data
        if let text = address {
            self.gameAddress.text = text
        }
        
        if let text = coordinator{
            self.gamecoord.text = text
        }
    }

}
