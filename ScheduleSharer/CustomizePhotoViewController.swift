//
//  CustomizePhotoViewController.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/3/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  Learned about and incorporated code from a Core Image tutorial online at:
//  http://www.raywenderlich.com/76285/beginning-core-image-swift
//
//  This class represents a UIViewController that contains the different 
//  Core Image functions that can be used to modify a Contact's photo

import UIKit

class CustomizePhotoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Public API
    @IBOutlet weak var edgesLabel: UILabel!
    @IBOutlet weak var checkmarkButton: CheckBoxUIButton!
    @IBOutlet weak var vintagePicker: UIPickerView!
    @IBOutlet weak var exposureValueLabel: UILabel!
    @IBOutlet weak var blurValueLabel: UILabel!
    @IBOutlet weak var blurStepper: UIStepper!
    @IBOutlet weak var exposureSlider: UISlider!
    
    @IBAction func blurStepperPressed(sender: UIStepper) {
        blurValueLabel.text = String(sender.value)
    }
    
    @IBAction func exposureSliderPressed(sender: UISlider) {
        exposureValueLabel.text = String(sender.value)
    }
    
    @IBAction func checkmarkButtonPressed(sender: CheckBoxUIButton) {
        sender.buttonClicked()
    }
    
    // MARK: Private API
    private var pickerData: [String] = ["None", "Faded", "Sepia"]
    
    private func formatOptions() {
        edgesLabel.sizeToFit()
        checkmarkButton.layer.borderWidth = 1.0
        checkmarkButton.layer.borderColor = UIColor.orangeColor().CGColor
        
        blurValueLabel.text = String(blurStepper.value)
        exposureValueLabel.text = String(exposureSlider.value)
        
        self.vintagePicker.delegate = self
        self.vintagePicker.dataSource = self
        
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        formatOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Target/Action
    @IBAction func cancel(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // MARK: UIPickerViewDataSource
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[row])
    }

}
