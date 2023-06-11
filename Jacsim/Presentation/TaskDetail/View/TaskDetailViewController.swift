//
//  TaskDetailViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class TaskDetailViewController: BaseViewController {
    
    //MARK: -- Private Property
    private let viewModel: TaskDetailViewModel
    private let mainView = TaskDetailView()
    
    init(viewModel: TaskDetailViewModel) {
        self.viewModel = viewModel
        self.title = viewModel.jacsimTask.value.title
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
                
    }

    // MARK: Configure
    override func configure() {
        view.backgroundColor = Constant.BaseColor.backgroundColor
        mainView.startDateLabel.text = viewModel.jacsimTask.value.startDateStringFull
        mainView.endDateLabel.text = viewModel.jacsimTask.value.endDateStringFull
        
        mainView.alarmLabel.text = viewModel.showAlarm

        mainView.mainImage.image = viewModel.documentManager.loadImageFromDocument(fileName: <#T##String#>)
        
    }
    
    override func setNavigationController() {
        
        navigationController?.navigationBar.backItem?.backButtonTitle = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage.menu, menu: reviseButtonTapped())
        
        navigationController?.navigationBar.tintColor = Constant.BaseColor.textColor
    }
    
    private func reviseButtonTapped() -> UIMenu {
        
        let deleteAlarm = UIAction(title: "알람 끄기", image: UIImage.alarmDelete) { [weak self]_ in
            guard let self = self else { return }
            
            self.showAlertMessage(title: "알람을 끄시겠습니까?", message: nil, button: "확인", cancel: "취소") { _ in
                self.viewModel.jacsimAlarmDeleteRelay.accept(Void())
                self.mainView.alarmLabel.text = self.viewModel.showAlarm
            }
            
        }
        
        let quit = UIAction(title: "작심 그만두기", image: UIImage.trash , attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.showAlertMessage(title: "해당 작심을 그만두실 건가요?", message: "기존에 저장한 데이터들은 사라집니다.", button: "확인", cancel: "취소") { _ in
                self.viewModel.jacsimDeleteRelay.accept(Void())
            }
        }
        
        let items = viewModel.jacsimTask.value.alarm != nil ? [deleteAlarm, quit] : [quit]
        
        let menu = UIMenu(title: "", options: .displayInline, children: items)
        
        return menu
    }

    private func bind() {
        
        let input = TaskDetailViewModel.Input(viewWillAppear: self.rx.viewWillAppear)
        let output = self.viewModel.transform(input: input)
        
        output.fetchSuccess
            .drive(onNext: { [weak self] jacsim in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.mainView.collectionView.reloadData()
                    self.mainView.collectionView.scrollToItem(at: IndexPath(item: self.viewModel.scrollToCurrentDate, section: 0), at: .centeredHorizontally, animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        output.jacsimSuccess
            .drive(onNext: { [weak self] message in
                self?.mainView.successLabel.text = message
            })
            .disposed(by: disposeBag)
        
        output.jacsimDelete
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.jacsimAlarmDelete
            .drive(onNext: {
                
            })
    }

}
//MARK: CollectionView Delegate, Datasource
extension TaskDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (Calendar.current.dateComponents([.day],
                                                from: viewModel.jacsimTask.value.startDate,
                                                to: viewModel.jacsimTask.value.endDate).day ?? 1) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDetailCollectionViewCell
        else { return UICollectionViewCell() }


        let dateText = DateFormatType.toString(dayArray[indexPath.item], to: .fullWithoutYear)
        guard let objectId = task?.id else { return UICollectionViewCell() }
        cell.dateLabel.text = dateText
        cell.certifiedMemo.text = task?.memoList[indexPath.row].memo

        guard let image = loadImageFromDocument(fileName: "\(objectId)_\(dateText).jpg") else { return UICollectionViewCell()}
        cell.certifiedImageView.image = image

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? TaskDetailCollectionViewCell else { return }

        let task = viewModel.jacsimTask.value
        
        let vc = TaskUpdateViewController()

        guard viewModel.checkIsToday(indexPath: indexPath) else {
            showAlertMessage(title: "작심 인증하기", message: "인증 날짜가 아닙니다.\n확인해주세요!", button: "확인")
            return
        }
        
        if task.memoList[indexPath.item].check == false {
            vc.dateText = cell.dateLabel.text
            vc.task = task
            vc.index = indexPath.item
            self.transitionViewController(viewController: vc, transitionStyle: .push)
        } else { // 기존 작성 수정
            vc.dateText = cell.dateLabel.text
            vc.task = task
            vc.index = indexPath.item
            vc.mainView.memoTextfield.text = task.memoList[indexPath.item].memo
            vc.mainView.memoCountLabel.text = "\(task.memoList[indexPath.item].memo.count)/20"
            vc.mainView.certifyImageView.image = viewModel.fetchTodayImage(index: indexPath.item)
            self.transitionViewController(viewController: vc, transitionStyle: .push)
        }
    }
    
    
}

extension TaskDetailViewController {
    // MARK: Delegate
    private func configureDelegate() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.collectionView.register(TaskDetailCollectionViewCell.self, forCellWithReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier)
        mainView.collectionView.showsHorizontalScrollIndicator = false
    }
}
