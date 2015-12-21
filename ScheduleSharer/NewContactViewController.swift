//
//  NewContactViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/1/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  Fixed a problem I had with the photo and image pickers trying to load
//  at the same time after unwinding using a line of code form the following:
//  http://stackoverflow.com/questions/28620065/attempt-to-present-viewcontroller-which-is-already-presenting-null
//
//  This class shows a UIViewController with various text field and
//  a photo that allows the user to input a new Contact entry

import UIKit
import CoreData
import MobileCoreServices

class NewContactViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    // Mark: Public API
    var managedObjectContext: NSManagedObjectContext? = AppDelegate.managedObjectContext

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Private API
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    // Computed Property to ensure that our UIImage is well formatted
    // and maintains aspect ratio
    private var image: UIImage? {
        get {
            return imageView?.image
        }
        set {
            imageView?.image = newValue
            // remove any existing aspect ratio constraint on the imageView
            if aspectRatioConstraint != nil {
                imageView.removeConstraint(aspectRatioConstraint!)
                aspectRatioConstraint = nil
            }
            // add a new aspect ratio constraint on the imageView
            // the imageView will be constrained to have the same aspect ratio as its image
            // this code should look very similar to an inspected constraint in Interface Builder
            if let image = newValue, let imageView = imageView {
                let aspectRatio = image.size.width / image.size.height
                aspectRatioConstraint = NSLayoutConstraint(
                    item: imageView,
                    attribute: .Width,
                    relatedBy: .Equal,
                    toItem: imageView,
                    attribute: .Height,
                    multiplier: aspectRatio,
                    constant: 0
                )
                imageView.addConstraint(aspectRatioConstraint!)
            }
        }
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        image = UIImage(named: "photoNotAvailable")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        firstNameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Unwind
    // The following 2 functions uses the thread dispatcher to halt
    // the code bounded within the closure because originally,
    // there was a problem when the previous view controller would
    // try to unwind and call present a new photo library or camera
    // view controller while this current view contrller was trying
    // to load at the same time
    @IBAction func libaryOptionPressed(segue: UIStoryboardSegue) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.importPhotoFromLibrary()
        }
    }
    
    @IBAction func cameraOptionPressed(segue: UIStoryboardSegue) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.takePhoto()
        }
    }
    
    // MARK: Camera/UIImagePickerControllerDelegate
    // Function is wired up from the camera button
    // takes a photo with the camera if possible
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = true
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    // Function presents a new view controller where the user
    // can pick a photo from their photo library
    func importPhotoFromLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // Function is a delegate method called when the user has taken a photo
    // the dictionary contains the image (original and edited)
    // (among other things)
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Function is a delegate method called when the user cancels taking a photo
    // simply dismisses the picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Gestures
    // This function handles a tap gesture on the photo. When a tap gesture
    // is recognized, a popover view controller is shown to prompt the user
    // if they want to take a new photo with their camera or to choose a
    // photo from their photo library
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        let optionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Library Photo Option") as! LibaryCameraOptionViewController
        optionViewController.modalPresentationStyle = .Popover
        let popoverOptionViewController = optionViewController.popoverPresentationController
        popoverOptionViewController?.permittedArrowDirections = .Any
        popoverOptionViewController?.delegate = self
        popoverOptionViewController?.sourceView = recognizer.view
        popoverOptionViewController?.sourceRect = CGRect(x: recognizer.locationInView(recognizer.view.self).x, y: recognizer.locationInView(recognizer.view.self).y, width: 1, height: 1)
        presentViewController(optionViewController, animated: true, completion: nil)
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    // MARK: Navigation
    // Function returns true if a valid entry was typed in, but returns false
    // if a valid entry was not. In any case, an appropriate alert is shown
    // to the user
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "Done Adding Contact" {
            if firstNameTextField.text! == "" || lastNameTextField.text! == "" {
                let alertNoEntry = UIAlertController(title: "Contact Was Not Added", message: "Required fields are missing", preferredStyle: UIAlertControllerStyle.Alert)
                alertNoEntry.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertNoEntry, animated: true, completion: nil)
                return false
            }
            else {
                let contactCreated = Contact.createNewContact(firstNameTextField.text!, middleName: middleNameTextField.text, lastName: lastNameTextField.text!, phoneNumber: phoneNumberTextField.text, emailAddress: emailAddressTextField.text, photo: image, inManagedObjectContext: managedObjectContext!)
                if contactCreated == nil {
                    let alertError = UIAlertController(title: "Contact Was Not Added", message: "There was an error adding this entry", preferredStyle: UIAlertControllerStyle.Alert)
                    alertError.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertError, animated: true, completion: nil)
                    return false
                }
                else if contactCreated == false {
                    let alertDuplicate = UIAlertController(title: "Contact Was Not Added", message: "This entry already exists", preferredStyle: UIAlertControllerStyle.Alert)
                    alertDuplicate.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertDuplicate, animated: true, completion: nil)
                    return false
                }
                else {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    return true
                }
            }
        }
        return true
    }

}


