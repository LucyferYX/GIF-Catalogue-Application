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
        gifImageView.layer.cornerRadius = 10
        gifImageView.clipsToBounds = true
    }
    
    func configure(with gif : Gif){
      DispatchQueue.global().async { [weak self] in
          if let data = try? Data(contentsOf : gif.url), let image = UIImage(data:data){
              DispatchQueue.main.async{
                  self?.gifImageView.image=image
              }
          }
      }
    }
    
    // Function to load the GIF image using the provided URL
//    func loadGif(from url: URL) {
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: url),
//               let gifImage = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.gifImageView.image = gifImage
//                }
//            }
//        }
//    }
    
}
