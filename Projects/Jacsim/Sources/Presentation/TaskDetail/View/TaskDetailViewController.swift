//
//  TaskDetailViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import Core
import DSKit

final class TaskDetailViewController: BaseViewController {
    
    //MARK: - Public
    var passPreVC: (()-> Void)?
    
    //MARK: Property
    let mainView = TaskDetailView()
    private let documentManager = DocumentManager.shared

    private var dayViewData: [TaskDetailViewModel.DayViewData] = []
    
    private let viewModel: TaskDetailViewModel
    
    init(viewModel: TaskDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
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

        viewModel.refreshTaskStatus()
        updateSuccessLabel()
        dayViewData = viewModel.dayViewData

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

        view.backgroundColor = .backgroundNormal

        mainView.startDateLabel.text = viewModel.startDateText
        mainView.endDateLabel.text = viewModel.endDateText
        mainView.alarmTimeLabel.text = viewModel.alarmText
        dayViewData = viewModel.dayViewData
        updateSuccessLabel()
        Task { [weak self] in
            await self?.loadMainImage()
        }
    }

    private func updateSuccessLabel() {
        let remaining = viewModel.remainingSuccessCount

        if remaining > 0 {
            let front = "작심 성공까지".heading3(color: .labelNormal, alignment: .center)
            let count = " \(remaining) 회".heading3(color: .primaryNormal, alignment: .center)
            let last = " 남았습니다!".heading3(color: .labelNormal, alignment: .center)
            mainView.successLabel.attributedText = front + count + last
        } else {
            mainView.successLabel.attributedText = "🎉 목표를 달성했습니다! 🎉".heading3(color: .positive, alignment: .center)
        }
    }

    private func loadMainImage() async {
        let image = await documentManager.loadImage(fileName: viewModel.mainImageIdentifier) ?? DSKitAsset.Assets.jacsim.image
        await MainActor.run {
            self.mainView.mainImage.image = image
        }
    }
    
    override func setNavigationController() {
        super.setNavigationController()
        setBackButton(type: .pop)
        let image = DSKitAsset.Assets.squareMore.image
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, menu: reviseButtonTapped())
        navigationItem.rightBarButtonItem?.tintColor = .labelStrong
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
        let image = DSKitAsset.Assets.bell.image
        let deletealarm = UIAction(title: "알람 끄기", image: image) { [weak self] _ in
            guard let self = self else { return }
            self.showAlertMessage(title: "알람을 끄시겠습니까?", message: nil, button: "확인", cancel: "취소") { _ in

                self.viewModel.deleteAlarm()

                self.navigationController?.popViewController(animated: true) {
                    self.passPreVC?()
                }
            }
            
        }
        let trashImage = DSKitAsset.Assets.trash.image.withRenderingMode(.alwaysTemplate)
        let quit = UIAction(title: "작심 그만두기", image: trashImage, attributes: .destructive) { [weak self]_ in
            guard let self = self else { return }
            self.showAlertMessage(title: "해당 작심을 그만두실 건가요?", message: "기존에 저장한 데이터들은 사라집니다.", button: "확인", cancel: "취소") { _ in

                self.viewModel.deleteJacsim()
                self.navigationController?.popViewController(animated: true) {
                    self.passPreVC?()
                }
            }
           
        }
        
        var items: [UIMenuElement] = []
        if self.viewModel.currentTask.alarm != nil {
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
        return dayViewData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDetailCollectionViewCell
        else { return UICollectionViewCell() }

        cell.layer.borderWidth = Constant.Design.borderWidth
        cell.layer.cornerRadius = Constant.Design.cornerRadius
        cell.layer.borderColor = .backgroundNormal

        guard dayViewData.indices.contains(indexPath.item) else { return cell }
        let data = dayViewData[indexPath.item]
        let dateText = DateFormatType.toString(data.date, to: .fullWithoutYear)

        cell.dateLabel.text = dateText
        cell.certifiedMemo.text = data.memo
        cell.certifiedImageView.image = nil

        Task { [weak self, weak cell] in
            let image = await self?.documentManager.loadImage(fileName: data.imageIdentifier) ?? DSKitAsset.Assets.jacsim.image
            await MainActor.run {
                cell?.certifiedImageView.image = image
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let task = self.viewModel.currentTask
        guard let cell = collectionView.cellForItem(at: indexPath) as? TaskDetailCollectionViewCell else { return }
        guard dayViewData.indices.contains(indexPath.item) else { return }
        let data = dayViewData[indexPath.item]

        let vc = TaskUpdateViewController()

        let dateText = DateFormatType.toString(data.date, to: .fullWithoutYear)
        vc.title = dateText + "의 작심"
        guard DateFormatType.toString(Date(), to: .fullWithoutYear) == dateText else {
            showAlertMessage(title: "작심 인증하기", message: "인증 날짜가 아닙니다.\n확인해주세요!", button: "확인")
            return
        }
        
        if !task.memoList[indexPath.item].check {
            vc.dateText = cell.dateLabel.text
            vc.task = task
            //vc.viewModel.task.value = task
            vc.index = indexPath.item
            //vc.viewModel.memoList.value = task.memoList[indexPath.item]
            self.transitionViewController(viewController: vc, transitionStyle: .push)
        } else {
            vc.dateText = cell.dateLabel.text
            vc.task = task
            vc.index = indexPath.item
            vc.mainView.memoTextfield.text = task.memoList[indexPath.item].memo
            vc.mainView.memoCountLabel.text = "\(task.memoList[indexPath.item].memo.count)/20"
            Task { [weak self, weak vc] in
                let image = await self?.documentManager.loadImage(fileName: data.imageIdentifier) ?? DSKitAsset.Assets.jacsim.image
                await MainActor.run {
                    vc?.mainView.certifyImageView.image = image
                }
            }
            self.transitionViewController(viewController: vc, transitionStyle: .push)
        }
    }
    
    
}
