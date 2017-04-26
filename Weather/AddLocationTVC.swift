//
//  AddLocationTVC.swift
//  Weather
//
//  Created by Vasyl Savka on 5/12/15.
//  Copyright (c) 2015 Vasyl Savka. All rights reserved.
//

import UIKit

struct cPositions {
    static let ID = 0
    static let City = 1
    static let Country = 4
}

struct CityDetail {
    var city = ""
    var country = ""
    var idCity = -1
}

class AddLocationTVC: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    var data = [CityDetail]()
    var filteredData = [CityDetail]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.startAnimating()
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.barTintColor = UIColor.blueColor()
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        //difficult operations go to the background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let path = NSBundle.mainBundle().pathForResource("countries", ofType: "txt")
            if let content = String(contentsOfFile:path!, encoding: NSUTF8StringEncoding, error: nil) {
                //parsing file
                var temp = content.componentsSeparatedByString("\n")
                temp.removeAtIndex(0)
                for  line in  temp{
                    
                    let lineArray = line.componentsSeparatedByString("\t")
                    self.data.append( CityDetail(city: lineArray[cPositions.City], country: lineArray[cPositions.Country], idCity: lineArray[cPositions.ID].toInt()!) )
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.activity.stopAnimating()
                self.tableView.reloadData()
            })
            
        })
    }
    
    @IBAction func bCancelPressed(sender: UIBarButtonItem) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let record = self.resultSearchController.active ? filteredData[indexPath.row] : data[indexPath.row]
        SavedCity.insertCity(record.city, country: record.country, idCity: record.idCity)
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    //MARK: UITableView Protocols
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.resultSearchController.active) {
            return self.filteredData.count
        }
        else {
            return data.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let c = tableView.dequeueReusableCellWithIdentifier("AddLocationCell") as! UITableViewCell
        if (self.resultSearchController.active) {
            
            let record =  filteredData[indexPath.row]
            c.textLabel?.text = record.city + ", " + record.country
            
        } else {
            
            let record =  data[indexPath.row]
            c.textLabel!.text = record.city + ", " + record.city
        }
        return c
    }
    
    //MARK: Helpers
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredData = data.filter({ (line: CityDetail) -> Bool in
            
            return line.city.lowercaseString.rangeOfString(searchText) != nil
        })
        
    }
    
    //MARK: Search
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredData.removeAll(keepCapacity: false)
        filterContentForSearchText(searchController.searchBar.text.lowercaseString)
        self.tableView.reloadData()
    }
    
}
