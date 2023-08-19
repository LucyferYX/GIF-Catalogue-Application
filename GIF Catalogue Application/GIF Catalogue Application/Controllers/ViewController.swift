//
//  CollectionViewController.swift
//  Gif Catalogue Application
//
//  Created by liene.krista.neimane on 20/07/2023.
//

import UIKit
import RxSwift
import RxCocoa

//last 2 go into extension
class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gifLabel: UILabel!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    
    private let giphyAPIKey = "eD2EKarMyNu9z4nBQaKzAC2Zyfg72oky"
    private let giphyURLSearch = "api.giphy.com/v1/gifs/search"
    
    private var gifs: [Gif] = []
    private var searchTimer: Timer?
    
    let numberOfCellsPerRow: CGFloat = 2
    let spacingBetweenCells: CGFloat = 10
    
    let searchText = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        gifCollectionView.dataSource = self
        gifCollectionView.delegate = self
        
        // User taps anywhere to dismiss the keyboard
        let userTap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        userTap.cancelsTouchesInView = false
        view.addGestureRecognizer(userTap)
        
        //add into functions
        gifLabel.text = "There are no GIF images to display."
        searchBar.text = ""
        searchBar.placeholder = "Browse GIF images"
        
        //into 4 functions
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
    

    // Extracting information from JSON, then displaying in collection view
    func fetchGifs(searchWord: String) {
        let urlString = "https://api.giphy.com/v1/gifs/search?q=\(searchWord)&api_key=\(giphyAPIKey)"
        
        // No gifs shown if search bar is empty
        if searchWord.isEmpty {
            self.gifs.removeAll()
            self.gifCollectionView.reloadData()
            self.gifLabel.isHidden = false
            return
        }

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)!")
                return
            }
            
            guard let data = data else { return }
            
            // Parsing JSON
            do {
                let decoder = JSONDecoder()
                let welcome = try decoder.decode(Welcome.self, from: data)
                self.gifs = welcome.data.compactMap { datum in
                    if let urlStr = datum.images.original.url, let url = URL(string: urlStr) {
                        return Gif(url: url)
                    } else {
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self.gifCollectionView.reloadData()
                    self.gifLabel.isHidden = !self.gifs.isEmpty
                }
            } catch {
                print("Error decoding JSON: \(error)!")
            }
        }.resume()
    }

}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        
        let totalSpacing = (2 * spacingBetweenCells) + ((numberOfCellsPerRow - 1) * spacingBetweenCells)
        let width = (collectionView.bounds.width - totalSpacing) / numberOfCellsPerRow
        return CGSize(width: width, height: 128)
    }

}


struct Gif {
    let url : URL
}

struct Welcome: Codable {
    let data: [Datum]
}

struct Datum: Codable {
    let images: Images
}

struct Images: Codable {
    let original: Original
}

struct Original: Codable {
    let url: String?
}

