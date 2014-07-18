//
//  DetailViewController.swift
//  HomePit2
//
//  Created by John Grosen on 7/7/14.
//  Copyright (c) 2014 John Grosen. All rights reserved.
//

import UIKit
import HomeKit

/*
func findCharacteristic(service: HMService, name: String) -> HMCharacteristic? {
    for cha in service.characteristics as HMCharacteristic[] {
        if cha.characteristicType == name {
            return cha
        }
    }
    return nil
}
*/

protocol ServiceDelegate {
    func characteristicValueDidChange(cha: HMCharacteristic)
    func serviceNameDidChange()
}

class DetailTableViewController: UITableViewController, UISplitViewControllerDelegate, HMAccessoryDelegate {
    
    var masterPopoverController: UIPopoverController? = nil
    var lightbulbServices: HMService[] = []
    var serviceViews: [HMService: ServiceDelegate] = [HMService: ServiceDelegate]()
    
    var detailItem: AnyObject? {
    didSet {
        // Update the view.
        self.configureView()
        
        if self.masterPopoverController != nil {
            self.masterPopoverController!.dismissPopoverAnimated(true)
        }
    }
    }
    
    func configureView() {
        // self.edgesForExtendedLayout = .None
        
        // Update the user interface for the detail item.
        if let acc: HMAccessory = self.detailItem as? HMAccessory {
            let services = acc.services as [HMService]
            self.lightbulbServices = services.filter({ s in s.serviceType == "public.hap.service.lightbulb" })
            acc.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Table view
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.lightbulbServices.count > 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(UITableView!, titleForHeaderInSection section: Int) -> String! {
        switch (section) {
        case 0:
            return "Lightbulbs"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("I have \(self.lightbulbServices.count) lightbulbs ")
    return self.lightbulbServices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Lightbulb2", forIndexPath: indexPath) as UITableViewCell
        println("cell = \(cell)")
    
        println("making cell for row #\(indexPath.row)")
        cell.backgroundView = UIView()
        cell.backgroundColor = UIColor.clearColor()
        let service = self.lightbulbServices[indexPath.row]
        let view = LightbulbView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: cell.frame.size), service: service)
        self.serviceViews[service] = view
        cell.contentView.addSubview(view)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return false
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 230
    }
    
    // #pragma mark - accessory delegate
    
    func accessory(_: HMAccessory!, didUpdateNameForService service: HMService!) {
        println("didUpdateNameForService")
        self.serviceViews[service]?.serviceNameDidChange()
    }
    
    func accessory(_: HMAccessory!, service: HMService!, didUpdateValueForCharacteristic cha: HMCharacteristic!) {
        println("didUpdateValueForCharacteristic")
        self.serviceViews[service]?.characteristicValueDidChange(cha)
    }
    
    // #pragma mark - Split view
    
    func splitViewController(splitController: UISplitViewController, willHideViewController viewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController popoverController: UIPopoverController) {
        barButtonItem.title = "Accessories" // NSLocalizedString(@"Master", @"Master")
        self.navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
        self.masterPopoverController = popoverController
    }
    
    func splitViewController(splitController: UISplitViewController, willShowViewController viewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        // Called when the view is shown again in the split view, invalidating the button and popover controller.
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.masterPopoverController = nil
    }
    func splitViewController(splitController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return true
    }
    
}

