//
//  DBProvider.swift
//  BuzzLabor
//
//  Created by Jay Balderas on 6/3/17.
//  Copyright © 2017 Jay Balderas. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider();
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference();
    }
    
    var ridersRef: DatabaseReference {
        return dbRef.child(Constants.USERS);
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.LABOR_REQUESTED);
    }
    
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.LABOR_ACCEPTED);
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isUser: true];
        ridersRef.child(withID).child(Constants.DATA).setValue(data);
    }
    
} // class
