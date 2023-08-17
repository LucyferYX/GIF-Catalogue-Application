//
//  CollectionViewController.swift
//  Gif Catalogue Application
//
//  Created by liene.krista.neimane on 20/07/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gifLabel: UILabel!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    
    private let giphyAPIKey = "eD2EKarMyNu9z4nBQaKzAC2Zyfg72oky"
    private let giphyURLSearch = "api.giphy.com/v1/gifs/search"
    
    private var gifs: [Gif] = []
    private var searchTimer: Timer?
    
    let searchText = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    // let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
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
            // Corners
            searchField.layer.cornerRadius = 5
            searchField.clipsToBounds = true
            // Colours
            searchField.backgroundColor = UIColor.white
            searchField.layer.borderColor = UIColor.systemGray4.cgColor
            searchField.layer.borderWidth = 1
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.lightGray
            ]
            // Removes search bar icon
            searchField.leftView = nil
            searchField.attributedPlaceholder = NSAttributedString(string: "Browse GIF images", attributes: attributes)
        }
        searchBar.backgroundImage = UIImage()
        
        // RxSwift
        // Fetch GIFs based on the search text with time interval
        searchText
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.fetchGifs(searchWord: text)
            })
            .disposed(by: disposeBag)

        searchBar.rx.text
            .orEmpty
            .bind(to: searchText)
            .disposed(by: disposeBag)
    }
    
    // User taps "Search" to dismiss the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.text = ""
        return true
    }

    // Fetch GIFs based on the search text with time interval
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchTimer?.invalidate()
//        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
//            self?.fetchGifs(searchWord: searchText)
//        }
//    }
    

    // Extracting information from JSON, then displaying in collection view
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
            
            // Parsing JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonDict = json as? [String:Any], let dataDicts = jsonDict["data"] as? [[String:Any]] {
                    self.gifs.removeAll()
                    for dataDict in dataDicts {
                        if let imagesDict = dataDict["images"] as? [String:Any], let originalDict = imagesDict["original"] as? [String:Any], let urlStr = originalDict["url"] as? String, let url = URL(string:urlStr) {
                            self.gifs.append(Gif(url:url))
                        }
                    }
                    //Updating label based on whether gifs are displayed
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
    

    // Return the number of gifs in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }

    // Dequeued reusable cell and pass it to GifCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell1", for: indexPath) as! GifCell
        cell.configure(with: gifs[indexPath.item])
        
        return cell
    }
    
    // Gif cell layout (2 cells per row)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 10
        
        let totalSpacing = (2 * spacingBetweenCells) + ((numberOfCellsPerRow - 1) * spacingBetweenCells)
        let width = (collectionView.bounds.width - totalSpacing) / numberOfCellsPerRow
        return CGSize(width: width, height: 128)
    }

}

struct Gif {
    let url : URL
}
