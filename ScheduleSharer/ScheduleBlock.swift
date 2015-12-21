//
//  ScheduleBlock.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/4/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//

import Foundation
import CoreData


class ScheduleBlock: NSManagedObject {

    // Function adds a new ScheduleBlock Core Data Object and correctly sets
    // the relationship between the new ScheduleBlock and the provided Contact
    // Core Data object
    class func addScheduleToContact(startDate: NSDate, endDate: NSDate, currentContact: Contact, inManagedObjectContext context: NSManagedObjectContext) {
        if let newScheduleBlock = NSEntityDescription.insertNewObjectForEntityForName("ScheduleBlock", inManagedObjectContext: context) as? ScheduleBlock {
            newScheduleBlock.startTime = startDate
            newScheduleBlock.endTime = endDate
            newScheduleBlock.contact = currentContact
        }
        try! context.save()
    }
}
