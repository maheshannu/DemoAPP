//
//  HeaderCollectionReusableView.swift
//  DemoApp
//
//  Created by mahesh shukla on 01/07/17.
//  Copyright © 2017 mahesh shukla. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgUser:EGOImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
