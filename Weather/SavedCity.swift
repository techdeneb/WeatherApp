//
//  SavedCity.swift
//  Weather
//
//  Created by Vasyl Savka on 5/15/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import Foundation
import CoreData

class SavedCity: NSManagedObject {

    @NSManaged var sCityName: String
    @NSManaged var sID: NSNumber
    @NSManaged var sCountry: String

}
