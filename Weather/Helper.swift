//
//  Helper.swift
//  Weather
//
//  Created by Vasyl Savka on 5/12/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import UIKit
import CoreData

struct cGeneral {
    
    static let ChangeUnitNotification = "ChangeUnitNotification"
    static let ChangeSelectedCity = "ChangeSelectedCity"
    static let NeedReloadForecastTVC = "NeedReloadForecastTVC"
    static let appBlackColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
}

struct cForecast {
    static let kTemp = "temp"
    static let kDesc = "desc"
    static let kIDWeather = "idImage"
}

class Helper {
    
    static func showAlertWithText(text: String, sender: AnyObject) {
        
        let a = UIAlertController(title: "App says:", message: text ?? "", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (ok) -> Void in})
        a.addAction(ok)
        if let s = sender as? UIViewController {
            sender.presentViewController(a, animated: true, completion: nil)
        }
    }
    
    
    static func getTemperatureToShow(temp: Double) -> String {
        
        let u = User.getUser()
        if let u = u {
            if u.uTemperature == cUser.InternalTempCelsius {
                
                let newVal = temp - 273.15
                return String(format:"%.0f", round(newVal)) + "°C"
            } else if u.uTemperature == cUser.InternalTempKelvin {
                
                return String(format:"%.0f", round(temp)) + "K"
            }
        }
        return "-"
    }
    
    static func getSpeedToShow(speed: Double) -> String {
        
        let u = User.getUser()
        if let u = u {
            if u.uLength == cUser.InternalLengthImperial {
                let newVal = speed * 3.6 * 0.62
                return String(format:"%.1f", round(newVal * 100) / 100) + " mps"
            } else if u.uLength == cUser.InternalLengthMetric {
                let newVal = speed  * 3.6
                
                return String(format:"%.1f", round(newVal * 100) / 100) + " km/h"
            }
        }
        return "-"
    }
    
    
    
    static func getWindDirectionToShowFromDegree(degree: Double) -> String {
        
        let d = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        let i = (degree + 11.25)/22.5;
        return d[Int(round(i)) % 16];
    }
    
    static func getImageToShow(id: Int?) -> UIImage {
        
        if let id = id {
            switch id {
            case 200...232://Thunderstorm
                return UIImage(named: "CL")!
            case 300...321:
                return UIImage(named: "CR")!
            case 500...531:
                return UIImage(named: "CR")!
            case 600...622://snow
                return UIImage(named: "CR")!
            case 701...781://Atmosphere
                return UIImage(named: "CR")!
            case 800...801://Clouds - clear sky, few clouds
                return UIImage(named: "Sun")!
            case 802...804://Clouds - clear sky
                return UIImage(named: "CS")!
            case 900...906://Extreme
                return UIImage()
            case 951...962://Additional
                return UIImage()
            default:
                return UIImage()
                
            }
        }
        return UIImage()
        
        
    }
    
    static func getDayOfWeek()->Int {
        
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.CalendarUnitWeekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay
    }
    
    
    static func initializeDatabaze() {
        
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        var u =  NSEntityDescription.insertNewObjectForEntityForName(cUser.User, inManagedObjectContext: c) as! User
        u.uLength = cUser.InternalLengthMetric
        u.uTemperature = cUser.InternalTempCelsius
        u.uChosenLocationID =  cUser.ChosenLocationCurrent
        saveContext()
    }
    
    static func saveContext() {
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }
    
    
}
