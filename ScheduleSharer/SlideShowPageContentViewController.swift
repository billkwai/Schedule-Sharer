//
//  SlideShowPageContentViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/8/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  This UIViewController represents the content page of
//  our slideshow UIPageController

import UIKit

class SlideShowPageContentViewController: UIViewController {

    // MARK: Public API
    @IBOutlet weak var pageImageView: UIImageView!
    @IBOutlet weak var pageLabel: UILabel!
    
    var imageContent: UIImage? = nil
    var textContent: String? = nil
    var index: Int = 0
    
    // MARK: Private API
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    private var image: UIImage? {
        get {
            return pageImageView?.image
        }
        set {
            pageImageView?.image = newValue
            // remove any existing aspect ratio constraint on the imageView
            if aspectRatioConstraint != nil {
                pageImageView.removeConstraint(aspectRatioConstraint!)
                aspectRatioConstraint = nil
            }
            // add a new aspect ratio constraint on the imageView
            // the imageView will be constrained to have the same aspect ratio as its image
            // this code should look very similar to an inspected constraint in Interface Builder
            if let image = newValue, let imageView = pageImageView {
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
        image = imageContent
        pageLabel.text = textContent
        self.view.backgroundColor = UIColor(red: 200.0/255, green: 199.0/255, blue: 204.0/255, alpha: 1.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
