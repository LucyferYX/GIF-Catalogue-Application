//
//  CollectionViewController.swift
//  Gif Catalogue Application
//
//  Created by liene.krista.neimane on 20/07/2023.
//

//import RxSwift
//import RxCocoa
import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gifLabel: UILabel!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    
    private let giphyAPIKey = "eD2EKarMyNu9z4nBQaKzAC2Zyfg72oky"
    private let giphyURLSearch = "api.giphy.com/v1/gifs/search"
    
    //---
    private var gifs: [Gif] = []
    private var searchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        //---
        gifCollectionView.dataSource = self
        gifCollectionView.delegate = self
        
        // User taps anywhere to dismiss the keyboard
        let userTap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        userTap.cancelsTouchesInView = false
        view.addGestureRecognizer(userTap)
        
        gifLabel.text = "There are no GIF images to display."
        searchBar.text = ""
        searchBar.placeholder = "Browse GIF images"
        
        //---
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.layer.cornerRadius = 0
            searchField.clipsToBounds = true
            searchField.leftView = nil
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.lightGray
            ]
            searchField.attributedPlaceholder = NSAttributedString(string: "Browse GIF images", attributes: attributes)
        }
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundImage = UIImage()
    }
    
    // User taps "Search" to dismiss the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = ""
        return true
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.fetchGifs(searchWord: searchText)
        }
    }
    
    //---
    
    
    func fetchGifs(searchWord: String) {
        let urlString = "https://api.giphy.com/v1/gifs/search?q=\(searchWord)&api_key=\(giphyAPIKey)"
        
        // No gifs shown if search bar is empty
        if searchWord.isEmpty {
            self.gifs.removeAll()
            DispatchQueue.main.async {
                self.gifCollectionView.reloadData()
                self.gifLabel.isHidden = false
            }
            return
        }

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
                if let jsonDict = json as? [String:Any], let dataDicts = jsonDict["data"] as? [[String:Any]] {
                    self.gifs.removeAll()
                    for dataDict in dataDicts {
                        if let imagesDict = dataDict["images"] as? [String:Any], let originalDict = imagesDict["original"] as? [String:Any], let urlStr = originalDict["url"] as? String, let url = URL(string:urlStr) {
                            self.gifs.append(Gif(url:url))
                        }
                    }
                    DispatchQueue.main.async {
                        self.gifCollectionView.reloadData()
                        if self.gifs.isEmpty {
                            self.gifLabel.isHidden = false
                        } else {
                            self.gifLabel.isHidden = true
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)!")
            }
        }
        task.resume()
    }
    
    //----
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as! GifCell
        cell.configure(with: gifs[indexPath.item])
        
        if gifs.isEmpty {
            //gifLabel.text = "There are no GIF images to display."
            gifLabel.isHidden = false
        } else {
            //gifLabel.text = ""
            gifLabel.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 10
        
        let totalSpacing = (2 * spacingBetweenCells) + ((numberOfCellsPerRow - 1) * spacingBetweenCells)
        let width = (collectionView.bounds.width - totalSpacing) / numberOfCellsPerRow
        return CGSize(width: width, height: 128)
    }
    
    //-----

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            // Fetch more gifs and update collection view
        }
    }

}

struct Gif {
    let url : URL
}
