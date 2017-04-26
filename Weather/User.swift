//
//  User.swift
//  Weather
//
//  Created by Vasyl Savka on 5/18/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var uChosenLocationName: String?
    @NSManaged var uChosenLocationID: NSNumber
    @NSManaged var uCurrentLatitude: NSNumber
    @NSManaged var uCurrentLongitude: NSNumber
    @NSManaged var uLength: String
    @NSManaged var uTemperature: String
    @NSManaged var uCurrentWeatherDesc: String
    @NSManaged var uCurrentTemperature: NSNumber
    @NSManaged var uCurrentWeatherImageID: NSNumber
    @NSManaged var uCurrentSpeed: NSNumber

}
