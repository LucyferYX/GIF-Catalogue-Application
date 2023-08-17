//
//  GifCell.swift
//  Gif Catalogue Application
//
//  Created by liene.krista.neimane on 29/07/2023.
//

import UIKit
import SDWebImage
import FLAnimatedImage

class GifCell: UICollectionViewCell {
    
    @IBOutlet weak var gifImageView: FLAnimatedImageView!
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func layoutSubviews() {
        gifImageView.layer.cornerRadius = 10
        gifImageView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gifImageView.addSubview(activityIndicator)
        activityIndicator.frame = gifImageView.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gifImageView.image = nil
        activityIndicator.startAnimating()
    }
    
    func configure(with gif: Gif) {
        activityIndicator.startAnimating()
        gifImageView.sd_setImage(with: gif.url) { [weak self] _, _, _, _ in
            self?.activityIndicator.stopAnimating()
        }
    }
    
}
