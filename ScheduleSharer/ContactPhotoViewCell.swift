//
//  FriendPhotoViewCell.swift
//  ScheduleSharer
//
//  Created by Bill Kwai on 12/2/15.
//  Copyright © 2015 Bill Kwai. All rights reserved.
//
//  This class represents a custom UICollectionVewCell

import UIKit

class ContactPhotoViewCell: UICollectionViewCell {
    
    // MARK: Public API
    @IBOutlet weak var nameLabel: UILabel! // name of Contact
    @IBOutlet weak var imageView: UIImageView! // photo of Contact
    var currentContact: Contact? = nil // reference to Contact Core Data Object
}
