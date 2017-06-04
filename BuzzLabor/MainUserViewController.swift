//
//  MainUserViewController.swift
//  BuzzLabor
//
//  Created by Jay Balderas on 6/3/17.
//  Copyright © 2017 Jay Balderas. All rights reserved.
//

import UIKit
import MapKit

class MainUserViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, LaborController {
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var descriptionTextField: UITextField?
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var laborerLocation: CLLocationCoordinate2D?;
    
    private var timer = Timer();
    
    private var canCallLabor = true;
    private var LaborerCancelledRequest = false;
    
    private var appStartedForTheFirstTime = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.disableKeybordWhenTapped = true
        initializeLocationManager();
        LaborHandler.Instance.observeMessagesForUser();
        LaborHandler.Instance.delegate = self;
        self.myMap.showsUserLocation = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
//        self.myMap.showsBuildings = true
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "LaborConfirmed") {
//            var svc = segue.destination as! LaborEnRouteViewController;
//            svc.descriptionTextField = descriptionTextField.text
//        }
//
//    }
  
    
    private func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    @IBAction func callLaborerButton(_ sender: Any) {
        
        self.dismiss(animated: true) { 
            if self.userLocation != nil {
                if self.canCallLabor {
                    LaborHandler.Instance.requestLabor(latitude: Double(self.userLocation!.latitude), longitude: Double(self.userLocation!.longitude))
                    
                    self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(MainUserViewController.updateUsersLocation), userInfo: nil, repeats: true);
                    
                } else {
                    self.LaborerCancelledRequest = true;
                    LaborHandler.Instance.cancelUber();
                    self.timer.invalidate();
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            
            myMap.setRegion(region, animated: true);
            
            myMap.removeAnnotations(myMap.annotations);
            
            if laborerLocation != nil {
                if !canCallLabor {
                    let laborerAnnotation = MKPointAnnotation();
                    laborerAnnotation.coordinate = laborerLocation!;
                    laborerAnnotation.title = "Laborer Location";
                    myMap.addAnnotation(laborerAnnotation);
                }
            }
            
//            let annotation = MKPointAnnotation();
//            annotation.coordinate = userLocation!;
//            annotation.title = "Laborer Location";
//            myMap.addAnnotation(annotation);
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "Laborer")
            return annotationView
        }
    }
    
    func updateUsersLocation() {
        LaborHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    func canCallLabor(delegateCalled: Bool) {
        canCallLabor = true
    }
    
    func laborerAcceptedRequest(requestAccepted: Bool, driverName: String) {
        
        if !LaborerCancelledRequest {
            if requestAccepted {
                alertTheUser(title: "Labor Accepted", message: "\(driverName) Accepted Your Request")
            } else {
                LaborHandler.Instance.cancelUber();
                timer.invalidate();
                alertTheUser(title: "Labor Canceled", message: "\(driverName) Canceled Your Request")
            }
        }
        LaborerCancelledRequest = false;
    }
    
    func updateLaborerLocation(lat: Double, long: Double) {
        laborerLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
  
    
    @IBAction func logout(_ sender: AnyObject) {
        if AuthProvider.Instance.logOut() {
            
            if !canCallLabor {
                LaborHandler.Instance.cancelUber();
                timer.invalidate();
            }
            
            dismiss(animated: true, completion: nil);
            
        } else {
            // problem with loging out
            alertTheUser(title: "Could Not Logout", message: "We could not logout at the moment, please try again later");
        }
    }
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
} // class
