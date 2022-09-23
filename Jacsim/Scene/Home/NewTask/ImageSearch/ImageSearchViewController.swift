//
//  ImageSearchViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class ImageSearchViewController: BaseViewController {
    
    // MARK: Property SearchBar, CollectionView
    var delegate: SelectImageDelegate?
    let imageSearchView = ImageSearchView()
    let apiManager = ImageSearchAPIManager.shared
    
    var imageList: [String] = []
    var totalPage = 0
    var startPage = 1
    var selectedImage: UIImage?
    var selectedIndexPath: IndexPath?
    
    var selectedImageURL: String?
    
    override func loadView() {
        self.view = imageSearchView
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        
        navigationController?.isNavigationBarHidden = false
        
        configureDelegate()
        setNavigationController()
    }

    
    private func configureDelegate() {
        imageSearchView.collectionView.delegate = self
        imageSearchView.collectionView.dataSource = self
        imageSearchView.collectionView.prefetchDataSource = self
        imageSearchView.collectionView.register(ImageSearchCollectionViewCell.self, forCellWithReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier)
        imageSearchView.searchBar.delegate = self
    }
    
    override func setNavigationController() {
        navigationController?.navigationBar.tintColor = Constant.BaseColor.textColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(selectButtonTapped))
    }
    
    @objc func selectButtonTapped(){
        
        guard let selectedImage = selectedImage else {
            showAlertMessage(title: "사진을 선택해주세요!", button: "확인")
            return
        }
        guard let selectedImageURL = selectedImageURL else { return }
        delegate?.sendImage(image: selectedImage, urlString: selectedImageURL)
        self.navigationController?.popViewController(animated: true)
    }
    
}




// MARK: Networking
extension ImageSearchViewController {
   
    func fetchImage(query: String, startPage: Int){
        
        showLoading()
        apiManager.fetchImageDate(query: query, page: startPage) { [weak self] data in
            
            guard let self = self else { return }
            data.items.forEach{ self.imageList.append($0.link) }
            self.totalPage = data.total
            
            DispatchQueue.main.async {
                self.imageSearchView.collectionView.reloadData()
                self.hideLoading()
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
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageSearchCollectionViewCell
        else { return UICollectionViewCell() }
        
        //cell.backgroundColor = .lightGray
        let url = URL(string: imageList[indexPath.item])
        
        cell.setData(imageURL: url)
        
        cell.layer.borderWidth = selectedIndexPath == indexPath ? 4 : 0
        cell.layer.borderColor = selectedIndexPath == indexPath ? Constant.BaseColor.buttonColor?.cgColor : nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageSearchCollectionViewCell else { return }
        
        selectedImage = cell.imageView.image
        selectedIndexPath = indexPath
        selectedImageURL = imageList[indexPath.item]
        collectionView.reloadData()
    }
    
}

//MARK: UICollectionView Datasource Prefetching
extension ImageSearchViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if imageList.count - 1 == indexPath.item && imageList.count < totalPage {
                showLoading()
                
                startPage += 20
                guard let text = imageSearchView.searchBar.text else { return }
                fetchImage(query: text, startPage: startPage)
                
                DispatchQueue.main.async {
                    self.imageSearchView.collectionView.reloadData()
                    self.hideLoading()
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
        guard let text = searchBar.text else { return }
        
        imageList.removeAll()
        
        fetchImage(query: text, startPage: startPage)
        
        view.endEditing(true)
        searchBar.text = ""
    }
}
