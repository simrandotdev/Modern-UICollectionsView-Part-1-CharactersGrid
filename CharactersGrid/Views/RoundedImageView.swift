//
//  RoundedImageView.swift
//  CharactersGrid
//
//  Created by Simran Preet Narang on 2022-11-15.
//

import UIKit

class RoundedImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
    }
}
