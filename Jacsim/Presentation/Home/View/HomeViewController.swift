//
//  HomeViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import FSCalendar
import Floaty
import RealmSwift

final class HomeViewController: BaseViewController {
        
    //let repository = JacsimRepository()
    
    private let viewModel = HomeViewModel()
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
    
    private lazy var infoButton = UIButton().then {
        $0.setImage(UIImage.question, for: .normal)
        $0.tintColor = Constant.BaseColor.textColor
    }
    
    private lazy var sortButton = UIButton().then {
        $0.setImage(UIImage.sort, for: .normal)
        $0.tintColor = Constant.BaseColor.textColor
    }
    
    private lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(JacsimHeaderView.self, forHeaderFooterViewReuseIdentifier: JacsimHeaderView.reuseIdentifier)
        $0.register(JacsimTableViewCell.self, forCellReuseIdentifier: JacsimTableViewCell.reuseIdentifier)
        $0.rowHeight = 60
        $0.sectionFooterHeight = 0
        $0.sectionHeaderHeight = 40
        $0.backgroundColor = Constant.BaseColor.backgroundColor
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
        $0.buttonColor = Constant.BaseColor.floatyColor!
        $0.itemTitleColor = Constant.BaseColor.textColor!
        $0.size = 48
        $0.fabDelegate = self
    }
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBinding()
        fsCalendar.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fsCalendar.setCurrentPage(Date(), animated: false)
        fsCalendar.select(Date(), scrollToDate: false)
        
        viewModel.fetch()
        viewModel.checkIsDone()
   
    }
    
    private func setBinding() {
        
        viewModel.tasks.bind { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    // MARK: Set UI, Constraints
    override func configure() {
        
        [fsCalendar, tableView, infoButton, sortButton, floaty].forEach { view.addSubview($0) }
        
        setFSCalendar()
        setFloatyButton()
        
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        view.addGestureRecognizer(self.scopeGesture)
        view.backgroundColor = Constant.BaseColor.backgroundColor
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
       
    }
    
    override func setConstraint() {
        
        // 달력 높이 비율로 잡기
        fsCalendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.width.equalTo(view).multipliedBy(0.94)
            make.centerX.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2.5)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(fsCalendar.snp.bottom)
            make.width.equalTo(view).multipliedBy(0.88)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        infoButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.top).offset(8)
            make.trailing.equalTo(tableView.snp.trailing)
        }
        
        sortButton.snp.makeConstraints { make in
            make.top.equalTo(infoButton.snp.top)
            make.trailing.equalTo(infoButton.snp.leading).offset(-8)
            make.centerY.equalTo(infoButton)
        }
    }
    
    override func setNavigationController() {
        title = "작심"
        navigationController?.navigationBar.tintColor = Constant.BaseColor.textColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .gear, style: .plain, target: self, action: #selector(moveToSetting))
    }
    
    
    // MARK: Floaty Button Customize
    private func setFloatyButton(){
        
        floaty.plusColor = Constant.BaseColor.textColor!
        floaty.itemButtonColor = Constant.BaseColor.floatyColor!
        floaty.itemTitleColor = Constant.BaseColor.textColor!
        floaty.tintColor = Constant.BaseColor.textColor

        floaty.addItem("새로운 작심", icon: UIImage.write) { item in
            self.transitionViewController(viewController: NewTaskViewController(), transitionStyle: .presentFullNavigation)
        }
                       
        floaty.addItem("작심 모아보기", icon: UIImage.list) { item in
            self.transitionViewController(viewController: AllTaskViewController(), transitionStyle: .presentFullNavigation)
        }
        
    }

    
    // MARK: FSCalendar Customize
    private func setFSCalendar(){
        fsCalendar.backgroundColor = Constant.BaseColor.backgroundColor
        fsCalendar.appearance.headerTitleColor = Constant.BaseColor.textColor
        fsCalendar.appearance.headerTitleFont = UIFont.gothic(style: .Light, size: 20)
        fsCalendar.appearance.weekdayFont = UIFont.gothic(style: .Light, size: 16)
        fsCalendar.appearance.titleFont = UIFont.gothic(style: .Light, size: 16)
        
        fsCalendar.appearance.weekdayTextColor = Constant.BaseColor.textColor
        fsCalendar.appearance.titleDefaultColor = Constant.BaseColor.textColor
        
        fsCalendar.appearance.todayColor = Constant.BaseColor.buttonColor

        fsCalendar.appearance.todaySelectionColor = .none
       
        fsCalendar.appearance.selectionColor = Constant.BaseColor.buttonColor
        
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

// MARK: TableView Delegate, Datasource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: JacsimHeaderView.reuseIdentifier) as? JacsimHeaderView else { return UIView() }
        headerView.foldButton = UIButton(frame: .null)
        headerView.foldImage = UIImageView(frame: .null)
        headerView.headerLabel.text = "작심한 일"
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: JacsimTableViewCell.reuseIdentifier, for: indexPath) as? JacsimTableViewCell else { return UITableViewCell() }
        
        cell.setCellStyle(title: viewModel.tasks.value[indexPath.row].title,
                          alarm: viewModel.tasks.value[indexPath.row].alarm)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = TaskDetailViewController()
        //객체지향적으로 bad
        // 캡슐화()
        vc.viewModel.task.value = viewModel.tasks.value[indexPath.row]
        vc.title = viewModel.tasks.value[indexPath.item].title
        
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
