//
//  ImageSearchViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class ImageSearchViewController: BaseViewController {
    
    // MARK: SearchBar, CollectionView
    lazy var searchBar = UISearchBar().then {
        $0.backgroundColor = .lightGray
        $0.delegate = self
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let layout: UICollectionViewFlowLayout = {
        let width = UIScreen.main.bounds.width / 3
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: width, height: width * 1.1)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        return layout
    }()
    
    private var imageList: [String] = []
    private var totalPage = 0
    private var startPage = 1
    
    var selectedIndexPath: IndexPath?
    var selectedImage: UIImage?
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        
    }
    
    override func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(ImageSearchViewController.self, forCellWithReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier)
    }
    
    override func setConstraint() {
        
    }
    
}
// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension ImageSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageSearchCollectionViewCell else { return UICollectionViewCell() }
        
        //let url = URL(string: <#T##String#>)
        //cell.setData(imageURL: <#T##URL#>)
        cell.layer.borderWidth = selectedIndexPath == indexPath ? 4 : 0
        cell.layer.borderColor = selectedIndexPath == indexPath ? UIColor.tintColor.cgColor : nil
        return cell
    }
    
    
}

//MARK: UICollectionView
extension ImageSearchViewController: UICollectionViewDataSourcePrefetching{
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if imageList.count - 1 == indexPath.item && imageList.count < totalPage {

                startPage += 1
                guard let text = searchBar.text else { return }
//                UnsplashAPIManager.shared.request(page: startPage, query: text) { list, totalPage in
//                    self.imageList.append(contentsOf: list)
//                    self.totalPage = totalPage
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
}

//MARK: UISearchBarDelegate + Networking
extension ImageSearchViewController: UISearchBarDelegate {
    
}
