//
//  ScheduleBlock+CoreDataProperties.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/4/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ScheduleBlock {

    @NSManaged var startTime: NSDate?
    @NSManaged var endTime: NSDate?
    @NSManaged var contact: Contact?

}
