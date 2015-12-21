//
//  LibaryCameraOptionViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/8/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  This class is a simple UIViewController class that
//  is presented as a popover when a user presses on
//  the image while adding a new Contact. It contains
//  two buttons: "Library" and "Camera"

import UIKit
import MobileCoreServices

class LibaryCameraOptionViewController: UIViewController{

    // MARK: Public API
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        libraryButton.sizeToFit()
        self.preferredContentSize = CGSize(width: libraryButton.frame.width*2, height: libraryButton.frame.height * 2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
