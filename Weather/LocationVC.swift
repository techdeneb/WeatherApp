//
//  LocationVC.swift
//  Weather
//
//  Created by Vasyl Savka on 5/12/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import UIKit
import Alamofire

class LocationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var data = SavedCity.getAllCities() ?? [SavedCity]()
    var currentData = [[NSObject: AnyObject?]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //does not work...
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 85
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        data = SavedCity.getAllCities() ?? [SavedCity]()
        tableView.reloadData()
        var allCities = SavedCity.getAllCities()
        if let allCities = allCities where allCities.count > 0 {
            
            var idValues = [String]()
            currentData.removeAll(keepCapacity: true)
            for c in allCities {
                
                idValues.append(c.sID.stringValue)
            }
            
            let url = "http://api.openweathermap.org/data/2.5/group?id=" + (",".join(idValues))
            
            Alamofire.request(.GET, url).responseJSON() {
                (_, _, JSON, e) in
                if e == nil {
                    
                    var list =  (JSON as? [NSObject: AnyObject])?["list"] as? [[NSObject: AnyObject]]
                    if let l = list {
                        for (i, _) in enumerate(l) {
                            let temp = l[i]["main"]?["temp"] as? Double ?? 0
                            var weatherDes =  l[i]["weather"] as? [[NSObject: AnyObject]]
                            self.currentData.append([
                                cForecast.kTemp: temp,
                                cForecast.kDesc: weatherDes?.first?["main"] as? String ?? "-",
                                cForecast.kIDWeather: weatherDes?.first?["id"] as? Int
                                ])
                        }
                        self.tableView.reloadData()
                    }
                    
                } else {
                    Helper .showAlertWithText("Can't determine weather.", sender: self)
                }
            }
            
        }
    }
    
    @IBAction func bDonePressed(sender: UIBarButtonItem) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UITableView Protocols
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let u = User.getUser()
        
        if indexPath.row == 0 {
            u?.uChosenLocationID = cUser.ChosenLocationCurrent
            u?.uChosenLocationName = nil
            u?.uCurrentLatitude = 0
            u?.uCurrentLongitude = 0
        } else {
            u?.uChosenLocationName = data[indexPath.row - 1].sCityName
            u?.uChosenLocationID = data[indexPath.row - 1].sID
        }
        Helper.saveContext()
        NSNotificationCenter.defaultCenter().postNotificationName(cGeneral.ChangeSelectedCity, object: self)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationCell
        if indexPath.row == 0 {
            
            
            let user = User.getUser()!
            if  user.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
                
                c.lCity.text = user.uChosenLocationName
                c.lTemperature.text = Helper.getTemperatureToShow(user.uCurrentTemperature.doubleValue)
                c.iWeather.image = Helper.getImageToShow(user.uCurrentWeatherImageID.integerValue)
                c.lWeatherDesc.text = user.uCurrentWeatherDesc
                c.iCurrent.hidden = false
            } else {
                
                c.lCity.text = "Current Location"
                c.lTemperature.text = ""
                c.iWeather.image = UIImage()
                c.lWeatherDesc.text = ""
                c.iCurrent.hidden = true
                
            }
        } else {
            c.iCurrent.hidden = true
            c.lCity.text = data[indexPath.row - 1].sCityName/*+ ", " + data[indexPath.row - 1].sID.stringValue*/
            if SavedCity.getAllCities()?.count == currentData.count {
                let temp = currentData[indexPath.row - 1][cForecast.kTemp] as! Double
                c.lTemperature.text = Helper.getTemperatureToShow(temp)
                c.lWeatherDesc.text = currentData[indexPath.row - 1][cForecast.kDesc] as? String
                c.iWeather.image = Helper.getImageToShow(currentData[indexPath.row - 1][cForecast.kIDWeather] as? Int)
            } else {
                c.lTemperature.text = ""
                c.lWeatherDesc.text = ""
                c.iWeather.image = UIImage()
            }
        }
        return c
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "  ✕    " , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            SavedCity.removeCity(self.data[indexPath.row - 1])
            self.data.removeAtIndex(indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        })
        
        deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "Delete")!)
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}


