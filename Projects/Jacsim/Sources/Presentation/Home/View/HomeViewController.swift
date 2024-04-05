//
//  HomeViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import DSKit

import FSCalendar
import Floaty
import RealmSwift
import RxCocoa
import RxSwift

final class HomeViewController: BaseViewController {
            
    // MARK: Property
    
    private lazy var fsCalendar = FSCalendar(frame: .zero).then {
        $0.delegate = self
        $0.dataSource = self
        $0.appearance.headerMinimumDissolvedAlpha = 0.0
        $0.locale = Locale(identifier: "ko_KR")
        $0.headerHeight = 40
        $0.appearance.subtitleOffset = CGPoint(x: 0, y: 6)
        $0.appearance.headerDateFormat = "yyyy년 M월"
        $0.scope = .month
        $0.clipsToBounds = true
    }

    private lazy var tableView = UITableView(frame: CGRect.zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(JacsimHeaderView.self, forHeaderFooterViewReuseIdentifier: JacsimHeaderView.reuseIdentifier)
        $0.register(JacsimTableViewCell.self, forCellReuseIdentifier: JacsimTableViewCell.reuseIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.sectionFooterHeight = 0
        $0.sectionHeaderTopPadding = 0.0
        $0.backgroundColor = .backgroundNormal
        $0.separatorStyle = UITableViewCell.SeparatorStyle.none
        $0.panGestureRecognizer.require(toFail: self.scopeGesture)
    }
    
    
    private lazy var scopeGesture: UIPanGestureRecognizer = { [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.fsCalendar, action: #selector(self.fsCalendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    private lazy var floaty = Floaty().then {
        $0.paddingY = UIScreen.main.bounds.height / 12
        $0.buttonColor = .primaryNormal
        $0.itemTitleColor = .labelNormal
        $0.size = 48
        $0.fabDelegate = self
    }
    
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: View LifeCycle
    override func loadView() {
        super.loadView()
        setBinding()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        fsCalendar.setCurrentPage(Date(), animated: false)
        fsCalendar.select(Date(), scrollToDate: false)
        viewModel.fetch()
        viewModel.checkIsDone()
    }
    
    private func setBinding() {
        viewModel.tasks
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { _self, jacsims in
                _self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Set UI, Constraints
    private func setView() {
        view.addSubviews([fsCalendar, tableView, floaty])
        
        // 달력 높이 비율로 잡기
        fsCalendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2.5)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(fsCalendar.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
                
        setFSCalendar()
        setFloatyButton()
        
        view.addGestureRecognizer(self.scopeGesture)
        view.backgroundColor = .backgroundNormal
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func setNavigationController() {
        super.setNavigationController()
        title = "작심"
        navigationController?.navigationBar.tintColor = .labelNormal
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .gear, style: .plain, target: self, action: #selector(moveToSetting))
        navigationItem.titleView?.tintColor = .labelNormal
    }
    
    
// MARK: - Floaty Button Customize
    private func setFloatyButton(){
        
        floaty.plusColor = .labelNormal
        floaty.itemButtonColor = .primaryNormal
        floaty.itemTitleColor = .labelNormal
        floaty.tintColor = .labelNormal
        floaty.itemImageColor = .labelNormal
        
        floaty.addItem("새로운 작심", icon: DSKitAsset.Assets.pencil.image.withRenderingMode(.alwaysTemplate)) { item in
            self.transitionViewController(viewController: NewTaskViewController(), transitionStyle: .presentFullNavigation)
        }
                       
        floaty.addItem("작심 모아보기", icon: DSKitAsset.Assets.list.image.withRenderingMode(.alwaysTemplate)) { item in
            self.transitionViewController(viewController: AllTaskViewController(), transitionStyle: .presentFullNavigation)
        }
        
    }

    
    // MARK: FSCalendar Customize
    private func setFSCalendar(){
        fsCalendar.backgroundColor = .backgroundNormal
        fsCalendar.appearance.headerTitleColor = DSKitAsset.Colors.text.color
        fsCalendar.appearance.headerTitleFont = UIFont.pretendardSemiBold(size: 20)
        fsCalendar.appearance.weekdayFont = UIFont.pretendardMedium(size: 16)
        fsCalendar.appearance.titleFont = UIFont.pretendardMedium(size: 16)
        
        fsCalendar.appearance.weekdayTextColor = .labelNormal
        fsCalendar.appearance.titleDefaultColor = .labelNormal
        
        fsCalendar.appearance.todayColor = .primaryNormal

        fsCalendar.appearance.todaySelectionColor = .none
       
        fsCalendar.appearance.selectionColor = .primaryNormal
        
    }
    
    
    @objc func moveToSetting(){
        let vc = SettingViewController()
        self.transitionViewController(viewController: vc, transitionStyle: .push)
    }
    
    @objc func infoButtonTapped(){
        showAlertMessage(
            title: "작심한 일은...",
            message: """
            좋은 습관을 만들어주기 위해
            최대 5개의 목표를 다루고 있습니다!
            """,
            button: "확인")
    }
    
    @objc func sortButtonTapped(){
        
        fsCalendar.setCurrentPage(Date(), animated: true)
        fsCalendar.select(Date(), scrollToDate: true)
        //fsCalendar(fsCalendar, didSelect: fsCalendar.today ?? Date() , at: .current)
        //tasks = repository.fetchRealm()
        viewModel.fetch()
        
    }
    
}

//MARK: - TableView Delegate, Datasource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: JacsimHeaderView.reuseIdentifier) as? JacsimHeaderView else { return UIView() }
        
        headerView.infoButton.rx.tap
            .asDriverOnErrorJustComplete()
            .drive(with: self) { _self, _ in
                _self.infoButtonTapped()
            }
            .disposed(by: headerView.disposeBag)
       
        headerView.sortButton.rx.tap
            .asDriverOnErrorJustComplete()
            .drive(with: self) { _self, _ in
                _self.sortButtonTapped()
            }
            .disposed(by: headerView.disposeBag)
                
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JacsimTableViewCell.reuseIdentifier, for: indexPath) as? JacsimTableViewCell else { return UITableViewCell() }
        
        cell.setCellStyle(title: viewModel.tasks.value[indexPath.row].title,
                          alarm: viewModel.tasks.value[indexPath.row].alarm)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewModel = TaskDetailViewModel(task: viewModel.tasks.value[indexPath.item])
        
        let vc = TaskDetailViewController(viewModel: viewModel)
        //객체지향적으로 bad
        // 캡슐화()
//        vc.viewModel.task.value = viewModel.tasks.value[indexPath.row]
        vc.title = self.viewModel.tasks.value[indexPath.item].title
//        vc.task = viewModel.tasks.value[indexPath.item]
        self.transitionViewController(viewController: vc, transitionStyle: .push)
    }
    
}
// FsCalendar Swipe gesture
extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.fsCalendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            @unknown default:
                fatalError()
            }
        }
        return shouldBegin
    }
}



// MARK: FSCalendar Delegate, Datasource
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        viewModel.fetchDate(date: date)
        
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        
        switch DateFormatType.toString(date, to: .full) {
        case DateFormatType.toString(Date(), to: .full):
            return "오늘"
        default:
            return nil
        }
    }
    
}

extension HomeViewController: FloatyDelegate {
    
    func floatyWillOpen(_ floaty: Floaty) {
        if  viewModel.fetchIsNotDone() >= 5 {
            floaty.items[0].isHidden = true
        } else {
            floaty.items[0].isHidden = false
        }
    }
}
