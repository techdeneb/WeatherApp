//
//  TodayVC.swift
//  Weather
//
//  Created by Vasyl Savka on 5/12/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class TodayVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var bShare: UIButton!
    @IBOutlet weak var iCurrent: UIImageView!
    @IBOutlet weak var lLocation: UILabel!
    @IBOutlet weak var lDescription: UILabel!
    @IBOutlet weak var lRainPercentage: UILabel!
    @IBOutlet weak var lRainAmount: UILabel!
    @IBOutlet weak var lPressure: UILabel!
    @IBOutlet weak var lWIndSPeed: UILabel!
    @IBOutlet weak var lWindDirection: UILabel!
    @IBOutlet weak var iWeather: UIImageView!
    let locationManager = CLLocationManager()

    @IBOutlet weak var cIWeatherWidth: NSLayoutConstraint!
    @IBOutlet weak var cRainTop: NSLayoutConstraint!
    @IBOutlet weak var cWindTop: NSLayoutConstraint!
    ///Prevent downloading current weather more times
    var canUpdateUI = true
    
    ///Reload Data after becoming active but not first time
    var appFirstTimeLaunched = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIScreen.mainScreen().bounds.size.height == 480) {
            cIWeatherWidth.constant -= 40
            cRainTop.constant -= 10
            cWindTop.constant -= 10
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unitChanged", name: cGeneral.ChangeUnitNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedCityChanged", name: cGeneral.ChangeSelectedCity, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        
        bShare.enabled = false
        lLocation.text = "Getting location..."
        lPressure.text = ""
        lRainAmount.text = ""
        lDescription.text = ""
        lRainPercentage.text = ""
        lWindDirection.text = ""
        lWIndSPeed.text = ""
        iCurrent.hidden = User.getUser()?.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent ? false : true ?? true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.authorizationStatus() == .Denied{
            
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = url {
                UIApplication.sharedApplication().openURL(url)
            }
            lLocation.text = "Location not determined"
            
        }
    }
    
    func appBecomeActive() {
        
        if appFirstTimeLaunched == true {
            appFirstTimeLaunched = false
            return
        }
        canUpdateUI = true
        if User.getUser()?.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
            locationManager.startUpdatingLocation()
        } else {
            updateUI()
        }
        
    }
    
    @IBAction func bSharePressed() {
        
        let textToShare = "The weather forecast is " + lDescription.text! + ". Info by STRV Weather App."
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
        
        
    }
    
    func updateUI() {
        
        var url = ""
        if  let u = User.getUser() where u.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
            url = "http://api.openweathermap.org/data/2.5/weather?lat=" + u.uCurrentLatitude.description + "&lon=" + u.uCurrentLongitude.description
        } else {
            url  = "http://api.openweathermap.org/data/2.5/weather?id=" + (User.getUser()?.uChosenLocationID.stringValue ?? "")
        }
        
        Alamofire.request(.GET, url).responseJSON() {
            (_, _, JSON, e) in
            if e == nil {
                self.bShare.enabled = true
                var u = User.getUser()
                
                let city = (JSON as? [NSObject: AnyObject])?["name"] as? String ?? "-"
                let country = (JSON as? [NSObject: AnyObject])?["sys"]?["country"] as? String ?? "-"
                let pressure = (JSON as? [NSObject: AnyObject])?["main"]?["pressure"] as? Double ?? 0
                let rainPercentage = (JSON as? [NSObject: AnyObject])?["clouds"]?["all"] as? Int ?? 0
                
                
                let tempK = (JSON as? [NSObject: AnyObject])?["main"]?["temp"] as? Double ?? 0
                u?.uCurrentTemperature = tempK
                
                
                var weatherDes =  (JSON as? [NSObject: AnyObject])?["weather"] as? [[NSObject: AnyObject]]
                let tempDescription = weatherDes?.first?["main"] as? String ?? "-"
                u?.uCurrentWeatherDesc = tempDescription
                
                let imageID =  weatherDes?.first?["id"] as? Int
                u?.uCurrentWeatherImageID = imageID ?? 0
                
                let windDeg = (JSON as? [NSObject: AnyObject])?["wind"]?["deg"] as? Double ?? 0
                let windSpeed = (JSON as? [NSObject: AnyObject])?["wind"]?["speed"] as? Double ?? 0
                u?.uCurrentSpeed = windSpeed
                
                self.lRainPercentage.text = rainPercentage.description + "%"
                self.lPressure.text = String(format: "%.0f", pressure) + " hPa"
                self.lLocation.text = city + ", " + country
                self.lDescription.text = Helper.getTemperatureToShow(tempK) + " | " + tempDescription
                self.lWIndSPeed.text = Helper.getSpeedToShow(windSpeed)
                self.lWindDirection.text = Helper.getWindDirectionToShowFromDegree(windDeg)
                
                self.iWeather.image = Helper.getImageToShow(imageID)
                
                u?.uChosenLocationName = city
                Helper.saveContext()
                //u?.debug()
                NSNotificationCenter.defaultCenter().postNotificationName(cGeneral.NeedReloadForecastTVC, object: nil)
                
            } else {
                
                Helper .showAlertWithText("Can't determine weather.", sender: self)
                self.lLocation.text = "Not determined"
            }
        }
        
    }
    
    func unitChanged() {
        
        if let u = User.getUser() {
            
            lDescription.text = Helper.getTemperatureToShow(u.uCurrentTemperature.doubleValue) + " | " + u.uCurrentWeatherDesc
            lWIndSPeed.text = Helper.getSpeedToShow(u.uCurrentSpeed.doubleValue)
        }
        
    }
    
    func selectedCityChanged() {
        
        canUpdateUI = true
        if User.getUser()?.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
            locationManager.startUpdatingLocation()
        } else {
            updateUI()
        }
    }
    
    
    //MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if canUpdateUI == true && locations.count > 0 {
            
            canUpdateUI = false
            manager.stopUpdatingLocation()
            var u = User.getUser()
            u?.uCurrentLatitude = (locations.first as? CLLocation)?.coordinate.latitude ?? 0
            u?.uCurrentLongitude = (locations.first as? CLLocation)?.coordinate.longitude ?? 0
            Helper.saveContext()
            updateUI()
        }
    }
    
}
