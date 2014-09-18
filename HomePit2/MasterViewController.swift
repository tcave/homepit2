//
//  MasterViewController.swift
//  HomePit2
//
//  Created by John Grosen on 6/29/14.
//  Copyright (c) 2014 John Grosen. All rights reserved.
//

import UIKit
import HomeKit

class MasterViewController: UITableViewController, HMHomeManagerDelegate, HMHomeDelegate {

    var detailViewController: DetailTableViewController? = nil
    var accessories: [HMAccessory] = []
    var home: HMHome? = nil {
    didSet {
        if let home = self.home {
            home.delegate = self
            println("home delegate: \(home.delegate)")
            self.accessories = home.accessories.map({ return $0 as HMAccessory }) as [HMAccessory]
            self.tableView.reloadData()
        }
    }
    }
    var homeManager: HMHomeManager = HMHomeManager()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeManager.delegate = self
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.endIndex-1].topViewController as? DetailTableViewController
        }
    }
    
    func addHome() {
        self.homeManager.addHomeWithName("My Home", { maybeHome, error in
            if let home = maybeHome {
                self.home = home
                self.homeManager.updatePrimaryHome(self.home, completionHandler: {error in })
            } else {
                println("error creating home:")
                println(error)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue?.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let acc = self.accessories[indexPath!.row] as HMAccessory
            ((segue!.destinationViewController as UINavigationController).topViewController as DetailTableViewController).detailItem = acc
        } else if segue?.identifier == "findAccessories" {
            let controller = ((segue!.destinationViewController as UINavigationController).topViewController as FindAccessoriesController)
            controller.home = self.home
            controller.addedAccessoryHandler = self.whenAccessoryAdded
        }
    }

    // #pragma mark - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accessories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 76.0/255.0, green: 161.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        bgColorView.layer.masksToBounds = true
        cell.selectedBackgroundView = bgColorView

        let acc = self.home!.accessories[indexPath.row] as HMAccessory
        cell.textLabel?.text = acc.name
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let acc = self.accessories[indexPath.row]
            self.home?.removeAccessory(acc, completionHandler: {error in
                if let error = error {
                    var errorAlert = UIAlertController(title: "Removing Failed", message: nil, preferredStyle: .Alert)
                    errorAlert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                    println(error)
                } else {
                    self.accessories.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let acc = self.home!.accessories[indexPath.row] as HMAccessory
            self.detailViewController!.detailItem = acc
        }
    }
    
    // #pramga mark - home manager delegate
    
    func homeManagerDidUpdateHomes(manager: HMHomeManager!) {
        println("got home!")
        if let primary = manager.primaryHome {
            self.home = primary
        } else if manager.homes.count > 0 {
            self.home = manager.homes[0] as? HMHome
        } else {
            self.addHome()
        }
    }

    // #pragma mark - home delegate
    
    func whenAccessoryAdded(accessory: HMAccessory) {
        self.accessories.append(accessory)
        let indexPath = NSIndexPath(forRow: self.accessories.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func home(home: HMHome!, didRemoveAccessory accessory: HMAccessory!) {
        let idx = $.indexOf(self.accessories, value: accessory)
        self.accessories.removeAtIndex(idx!)
        let indexPath = NSIndexPath(forRow: idx!, inSection: 0)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
}

