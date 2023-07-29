//
//  CollectionViewController.swift
//  Gif Catalogue Application
//
//  Created by liene.krista.neimane on 20/07/2023.
//

//import RxSwift
//import RxCocoa
import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gifLabel: UILabel!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    
    private let giphyAPIKey = "eD2EKarMyNu9z4nBQaKzAC2Zyfg72oky"
    private let giphyURLSearch = "api.giphy.com/v1/gifs/search"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        fetchGifs(searchWord: "tree")
        
        // User taps anywhere to dismiss the keyboard
        let userTap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        userTap.cancelsTouchesInView = false
        view.addGestureRecognizer(userTap)
        
        gifLabel.text = "There are no GIF images to display."
    }
    
    // User taps "Search" to dismiss the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //----------------------------------------
    
    func fetchGifs(searchWord: String) {
        let urlString = "https://\(giphyURLSearch)?q=\(searchWord)&api_key=\(giphyAPIKey)"
        
        guard let url = URL(string: urlString) else {
            print("URL does not work!")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)!")
                return
            }
            
            guard let data = data else {
                print("No data received!")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print("Error parsing JSON: \(error)!")
            }
        }
        task.resume()
    }

}
