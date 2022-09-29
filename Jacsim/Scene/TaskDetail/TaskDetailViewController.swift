//
//  TaskDetailViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

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
        
        if let alarm = task.alarm {
            formatter.dateFormat = "a hh:mm"
            mainView.alarmTimeLabel.text = formatter.string(from: alarm)
        } else {
            mainView.alarmTimeLabel.text = "설정된 알람이 없습니다."
        }
        
        guard let image = loadImageFromDocument(fileName: "\(task.id).jpg") else { return }
        mainView.mainImage.image = image
        
        // collectionView cell개수
        jacsimDays = calculateDays(startDate: task.startDate, endDate: task.endDate)
        
        for date in stride(from: task.startDate, to: task.endDate + 86400, by: 86400 ){
            dayArray.append(date)
        }
    }
    
    override func setNavigationController() {
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), menu: reviseButtonTapped())
        
        navigationController?.navigationBar.tintColor = Constant.BaseColor.textColor
    }
    
    private func reviseButtonTapped() -> UIMenu {
        
//        let revise = UIAction(title: "수정", image: UIImage(systemName: "pencil.circle")) { _ in
//            guard let self = self else { return }
//            guard let title = self.task?.title else { return }
//            guard let success = self.task?.success else { return }
//            guard let id = self.task?.id else { return }
//            
//            let vc = NewTaskViewController()
//            vc.mainView.newTaskTitleTextfield.text = title
//            vc.mainView.titleCountLabel.text = "\(title.count)/20"
//            
//            vc.mainView.startDateTextField.text = self.mainView.startDateLabel.text
//            vc.mainView.endDateTextField.text = self.mainView.endDateLabel.text
//            vc.mainView.startDateTextField.isUserInteractionEnabled = false
//            vc.mainView.endDateTextField.isUserInteractionEnabled = false
//            
//            vc.mainView.successTextField.text = "\(success)"
//            
//            if let alarm = self.task?.alarm {
//                vc.mainView.alarmSwitch.isOn = true
//                self.formatter.dateFormat = "a hh:mm"
//                vc.mainView.alarmTimeLabel.text = self.formatter.string(from: alarm)
//            }
//            
//            vc.mainView.newTaskImageView.image = self.loadImageFromDocument(fileName: "\(String(describing: id)).jpg")
//            
//            vc.task = self.task
//            self.transitionViewController(viewController: vc, transitionStyle: .presentFullNavigation)
            
//        }
        let deletealarm = UIAction(title: "알람 끄기", image: UIImage(systemName: "bell.slash.fill")) { [weak self]_ in
            guard let self = self else { return }
            guard let task = self.task else { return }
            self.showAlertMessage(title: "알람을 끄시겠습니까?", message: nil, button: "확인", cancel: "취소") { _ in
                
                self.repository.deleteAlarm(item: task)
                
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        let quit = UIAction(title: "작심 그만두기", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self]_ in
            guard let self = self else { return }
            self.showAlertMessage(title: "해당 작심을 그만두실 건가요?", message: "기존에 저장한 데이터들은 사라집니다.", button: "확인", cancel: "취소") { _ in
               
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
                self.navigationController?.popViewController(animated: true)
            }
           
        }
        
        var items: [UIMenuElement] = []
        if task?.alarm != nil {
            items = [deletealarm, quit]
        } else {
            items = [quit]
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: items)
       
        return menu
    }
    
    
}
//MARK: CollectionView Delegate, Datasource
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
        
        let now = Date()
        formatter.dateFormat = "M월 dd일 EEEE"
        guard formatter.string(from: now) == dateText else {
            showAlertMessage(title: "작심 인증하기", message: "인증 날짜가 아닙니다.\n확인해주세요!", button: "확인")
            return
        }
        
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
