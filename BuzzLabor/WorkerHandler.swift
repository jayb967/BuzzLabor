//
//  WorkerHandler.swift
//  BuzzLabor
//
//  Created by Jay Balderas on 6/3/17.
//  Copyright © 2017 Jay Balderas. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol LaborController: class {
    func canCallLabor(delegateCalled: Bool);
    func laborerAcceptedRequest(requestAccepted: Bool, driverName: String);
    func updateLaborerLocation(lat: Double, long: Double);
}

class LaborHandler {
    private static let _instance = LaborHandler();
    
    weak var delegate: LaborController?;
    
    var rider = "";
    var driver = "";
    var rider_id = "";
    
    static var Instance: LaborHandler {
        return _instance;
    }
    
    func observeMessagesForUser() {
        // User requested Labor
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key;
                        self.delegate?.canCallLabor(delegateCalled: true);
                    }
                }
            }
            
        }
        
        // RIDER CANCELED UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.delegate?.canCallLabor(delegateCalled: false);
                    }
                }
            }
            
        }
        
        // DRIVER ACCEPTED UBER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.driver == "" {
                        self.driver = name;
                        self.delegate?.laborerAcceptedRequest(requestAccepted: true, driverName: self.driver);
                    }
                }
            }
            
        }
        
        // DRIVER CANCELED UBER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver = "";
                        self.delegate?.laborerAcceptedRequest(requestAccepted: false, driverName: name);
                    }
                }
            }
            
        }
        
        // DRIVER UPDATING LOCATION
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateLaborerLocation(lat: lat, long: long);
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    func requestLabor(latitude: Double, longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude];
        DBProvider.Instance.requestRef.childByAutoId().setValue(data);
    } // request uber
    
    func cancelUber() {
        DBProvider.Instance.requestRef.child(rider_id).removeValue();
    }
    
    func updateRiderLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
    
} // class
