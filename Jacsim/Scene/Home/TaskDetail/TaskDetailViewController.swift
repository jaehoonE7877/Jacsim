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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let task = task else { return }
        repository.checkIsDone(item: task, count: jacsimDays)
        repository.checkIsSuccess(item: task)
        
        if task.success - repository.checkCertified(item: task) > 0 {
            mainView.successLabel.text = "작심 성공까지 \(task.success - repository.checkCertified(item: task))회 남았습니다!"
        } else {
            mainView.successLabel.text = "목표를 달성했습니다! 끝까지 힘내세요!!"
        }
        
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
        
        view.backgroundColor = Constant.BaseColor.backgroundColor
        
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
        
        for date in stride(from: task.startDate, to: task.endDate + 86400, by: 86400 ){
            dayArray.append(date)
        }
    }
    
    override func setNavigationController() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "작심 그만두기", style: .plain, target: self, action: #selector(quitJacsimButtonTapped))
        //navigationItem.leftBarButtonItem?.tintColor = Constant.BaseColor.textColor
        
        navigationController?.navigationBar.tintColor = Constant.BaseColor.textColor
        navigationItem.rightBarButtonItem?.tintColor = .red
    }
    
    @objc func xButtonTapped(){
        self.dismiss(animated: true)
    }
    
    @objc func quitJacsimButtonTapped(){
        // Alert표시 진짜 그만둘건지(저장한 데이터 삭제된다.)
        showAlertMessage(title: "해당 작심을 그만두실 건가요?", message: "기존에 저장한 데이터들은 사라집니다.", button: "확인", cancel: "취소") { [weak self] _ in
            guard let self = self else { return }
            guard let task = self.task else { return }
            // 인증유무 분기처리
            self.formatter.dateFormat = "M월 dd일 EEEE"
            
            if self.repository.checkCertified(item: task) == 0 {
                
                self.repository.deleteJacsim(item: task)
                
            } else {
                // 인증이 있을 때
                for index in 0...self.repository.checkCertified(item: task) - 1 {
                    let dateText = self.formatter.string(from: self.dayArray[index])
                    self.repository.removeImageFromDocument(fileName: "\(task.id)_\(dateText).jpg")
                }
                
                self.repository.deleteJacsim(item: task)
                
            }
            
            self.dismiss(animated: true)
        }
        
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
        
        cell.layer.borderWidth = Constant.Design.borderWidth
        cell.layer.cornerRadius = Constant.Design.cornerRadius
        cell.layer.borderColor = Constant.BaseColor.textColor?.cgColor
        
       
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
        guard let task = task else { return }
        let dateText = formatter.string(from: dayArray[indexPath.item])
        // 인증처음 할 때
        if !task.memoList[indexPath.item].check {
            vc.dateText = cell.dateLabel.text
            vc.task = task
            vc.index = indexPath.item
            self.transitionViewController(viewController: vc, transitionStyle: .push)
        } else {
            vc.dateText = cell.dateLabel.text
            vc.task = task
            vc.index = indexPath.item
            vc.mainView.memoTextfield.text = task.memoList[indexPath.item].memo
            vc.mainView.certifyImageView.image = loadImageFromDocument(fileName: "\(task.id)_\(dateText).jpg")
            self.transitionViewController(viewController: vc, transitionStyle: .push)
        }
    }
    
    
}
