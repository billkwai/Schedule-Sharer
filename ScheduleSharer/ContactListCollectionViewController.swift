//
//  ContactListCollectionViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/1/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  Learned how to use collection view and took some code from this resource:
//  http://www.raywenderlich.com/78550/beginning-ios-collection-views-swift-part-1
//
//  Took the resizeImage function from stack overflow at the following
//  web address:
//  http://stackoverflow.com/questions/7645454/resize-uiimage-by-keeping-aspect-ratio-and-width
//
//  Learned how to use the Contacts framework and took some code from this resource:
//  http://www.appcoda.com/ios-contacts-framework/
//
//  This class is a UICollectionViewController that displays all of the user's Contacts
//  in a collection view. Each cell represents a Contact, and when pressed, segues
//  to that Contact's "Contact Card"

import UIKit
import CoreData
import Contacts
import ContactsUI

// global variable
private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)

class ContactListCollectionViewController: UICollectionViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, CNContactPickerDelegate {
    
    // MARK: Public API
    var managedObjectContext: NSManagedObjectContext? = AppDelegate.managedObjectContext
    private lazy var allContacts: [Contact]? = Contact.retrieveAllContacts(inManagedObjectContext: self.managedObjectContext!)
    private lazy var contactsToDisplay: [Contact]? = Contact.retrieveAllContacts(inManagedObjectContext: self.managedObjectContext!)
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 0, 0))
    private var cellSize: CGSize? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        searchBar.delegate = self
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
        calculateCellSize()
    }
    
    // MARK: Private API
    // Function calculates the size that each collection view cell should be
    private func calculateCellSize() {
        let tempImage = UIImage(named: "photoNotAvailable")
        let scaleFactor = collectionView!.frame.width/2.5/tempImage!.size.width
        var tempSize = CGSize(width: tempImage!.size.width*scaleFactor, height: tempImage!.size.height*scaleFactor)
        tempSize.height += tempSize.width/3.5
        cellSize = tempSize
    }
    
    // Function updates the contactsToDisplay variable to those
    // that match the input argument, "searchTerm"
    private func updateContactsToDisplay(searchTerm: String) {
        contactsToDisplay?.removeAll()
        for contactEntry in allContacts! {
            let fullName = contactEntry.firstName! + " " + contactEntry.lastName!
            if fullName.lowercaseString.rangeOfString(searchTerm.lowercaseString) != nil {
                contactsToDisplay?.append(contactEntry)
            }
        }
    }
    
    // Function reloads the Contacts from Core Data
    private func reloadContacts() {
        allContacts = Contact.retrieveAllContacts(inManagedObjectContext: self.managedObjectContext!)
        contactsToDisplay = allContacts
    }
    
    // MARK: UIViewController Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Unwind
    // Function ensures that we update our Contacts from Core Data
    // and reload the data when we unwind back to this view controller
    @IBAction func updateFriends(segue: UIStoryboardSegue) {
        reloadContacts()
        self.collectionView?.reloadData()
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Contact Info" {
            if let destinationvc = segue.destinationViewController as? ContactInfoViewController {
                destinationvc.currentContact = (sender as? ContactPhotoViewCell)?.currentContact
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
        
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if contactsToDisplay != nil  {
            return contactsToDisplay!.count
        }
        else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("contactCell", forIndexPath: indexPath) as! ContactPhotoViewCell
    
        // Configure the cell
        var contactPhoto = UIImage(data: contactsToDisplay![indexPath.item].photo!)
        let scaleFactor = cell.frame.width/contactPhoto!.size.width
        contactPhoto = resizeImage(contactPhoto!, scale: scaleFactor)
        cell.currentContact = contactsToDisplay![indexPath.item]
        cell.imageView?.image = contactPhoto
        cell.nameLabel.text = contactsToDisplay![indexPath.item].firstName! + " " + contactsToDisplay![indexPath.item].lastName!
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor.orangeColor()
        return cell
    }
    
    // Function resizes the given image to the given scale so all of our
    // collection view cells can have the same size
    private func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        let newHeight = image.size.height * scale
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView?.reloadData()
    }
    
    // MARK: UISearchBarDelegate
    // Function updates the contacts that we are currently displaying in our
    // collection view by forwarding any changes to the text in our search bar
    // to updateContactsToDisplay()
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "") {
            contactsToDisplay = allContacts
        }
        else {
            updateContactsToDisplay(searchText)
        }
        self.collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return cellSize!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 8.0
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 8.0
    }
    
    // MARK: Contacts API
    // The following 2 functions leverage the Contacts Kit to allow the user to
    // import contacts from the user's contact book
    @IBAction func showContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "givenName != nil")
        contactPickerViewController.delegate = self
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        let firstName = contact.givenName
        let lastName = contact.familyName
        if firstName == "" || lastName == "" {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        let middleName = contact.middleName
        let email = String((contact.emailAddresses.first?.value as? NSString)) ?? ""
        let phone = (contact.phoneNumbers.first?.value as? CNPhoneNumber)?.stringValue ?? ""
        let photo = contact.imageData
        Contact.createNewContactImport(firstName, middleName: middleName, lastName: lastName, phoneNumber: phone, emailAddress: email, photo: photo, inManagedObjectContext: managedObjectContext!)
        navigationController?.popViewControllerAnimated(true)
        reloadContacts()
        self.collectionView?.reloadData()
    }

}
