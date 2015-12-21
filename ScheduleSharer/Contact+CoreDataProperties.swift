//
//  Contact+CoreDataProperties.swift
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

extension Contact {

    @NSManaged var emailAddress: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var middleName: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var photo: NSData?
    @NSManaged var schedule: NSSet?

}
