//
//  CircleView.swift
//  Social
//
//  Created by Kiwon on 2017. 1. 1..
//  Copyright © 2017년 mgrdoc. All rights reserved.
//

import UIKit

class CircleView: UIImageView {


    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true

    }

}
