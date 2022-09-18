//
//  TaskDetailViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import Kingfisher

final class TaskDetailViewController: BaseViewController {
    
    //MARK: Property
    let mainView = TaskDetailView()
    
    var task: UserJacsim?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDelegate()
        view.backgroundColor = .white
    }
    
    private func configureDelegate() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.collectionView.register(TaskDetailCollectionViewCell.self, forCellWithReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier)
    }
    
    override func configure() {
        
        mainView.titleLabel.text = task?.title
        guard let startDate = task?.startDate else { return }
        guard let endDate = task?.endDate else { return }
        mainView.startDateLabel.text = formatter.string(from: startDate)
        mainView.endDateLabel.text = formatter.string(from: endDate)
        // urlString 값이 있으면 = web에서 저장한 이미지로 띄워주기
        if let urlString = task?.mainImage {
            let url = URL(string: urlString)
            mainView.mainImage.kf.setImage(with: url)
        } else { // 없으면 loadImage 값이 있는지, 없는지
            guard let objectId = task?.objectId else { return }
            guard let image = loadImageFromDocument(fileName: "\(objectId).jpg") else { return }
            mainView.mainImage.image = image
        }
        
        
    }
    
    override func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "인증하기", style: .plain, target: self, action: #selector(certifyButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = Constant.BaseColor.buttonColor
        navigationItem.leftBarButtonItem?.tintColor = Constant.BaseColor.buttonColor
    }
    
    @objc func certifyButtonTapped(){
        
    }
    
    @objc func xButtonTapped(){
        self.dismiss(animated: true)
    }
    
}

extension TaskDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDetailCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.certifiedMemo.text = "율무가 밥을 잘 먹었다."
        
        
        return cell
    }
    
    
}
