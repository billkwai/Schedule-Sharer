//
//  CheckBoxUIButton.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/3/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  Took parts of code from stack overflow at this web address:
//  http://stackoverflow.com/questions/28546557/saving-state-of-uibutton-checkbox-swift
//
//  This class subclasses UIButton to allow a checkbox since Swift
//  does not natively support checkboxes
//

import UIKit

class CheckBoxUIButton: UIButton {
    
    // MARK: Public API
    let checkedImage: UIImage = UIImage(named: "checkmark")! as UIImage
    
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                let scaleFactor = frame.size.width / checkedImage.size.width
                self.setImage(resizeImage(checkedImage, scale: scaleFactor), forState: .Normal)
            } else {
                self.setImage(nil, forState: .Normal)
            }
        }
    }
    
    func buttonClicked() {
        if isChecked == true {
            isChecked = false
        } else {
            isChecked = true
        }
    }
    
    // MARK: Private API
    private func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        let newHeight = image.size.height * scale
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
