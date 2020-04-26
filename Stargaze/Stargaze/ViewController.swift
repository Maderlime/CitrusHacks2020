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
import Foundation

class ViewController: UIViewController{

    /**
     My variables
     */
     @IBOutlet var MapView: MKMapView!
     @IBOutlet var SlideButton: UIButton!
    
     let locationManager = CLLocationManager()
     let regionInMeters: Double = 10000 // region of viewing
    
    // Menu
//    let collectionView:UICollectionView = {
//        let layout = UICollectionViewLayout()
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = UIColor.white
//
//        return cv
//    }()
//    let cellId = "cellId"

    
    
    
    
    
    
    
    
    
    
    
    /**
     
     Main Method
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        /**
         General Necessities
         */
        MapView.delegate = self
//        Radar.setDelegate(self)
        checkLocationServices()
        
        /**
         Grab Locations from txt file
         */
        let filename = Bundle.main.path(forResource: "places_togo", ofType: "txt")
        var readString = ""
        do{
            readString = try String(contentsOfFile: filename!)
        }
        catch let error as NSError{
            print("Failed to read from project")
        }
//        self.collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
        let lines = readString.split(separator:"\n")
        print(lines)
        for p in lines{
            let information = p.split(separator:",")
            let addy: String = String(information[2])
            Radar.geocode(address:addy){(status, addresses) in
//                print("Geocode: status = \(Radar.stringForStatus(status)); coordinate = \(String(describing: addresses?.first?.coordinate))")
                let latt :Double = (Double((addresses?.first?.coordinate.latitude)!))
                let lonng :Double = (Double((addresses?.first?.coordinate.longitude)!))
                self.goToLocation(latt, lonng, String(information[0]), String(information[1]))
                self.give_route(latt, lonng, 0)
            }
        }
        
        /* Radar.io code*/
        Radar.trackOnce { (status: RadarStatus, location: CLLocation?, events: [RadarEvent]?, user: RadarUser?) in
          // do something with location, events, user
            print("hi \n")
        }
        
//        give_route(37.7620, -122.3034, 0)

        
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
        
        
        let sourceCoordinates = locationManager.location?.coordinate
        let destCoordinates = CLLocationCoordinate2DMake(lat, long)
        
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        
        directionRequest.transportType = .walking
        
       
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else{
                if let error = error{
                    print("Something Went Wrong")
                }
                return
            }
            
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
//    let blackView = UIView()
    

    let settingsLauncher = SettingsLauncher()
    func handle_slidups(){
        settingsLauncher.showSettings()
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
//          MapView.setRegion(region, animated: true)
        
        // annotations
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = category
        annotation.subtitle = specific
        MapView.addAnnotation(annotation)
    }
    
    /**Given location go put an annotation on it*/
    func placeAddy(_ location: CLLocationCoordinate2D, _ category: String, _ specific: String){
        let location =  location
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
//          MapView.setRegion(region, animated: true)
        
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

        if annotation === mapView.userLocation{
             annotationView?.image = UIImage(named: "Location")
        }
        else{
            annotationView?.image = UIImage(named: "star")
        }
        annotationView?.canShowCallout = true
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation selected")
        handle_slidups()
        mapView.deselectAnnotation(view.annotation, animated: true)
        
    }
    
    
    
    
    
    
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        guard let location = locations.last else{return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        MapView.setRegion(region, animated: true)
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){

        checkLocationAuthorization()

    }

}


//extension ViewController: UICollectionViewDataSource {
//
//
////}
//
//extension ViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.row + 1)
//    }
//}
//
//extension ViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: collectionView.bounds.size.width - 16, height: 120)
//    }
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 8
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
//    }
//}
//
