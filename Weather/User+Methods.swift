//
//  User+Methods.swift
//  Weather
//
//  Created by Vasyl Savka on 5/12/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct cUser {
    
    static let User = "User"
    static let InternalLengthMetric = "m"
    static let InternalLengthImperial = "i"
    static let InternalTempCelsius = "c"
    static let InternalTempKelvin = "k"
    static let ChosenLocationCurrent = -1
}
extension User {
    
    
    static func getUser() -> User? {
        
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: cUser.User)
        
        var error: NSError?
        let results =  c.executeFetchRequest(fetchRequest, error: &error) as? [User]
        if error != nil {
            println("Could not save \(error), \(error?.userInfo)")
        }
        return results?.first
        
        
        
    }
    
    
    
    
    func debug() {
        
        println("Len: \(self.uLength)")
        println("Temp: \(self.uTemperature)")
        println("ChosenLocID: \(self.uChosenLocationID)")
        println("ChosenLon: \(self.uCurrentLongitude)")
        println("CurLat: \(self.uCurrentLatitude)")
        var curLoc = uChosenLocationName ?? "empty"
        println("Chosen Location: \(curLoc)")
    }
    
    
    
    
}




