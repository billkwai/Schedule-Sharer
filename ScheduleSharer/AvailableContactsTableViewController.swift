//
//  AvailableContactsTableViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/7/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  This class represents a UITableViewController that displays
//  all the available Contacts at the current time.

import UIKit
import CoreData

class AvailableContactsTableViewController: UITableViewController, UIPageViewControllerDelegate {

    // MARK: Public API
    var managedObjectContext: NSManagedObjectContext? = AppDelegate.managedObjectContext
    
    // MARK: Private API
    private lazy var availableContacts: [Contact]? = nil
    
    // Function retrieves all Contacts and filters them such that only the
    // available Contacts are saved to our "availableContacts" array.
    private func getAvailableContacts() -> [Contact]? {
        if let allContacts = Contact.retrieveAllContacts(inManagedObjectContext: self.managedObjectContext!) {
            let currentTime = NSDate()
            let available = allContacts.filter( { (entry: Contact) -> Bool in
                if entry.schedule!.count != 0 {
                    for block in entry.schedule! {
                        let schedBlock = block as! ScheduleBlock
                        if schedBlock.startTime!.compare(currentTime) == .OrderedAscending && schedBlock.endTime!.compare( currentTime) == .OrderedDescending {
                            return false
                        }
                    }
                    return true
                }
                else {
                    return true
                }
            })
            return available
        }
        return nil
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        availableContacts = getAvailableContacts()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return availableContacts!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Friend Cell", forIndexPath: indexPath)

        // Configure the cell.
        cell.textLabel!.text = availableContacts![indexPath.row].firstName! + " " + availableContacts![indexPath.row].lastName!
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showSchedule", sender: availableContacts![indexPath.row])
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationvc = segue.destinationViewController as? SlideShowViewController {
            destinationvc.availableContacts = self.availableContacts
        }
        else if let destinationvc = segue.destinationViewController as? ScheduleTableViewController{
            let sentContact = sender as! Contact
            destinationvc.currentContact = sentContact
        }
    }

}
