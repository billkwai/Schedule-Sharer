//
//  AddScheduleViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/4/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  This class represents a UIViewController that allows
//  the user to specify multple ScheduleBlocks to add
//  to a specific Contact

import UIKit

class AddScheduleViewController: UIViewController {

    // MARK: Public API
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var scheduleArray: [[NSDate]] = []
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Function saves the given date range into scheduleArray if the
    // data range is valid (i.e. end date comes after the start date).
    // An alert is shown to the user in each case.
    @IBAction func addPressed() {
        let start = startDatePicker.date
        let end = endDatePicker.date
        if end.compare(start) == NSComparisonResult.OrderedAscending || start.isEqualToDate(end) {
            let alertInvalid = UIAlertController(title: "Scheduled Block Was Not Added", message: "Invalid Block", preferredStyle: UIAlertControllerStyle.Alert)
            alertInvalid.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertInvalid, animated: true, completion: nil)
        }
        else {
            let newScheduleBlock: [NSDate] = [start, end]
            scheduleArray.append(newScheduleBlock)
            let alertAdded = UIAlertController(title: "Scheduled Block Was Added", message: "Remember to save when done", preferredStyle: UIAlertControllerStyle.Alert)
            alertAdded.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertAdded, animated: true, completion: nil)
        }
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
