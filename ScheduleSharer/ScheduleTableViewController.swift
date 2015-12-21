//
//  ScheduleTableViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/8/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  This class shows the upcoming ScheduleBlocks for a given
//  Contact in a UITableView

import UIKit

class ScheduleTableViewController: UITableViewController {

    // MARK: Public API
    var currentContact: Contact? = nil
    var blocksToDisplay: [ScheduleBlock]? = nil
    
    // MARK: Private API
    // Function filters the array of ScheduleBlocks such that only 
    // the ScheduleBlocks that have yet to occur or are currently
    // occuring are displayed in our UITableView
    private func filterScheduleBlocks() {
        let currentTime = NSDate()
        let descriptor = NSSortDescriptor(key: "startTime", ascending: true)
        let sortedSchedules = currentContact!.schedule!.sortedArrayUsingDescriptors([descriptor]) as! [ScheduleBlock]
        let available = sortedSchedules.filter( { (entry: ScheduleBlock) -> Bool in
            if entry.endTime!.compare(currentTime) == .OrderedDescending {
                return true
            }
            else {
                return false
            }
        })
        blocksToDisplay = available
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentContact != nil {
            self.title = currentContact!.firstName! + " " + currentContact!.lastName! + "'s Schedule"
            filterScheduleBlocks()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewControllerDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if blocksToDisplay != nil {
            return blocksToDisplay!.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scheduleBlock", forIndexPath: indexPath)

        // Configure the cell...
        let block = blocksToDisplay![indexPath.row]
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        let outputStart = formatter.stringFromDate(block.startTime!)
        let outputEnd = formatter.stringFromDate(block.endTime!)
        cell.textLabel!.text = outputStart + "    TO    " + outputEnd
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        return cell
    }

}
