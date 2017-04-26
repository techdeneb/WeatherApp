//
//  SavedCity+Methods.swift
//  Weather
//
//  Created by Vasyl Savka on 5/15/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct cSavedCity {
    static let SavedCity = "SavedCity"
    static let dbID = "sID"
}

extension SavedCity {
    
    static func getAllCities() ->[SavedCity]? {
        
        
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: cSavedCity.SavedCity)
        
        var error: NSError?
        let results =  c.executeFetchRequest(fetchRequest, error: &error) as? [SavedCity]
        if error != nil {
            println("Could not save \(error), \(error?.userInfo)")
        }
        return results
    }
    
    
    static func getCityByID(idCity:Int) ->SavedCity? {
        
        
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: cSavedCity.SavedCity)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [cSavedCity.dbID, idCity])
        var error: NSError?
        let results =  c.executeFetchRequest(fetchRequest, error: &error) as? [SavedCity]
        
        return results?.first
    }
    
    
    static func insertCity(city:String, country:String, idCity: Int) -> SavedCity? {
        
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        if let cityByID = SavedCity.getCityByID(idCity) {
            
            return nil
        }
        
        let savedCity = NSEntityDescription.insertNewObjectForEntityForName(cSavedCity.SavedCity, inManagedObjectContext: c) as? SavedCity
        
        savedCity?.sCityName = city
        savedCity?.sCountry = country
        savedCity?.sID = idCity
        Helper.saveContext()
        return savedCity
        
    }
    
    static func removeCity(city: SavedCity) {
        
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        c.deleteObject(city)
    }
    
    
}
