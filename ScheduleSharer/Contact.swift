//
//  Contact.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/4/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Contact: NSManagedObject {
    
    // Function creates a new Contact Core Data object and saves it to Core Data. 
    // If successful, the function returns true. If an entry with the same
    // first and last name already exists in Core Data, false is returned.
    // If the new Contact could not be added to Core Data for any reason, a nil
    // is returned.
    class func createNewContact(firstName: String, middleName: String?, lastName: String, phoneNumber: String?, emailAddress: String?, photo: UIImage?, inManagedObjectContext context: NSManagedObjectContext) -> Bool? {
        let request = NSFetchRequest(entityName: "Contact")
        request.predicate = NSPredicate(format: "firstName =[c] %@ AND lastName =[c] %@", argumentArray: [firstName, lastName])
        if let _ = (try? context.executeFetchRequest(request))?.first as? Contact {
            return false
        }
        else if let newContact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as? Contact{
            newContact.firstName = firstName
            newContact.lastName = lastName
            newContact.middleName = middleName
            newContact.phoneNumber = phoneNumber
            newContact.emailAddress = emailAddress
            // include the setting of photo and schedule
            if photo == nil {
                let picture = UIImageJPEGRepresentation(UIImage(named: "photoNotAvailable")!, 1.00)
                newContact.photo = picture
            }
            else {
                let picture = UIImageJPEGRepresentation(photo!, 1.00)
                newContact.photo = picture
            }
            try! context.save()
            return true
        }
        return nil
    }
    
    // Function creates a new Contact Core Data object and saves it to Core Data.
    // If successful, the functionr returns true. If a Contact exists with the same
    // first and last name, its data is merged and over-writtern with the new arguments,
    // and the function also returns true. The function returns false when the entry could
    // not be added to Core Data.
    class func createNewContactImport(firstName: String, middleName: String?, lastName: String, phoneNumber: String?, emailAddress: String?, photo: NSData?, inManagedObjectContext context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest(entityName: "Contact")
        request.predicate = NSPredicate(format: "firstName =[c] %@ AND lastName =[c] %@", argumentArray: [firstName, lastName])
        if let duplicateEntry = (try? context.executeFetchRequest(request))?.first as? Contact { // merge and over-write
            if duplicateEntry.middleName! == "" {
                duplicateEntry.middleName = middleName
            }
            if duplicateEntry.emailAddress == "" && emailAddress != "nil"{
                duplicateEntry.emailAddress = emailAddress
            }
            if duplicateEntry.phoneNumber == "" {
                duplicateEntry.phoneNumber = phoneNumber
            }
            if photo != nil {
                duplicateEntry.photo = photo
            }
            return true
        }
        else if let newContact = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: context) as? Contact{ // create new object
            newContact.firstName = firstName
            newContact.lastName = lastName
            newContact.middleName = middleName
            newContact.phoneNumber = phoneNumber
            // parsing the email address is necessary because getting
            // the string representation of an email address from a contact
            // either sets the value to "nil" or "optional(xxxxxxx)"
            if emailAddress == "nil" {
                newContact.emailAddress = ""
            }
            else {
                let start = emailAddress!.startIndex.advancedBy(9)
                let end = emailAddress!.startIndex.advancedBy(emailAddress!.characters.count - 1)
                newContact.emailAddress = emailAddress?.substringWithRange(Range(start: start, end: end))
            }
            // include the setting of photo and schedule
            if photo == nil {
                let picture = UIImageJPEGRepresentation(UIImage(named: "photoNotAvailable")!, 1.00)
                newContact.photo = picture
            }
            else {
                newContact.photo = photo!
            }
            try! context.save()
            return true
        }
        return false
    }
    
    // Function retrieves all Contact Core Data Objects and returns them in in an array.
    // If the results could not be fetched, nil is returned
    class func retrieveAllContacts(inManagedObjectContext context: NSManagedObjectContext) -> [Contact]? {
        let request = NSFetchRequest(entityName: "Contact")
        let sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        request.sortDescriptors = sortDescriptors
        if let result = (try? context.executeFetchRequest(request)) as? [Contact] {
            return result
        }
        else {
            return nil
        }
    }
    
    // Function updates the photo for the given Contact in Core Data
    class func updateContactImage(photo: UIImage?, contact: Contact?, inManagedObjectContext context: NSManagedObjectContext) {
        if photo != nil {
            contact!.photo = UIImageJPEGRepresentation(photo!, 1.00)
            try! context.save()
        }
    }

}
