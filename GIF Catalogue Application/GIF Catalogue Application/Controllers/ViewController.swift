//
//  ViewController.swift
//  GIF Catalogue Application
//
//  Created by liene.krista.neimane on 20/07/2023.
//

import UIKit
import RxSwift
//import RxCocoa
//import SDWebImage

class ViewController: UICollectionViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    @IBOutlet weak var gifDisplayLabel: UILabel!
    
    // Testing
    @IBOutlet weak var gifView: UIView!
    @IBOutlet weak var gifImageView: UIImageView!
    
    private let giphyAPIKey = "eD2EKarMyNu9z4nBQaKzAC2Zyfg72oky"
    private let giphyURLSearch = "api.giphy.com/v1/gifs/search"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User taps anywhere to dismiss the keyboard
        let userTap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        userTap.cancelsTouchesInView = false
        view.addGestureRecognizer(userTap)
        
        // Rounding corners of gif
        gifView.layer.borderWidth = 2.0
        
        searchBar.delegate = self
    }
    
    // User taps "Search" to dismiss the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    //----------------------------------------
    
    
    
}
