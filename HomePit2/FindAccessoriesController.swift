//
//  FindAccessoriesController.swift
//  HomePit2
//
//  Created by John Grosen on 6/29/14.
//  Copyright (c) 2014 John Grosen. All rights reserved.
//

import UIKit
import HomeKit

class FindAccessoriesController: UITableViewController, HMAccessoryBrowserDelegate, UIAlertViewDelegate {
    
    var home: HMHome! = nil
    var addedAccessoryHandler: ((HMAccessory) -> Void)! = nil
    var accessories: [HMAccessory] = []
    var accessoryBrowser = HMAccessoryBrowser()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryBrowser.delegate = self
        
        println("now searching for accessories")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accessoryBrowser.startSearchingForNewAccessories()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let itemIndicator = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButtonItem(itemIndicator, animated: false)
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.accessories = []
        self.accessoryBrowser.stopSearchingForNewAccessories()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let acc = self.accessories[indexPath.row]
        cell.textLabel.text = acc.name
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("\(self.parentViewController.parentViewController)")
        let acc = self.accessories[indexPath.row]
        let message = "Are you sure you want to pair with \(acc.name)?"
        
        var alert = UIAlertController(title: "Pair?", message: "Are you sure you want to pair with \"\(acc.name)\"?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            if let selectedRow = self.tableView.indexPathForSelectedRow() {
                self.tableView.deselectRowAtIndexPath(selectedRow, animated: true)
            }
            }))
        
        alert.addAction(UIAlertAction(title: "Pair", style: .Default, handler: { action in
            self.home.addAccessory(acc, /* nil */ { error in
                if let error = error {
                    var errorAlert = UIAlertController(title: "Pairing Failed", message: nil, preferredStyle: .Alert)
                    errorAlert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.addedAccessoryHandler(acc)
                }
            })
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // #pragma mark - Accessory delegate
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory!) {
        self.accessories.insert(accessory, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory!) {
        let idx = $.indexOf(self.accessories, value: accessory)
        self.accessories.removeAtIndex(idx!)
        let indexPath = NSIndexPath(forRow: idx!, inSection: 0)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}