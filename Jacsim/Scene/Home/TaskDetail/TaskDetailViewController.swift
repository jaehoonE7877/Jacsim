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
    let repository = JacsimRepository()
    
    var jacsimDays: Int = 0
    var dayArray: [Date] = []
    
    var task: UserJacsim?
    
    override func loadView() {
        self.view = mainView
    }
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDelegate()
        view.backgroundColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let task = task else { return }
        repository.checkIsDone(item: task, count: jacsimDays)
        
        
        DispatchQueue.main.async {
            self.mainView.collectionView.reloadData()
        }
    }
    // MARK: Delegate
    private func configureDelegate() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.collectionView.register(TaskDetailCollectionViewCell.self, forCellWithReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier)
        mainView.collectionView.showsHorizontalScrollIndicator = false
    }
    // MARK: Configure
    override func configure() {
        
        mainView.titleLabel.text = task?.title
        guard let task = task else { return }
        
        
        
        mainView.startDateLabel.text = formatter.string(from: task.startDate)
        mainView.endDateLabel.text = formatter.string(from: task.endDate)
        
        // urlString 값이 있으면 = web에서 저장한 이미지로 띄워주기
        if let urlString = task.mainImage {
            let url = URL(string: urlString)
            mainView.mainImage.kf.setImage(with: url)
        } else { // 없으면 loadImage 값이 있는지, 없는지
            guard let image = loadImageFromDocument(fileName: "\(task.id).jpg") else { return }
            mainView.mainImage.image = image
        }
        // collectionView cell개수
        jacsimDays = calculateDays(startDate: task.startDate, endDate: task.endDate)
        
        for date in stride(from: task.startDate, to: task.endDate + 86401, by: 86400 ){
            dayArray.append(date)
        }
        
    }
    
    override func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = Constant.BaseColor.buttonColor
        navigationItem.leftBarButtonItem?.tintColor = Constant.BaseColor.buttonColor
    }
    
    @objc func xButtonTapped(){
        self.dismiss(animated: true)
    }
    
}
// MARK: CollectionView Delegate, Datasource
extension TaskDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jacsimDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDetailCollectionViewCell
        else { return UICollectionViewCell() }
       
        formatter.dateFormat = "M월 dd일 EEEE"
        let dateText = formatter.string(from: dayArray[indexPath.item])
        guard let objectId = task?.id else { return UICollectionViewCell() }
        cell.dateLabel.text = dateText
        cell.certifiedMemo.text = task?.memoList[indexPath.row].memo
        
        guard let image = loadImageFromDocument(fileName: "\(objectId)_\(dateText).jpg") else { return UICollectionViewCell()}
        cell.certifiedImageView.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TaskDetailCollectionViewCell else { return }
        
        let vc = TaskUpdateViewController()
        vc.dateText = cell.dateLabel.text
        vc.task = task
        vc.index = indexPath.item
        self.transitionViewController(viewController: vc, transitionStyle: .push)
    }
    
    
}
