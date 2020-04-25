//
//  ViewController.swift
//  Stargaze
//
//  Created by Madeline Tjoa on 4/24/20.
//  Copyright © 2020 Madeline Tjoa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RadarSDK

class ViewController: UIViewController, CLLocationManagerDelegate{

    /**
     My variables
     */
     @IBOutlet var MapView: MKMapView!
     @IBOutlet var SlideButton: UIButton!
    
     let locationManager = CLLocationManager()
    
     let regionInMeters: Double = 10000 // region of viewing
    
    // Menu
    let collectionView:UICollectionView = {
        let layout = UICollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    /**
     
     Main Method
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        /**
         General Necessities
         */
        MapView.delegate = self
        checkLocationServices()
        
        /* Radar.io code*/
        Radar.trackOnce { (status: RadarStatus, location: CLLocation?, events: [RadarEvent]?, user: RadarUser?) in
          // do something with location, events, user
            print("hi \n")
        }

        
        
//        goToLocation(51.50007773, -0.1246402, "Big Ben", "little")
        
        give_route(37.7620, -122.3034, 0)

        
    }

    /**
     Directions
     */
    func give_route(_ lat: Double, _ long: Double, _ travelType: Int){
        
        MapView.showsScale = true
        MapView.showsPointsOfInterest = true
        MapView.showsUserLocation = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
        }
        
        print("phase 1")
        let sourceCoordinates = locationManager.location?.coordinate
        let destCoordinates = CLLocationCoordinate2DMake(lat, long)
        
        print("Pase 2")
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        print("phase 3")
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        print("pase 4")
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        
        directionRequest.transportType = .walking
        
        print("phase 5")
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else{
                if let error = error{
                    print("Something Went Wrong")
                }
                return
            }
            print("phase 6")
            let route = response.routes[0]
            self.MapView.addOverlay(route.polyline, level: .aboveRoads)
            let rekt = route.polyline.boundingMapRect
            self.MapView.setRegion(MKCoordinateRegion(rekt), animated : true)
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("inside")
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }

    
    /**
     
     Location Code
     
     */
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center:location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            MapView.setRegion(region, animated: true)
        }
    }
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    // check if user enabled location
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
        else{
            // Tell user to enable location
        }
    }
    // check what the user has given us access too
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            MapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            MapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    
    /**
     Menu code
     */
    let blackView = UIView()
    
    @IBAction func ScrollUP(_ sender: Any) {

        if let window = UIApplication.shared.keyWindow{
            
            blackView.backgroundColor = UIColor(white:0, alpha:0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations:
                {self.blackView.alpha = 1})
            
            
            window.addSubview(collectionView)
            
            let height : CGFloat = 500
            let y = window.frame.height - height
            
            collectionView.frame = CGRect(x: 0,y: window.frame.height,width: window.frame.width, height: 500)
            
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
                self.collectionView.frame = CGRect(x: 0,y: y,width: self.collectionView.frame.width, height: self.collectionView.frame.height)}, completion: nil)
            
        }
        
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5){
            self.blackView.alpha = 0
        }
        UIView.animate(withDuration: 0.5) {
             if let window = UIApplication.shared.keyWindow{
                 self.collectionView.frame = CGRect(x: 0,y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
             }
         }
    }
    
    
    /*
     Go to the Location of a coordinate
     @ param lat: the latitude we want to put the sticky on
     @ param long: the longitude
     @ param category: the general category that the event is
     @ param specific: specifically what the event is
     */
    func goToLocation(_ lat: Double, _ long: Double, _ category: String, _ specific: String){
        let location =  CLLocationCoordinate2D(latitude: lat, longitude: long)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
          MapView.setRegion(region, animated: true)
        
        // annotations
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = category
        annotation.subtitle = specific
        MapView.addAnnotation(annotation)
    }

}
//customize
extension ViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if let title = annotation.title, title ==  "Big Ben"{
            annotationView?.image = UIImage(named: "plant")
        }
        else if let title = annotation.title, title ==  "Ortega Park"{
            annotationView?.image = UIImage(named: "star")
        }
        else if annotation === mapView.userLocation{
             annotationView?.image = UIImage(named: "Location")
        }
        annotationView?.canShowCallout = true
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation selected")
    }
}

//extension ViewController: CLLocationManagerDelegate{
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
//        guard let location = locations.last else{return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        MapView.setRegion(region, animated: true)
//    }
//    func locationManager(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
//
//        checkLocationAuthorization()
//
//    }
//
//}

