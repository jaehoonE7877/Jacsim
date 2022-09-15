//
//  ImageSearchViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class ImageSearchViewController: BaseViewController {
    
    // MARK: Property SearchBar, CollectionView
    
    let imageSearchView = ImageSearchView()
    let apiManager = ImageSearchAPIManager.shared
    
    var imageList: [items] = []
    var totalPage = 0
    var startPage = 1
    var selectedImage: UIImage?
    var selectedIndexPath: IndexPath?
    
    override func loadView() {
        self.view = imageSearchView
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        
        navigationController?.isNavigationBarHidden = false
        
        imageSearchView.searchBar.delegate = self
    }
    
    override func configure() {
        
        imageSearchView.collectionView.delegate = self
        imageSearchView.collectionView.dataSource = self
        imageSearchView.collectionView.prefetchDataSource = self
        imageSearchView.collectionView.register(ImageSearchViewController.self, forCellWithReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier)
        
        
    }

}
// MARK: Networking
extension ImageSearchViewController {
    func fetchImage(query: String, startPage: Int){
        apiManager.fetchImageDate(query: query, page: startPage) { [weak self] data in
            
            guard let self = self else { return }
            self.imageList = data.items
            self.totalPage = data.total
            dump(self.imageList)
            
            DispatchQueue.main.async {
                self.imageSearchView.collectionView.reloadData()
            }
        }
    }
}


// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension ImageSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageSearchCollectionViewCell else { return UICollectionViewCell() }
        
        let url = URL(string: String(describing: imageList[indexPath.item]))
        guard let url = url else { return UICollectionViewCell() }

        cell.setData(imageURL: url)
        cell.layer.borderWidth = selectedIndexPath == indexPath ? 4 : 0
        cell.layer.borderColor = selectedIndexPath == indexPath ? UIColor.tintColor.cgColor : nil
        return cell
    }
    
}

//MARK: UICollectionView
extension ImageSearchViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if imageList.count - 1 == indexPath.item && imageList.count < totalPage {
                
                startPage += 1
                guard let text = imageSearchView.searchBar.text else { return }
                fetchImage(query: text, startPage: startPage)
                
                DispatchQueue.main.async {
                    self.imageSearchView.collectionView.reloadData()
                }
            }
            
        }
    }
}

//MARK: UISearchBarDelegate + Networking
extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(#function)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
        guard let text = imageSearchView.searchBar.text else { return }
        
        print(text)
//        guard text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            showAlertMessage(title: "단어를 입력해주세요!", button: "확인")
//            return
//        }
        //imageList.removeAll()
        fetchImage(query: text, startPage: startPage)
        view.endEditing(true)
    }
}
