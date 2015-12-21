//
//  ContactInfoViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/2/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  Took code to crop image to get a square from Stack Overflow:
//  http://stackoverflow.com/questions/14203951/cropping-center-square-of-uiimage
//
//  This class is a UIViewController that represents a "Contact Card"
//  for a given Contact

import UIKit
import MobileCoreServices
import CoreData
import CoreImage

class ContactInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Public API
    var managedObjectContext: NSManagedObjectContext? = AppDelegate.managedObjectContext
    
    @IBOutlet weak var availableButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var customizeButton: UIButton!
    @IBOutlet weak var newPhotoButton: UIButton!
    
    var currentContact: Contact? = nil
    
    @IBAction func viewScheduleButtonPressed() {
        performSegueWithIdentifier("showSchedule", sender: currentContact)
    }
    
    // Function sets up a push notification if the "Currently Unavailable"
    // button is shown on screen. The push notification is sent to the user
    // when someone who is currently unavailable becomes available
    @IBAction func availableButtonPressed(sender: UIButton) {
        if sender.titleLabel?.text == "Currently Busy" {
            let fullName: String = currentContact!.firstName! + " " + currentContact!.lastName!
            let alert = UIAlertController(title: "Push Notification", message: "Would you like a push notification when \(fullName) becomes available?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alert) -> Void in
                let notification = UILocalNotification()
                notification.alertBody = "\(fullName) is now available!"
                notification.alertAction = "view"
                notification.fireDate = self.timeAvailable
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func newPhotoTouched() {
        takePhoto()
    }
    
    @IBAction func libraryTouched() {
        importPhotoFromLibrary()
    }
    
    // MARK: Private API
    private var timeAvailable: NSDate? = nil
    
    private var coreImageContext: CIContext = CIContext(options: nil)

    private var aspectRatioConstraint: NSLayoutConstraint?
    
    // Computed property to properly format our UIImage
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

    // Function checks if the Contact is currently available and appropriately
    // formats the availableButton. This function also sets timeAvailable to
    // to the latest endTime, which is the time that a push notification will be
    // sent to a user if a user chooses to do so
    private func checkIfAvailable() {
        var result = true
        if currentContact != nil {
            let currentTime = NSDate()
            for entry in currentContact!.schedule! {
                if (entry as! ScheduleBlock).startTime!.compare(currentTime) == .OrderedAscending && (entry as! ScheduleBlock).endTime!.compare(currentTime) == .OrderedDescending {
                    result = false
                    if timeAvailable == nil {
                        timeAvailable = (entry as! ScheduleBlock).endTime
                    }
                    else if timeAvailable!.compare((entry as! ScheduleBlock).endTime!) == .OrderedAscending {
                        timeAvailable = (entry as! ScheduleBlock).endTime
                    }
                }
            }
        }
        if result {
            availableButton.setTitle("Currently Available", forState: .Normal)
            availableButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
            availableButton.enabled = false
        }
        else {
            availableButton.setTitle("Currently Busy", forState: .Normal)
            availableButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            availableButton.enabled = true
        }
    }
    
    // Function crops an UIImage to the given square size so that we can
    // round out the edges and make the UI present the image in a circle
    private func imageByCroppingImage(image : UIImage, size : CGSize) -> UIImage?{
        let refWidth : CGFloat = CGFloat(CGImageGetWidth(image.CGImage))
        let refHeight : CGFloat = CGFloat(CGImageGetHeight(image.CGImage))
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        let cropRect = CGRectMake(x, y, size.height, size.width)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)
        let cropped : UIImage = UIImage(CGImage: imageRef!, scale: 0, orientation: image.imageOrientation)
        return cropped
    }
    
    // Function resizes an image to an appropriate size that fits nicely
    // in the UI
    private func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        let newHeight = image.size.height * scale
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func formatButtons() {
        newPhotoButton.sizeToFit()
        newPhotoButton.layer.borderColor = UIColor.orangeColor().CGColor
        newPhotoButton.layer.borderWidth = 1.0
        libraryButton.layer.borderColor = UIColor.orangeColor().CGColor
        libraryButton.layer.borderWidth = 1.0
        customizeButton.layer.borderColor = UIColor.orangeColor().CGColor
        customizeButton.layer.borderWidth = 1.0
    }
    
    // Formats the image and nicely puts the image into our UI as a circle
    private func formatImage(currentImage: UIImage?) {
        let normalSizedImage = currentImage
        let scaleFactor = self.view.frame.width/2/normalSizedImage!.size.width
        let scaledImage = resizeImage(normalSizedImage!, scale: scaleFactor)
        let length = scaledImage.size.height > scaledImage.size.width ? scaledImage.size.width : scaledImage.size.height
        let size: CGSize = CGSize(width: length, height: length)
        image = imageByCroppingImage(scaledImage, size: size)
        imageView.layer.borderWidth = 2.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.orangeColor().CGColor
        imageView.layer.cornerRadius = imageView.image!.size.height/2
        imageView.clipsToBounds = true
    }
    
    
    // MARK: UIViewController Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        checkIfAvailable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatButtons()
        if currentContact == nil {
            nameLabel.text = "No Entry"
            phoneNumberLabel.text = "No Entry"
            emailLabel.text = "No Entry"
            image = UIImage(named: "photoNotAvailable")
            availableButton.setTitle("", forState: .Normal)
            availableButton.enabled = false
        }
        else {
            nameLabel.text = currentContact!.firstName! + " " + currentContact!.middleName! + " " + currentContact!.lastName!
            if currentContact!.phoneNumber == "" {
                phoneNumberLabel.text = "No Entry"
            }
            else {
                phoneNumberLabel.text = currentContact!.phoneNumber
            }
            if currentContact!.emailAddress == "" {
                emailLabel.text = "No Entry"
            }
            else {
                emailLabel.text = currentContact!.emailAddress
            }
            formatImage(UIImage(data: currentContact!.photo!))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Unwind
    // Function adds the new ScheduleBlocks from our modal view controller
    // to Core Data
    @IBAction func scheduleUpdated(segue: UIStoryboardSegue) {
        let sourcevc = segue.sourceViewController as? AddScheduleViewController
        let newSchedulesArray = sourcevc!.scheduleArray
        for entry in newSchedulesArray {
            ScheduleBlock.addScheduleToContact(entry[entry.startIndex], endDate: entry[entry.endIndex.predecessor()], currentContact: currentContact!, inManagedObjectContext: managedObjectContext!)
        }
    }
    
    // Function applies the Core Image filters applied to the current Contact's
    // and appropriately updates this new, modified image in Core Data
    @IBAction func updatePhoto(segue: UIStoryboardSegue) {
        let sourcevc = segue.sourceViewController as? CustomizePhotoViewController
        let blurValue = sourcevc!.blurStepper!.value
        let exposureValue = sourcevc!.exposureSlider.value
        let isEdgeColored = sourcevc!.checkmarkButton.isChecked
        let vintageFeature = sourcevc!.pickerView(sourcevc!.vintagePicker, attributedTitleForRow: 0, forComponent: 0)
        
        // Core Image filtering application
        let originalImage = CIImage(image: UIImage(data: currentContact!.photo!)!)
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(blurValue, forKey: kCIInputRadiusKey)
        var tempImage = blurFilter?.outputImage
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(tempImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(exposureValue, forKey: kCIInputEVKey)
        tempImage = exposureFilter?.outputImage
        if isEdgeColored {
            let edgeFilter = CIFilter(name: "CIEdges")
            edgeFilter?.setValue(tempImage, forKey: kCIInputImageKey)
            edgeFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
            tempImage = edgeFilter?.outputImage
        }
        if vintageFeature == "Faded" {
            let vintageFilter = CIFilter(name: "CIPhotoEffectFade")
            vintageFilter?.setValue(tempImage, forKey: kCIInputImageKey)
            tempImage = vintageFilter?.outputImage
        }
        else if vintageFeature == "Sepia" {
            let vintageFilter = CIFilter(name: "CISepiaTone")
            vintageFilter?.setValue(tempImage, forKey: kCIInputImageKey)
            vintageFilter?.setValue(0.5, forKey: kCIInputIntensityKey)
            tempImage = vintageFilter?.outputImage
        }
        if tempImage != nil {
            let newTempImage = coreImageContext.createCGImage(tempImage!, fromRect: tempImage!.extent)
            let newImage = UIImage(CGImage: newTempImage)
            formatImage(newImage)
            Contact.updateContactImage(newImage, contact: currentContact, inManagedObjectContext: managedObjectContext!)
        }
    }
    
    // MARK: Camera/UIImagePickerControllerDelegate
    // Function is wired up from the camera button
    // takes a photo with the camera if possible
    private func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = true
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    // Function opens the device's photo library and allows users to
    // choose a photo
    private func importPhotoFromLibrary() {
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
        let newImage = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage
        Contact.updateContactImage(newImage, contact: currentContact, inManagedObjectContext: managedObjectContext!)
        formatImage(newImage)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Function is a delegate method called when the user cancels taking a photo
    // simply dismisses the picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationvc = segue.destinationViewController as? ScheduleTableViewController {
            let contactToSend = sender as? Contact
            destinationvc.currentContact = contactToSend
        }
    }

}
