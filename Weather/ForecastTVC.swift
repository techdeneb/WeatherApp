//
//  ForecastTVC.swift
//  Weather
//
//  Created by Vasyl Savka on 5/12/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import UIKit
import Alamofire
class ForecastTVC: UITableViewController {
    
    ///Actual day in the days variable
    let dateInTheWeek = Helper.getDayOfWeek() - 1 // 1 = Sunday, adjusted to our structure -> added +1
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var data = [[NSObject: AnyObject?]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(Helper.getDayOfWeek())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "needReloadData", name: cGeneral.NeedReloadForecastTVC, object: nil)
        
        updateUI()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    func updateUI() {
        
        data.removeAll(keepCapacity: true)
        let u = User.getUser()
        navigationItem.title = u?.uChosenLocationName ?? "-"
        var url = ""
        if let user = u where user.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent{
            
            url = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=" + user.uCurrentLatitude.description + "&lon=" + user.uCurrentLongitude.description
            
        } else {
            
            url = "http://api.openweathermap.org/data/2.5/forecast/daily?id=" + (User.getUser()?.uChosenLocationID.stringValue ?? "")
        }
        Alamofire.request(.GET, url).responseJSON() {
            (_, _, JSON, e) in
            if e == nil {
                
                var list =  (JSON as? [NSObject: AnyObject])?["list"] as? [[NSObject: AnyObject]]
                if let l = list where l.count > 5 {
                    for i in 0...6 {
                        
                        let temp = l[i]["temp"]?["day"] as? Double ?? 0
                        var weatherDes =  l[i]["weather"] as? [[NSObject: AnyObject]]
                        self.data.append([
                            cForecast.kTemp: temp,
                            cForecast.kDesc: weatherDes?.first?["main"] as? String ?? "-",
                            cForecast.kIDWeather: weatherDes?.first?["id"] as? Int
                            ])
                    }
                    self.tableView.reloadData()
                }
                
            } else {
                Helper .showAlertWithText("Can't determine weather.", sender: self)
                self.navigationItem.title = "-"
            }
        }
        
    }
    
    func needReloadData() {
        
        updateUI()
    }
    
    //MARK: UITableView Protocols
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("ForecastCell") as! ForecastCell
        
        c.lDay.text = days[(indexPath.row + dateInTheWeek) % 7]

        let temp = data[indexPath.row][cForecast.kTemp] as! Double
        c.lTemperature.text = Helper.getTemperatureToShow(temp)
        c.lWeatherDesc.text = data[indexPath.row][cForecast.kDesc] as? String
        c.iWeather.image = Helper.getImageToShow(data[indexPath.row][cForecast.kIDWeather] as? Int)
        return c
    }
    
    
}
