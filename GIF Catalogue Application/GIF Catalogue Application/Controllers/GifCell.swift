//
//  GifCell.swift
//  Gif Catalogue Application
//
//  Created by liene.krista.neimane on 29/07/2023.
//

import UIKit

class GifCell: UICollectionViewCell {
    @IBOutlet weak var gifImageView: UIImageView!
    
    override func layoutSubviews() {
        gifImageView.layer.borderWidth = 2.0
    }
}
