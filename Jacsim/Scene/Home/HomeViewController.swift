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
        
    let repository = JacsimRepository()
    
    var dayArray: [Date] = []
    // MARK: Property
    
    lazy var fsCalendar = FSCalendar(frame: .zero).then {
        $0.delegate = self
        $0.dataSource = self
        $0.appearance.headerMinimumDissolvedAlpha = 0.0
        $0.locale = Locale(identifier: "ko_KR")
        $0.headerHeight = 40
        $0.appearance.subtitleOffset = CGPoint(x: 0, y: 6)
        $0.appearance.headerDateFormat = "yyyy년 M월"
        $0.clipsToBounds = true
    }
    
    lazy var infoButton = UIButton().then {
        $0.setImage(UIImage(systemName: "questionmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        $0.tintColor = .darkGray
    }
    
    lazy var sortButton = UIButton().then {
        $0.setImage(UIImage(systemName: "text.justify", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        $0.tintColor = .darkGray
    }
    
    lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(JacsimHeaderView.self, forHeaderFooterViewReuseIdentifier: JacsimHeaderView.reuseIdentifier)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        $0.rowHeight = 72
        $0.sectionFooterHeight = 0
        $0.sectionHeaderHeight = 40
        $0.backgroundColor = .clear
    }
    
    
    lazy var scopeGesture: UIPanGestureRecognizer = { [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.fsCalendar, action: #selector(self.fsCalendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    let floaty = Floaty()
    
    var tasks: Results<UserJacsim>!{
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        fsCalendar.reloadData()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tasks = repository.fetchRealm()
        
        fsCalendar.reloadData()
        
    }
    
    // MARK: Set UI, Constraints
    override func configure() {
        
        [fsCalendar, tableView, infoButton, sortButton, floaty].forEach { view.addSubview($0) }
        setFloatyButton()
        
        setFSCalendar()
        
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.fsCalendar.scope = .month
    }
    
    override func setConstraint() {
        
        // 달력 높이 비율로 잡기
        fsCalendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(UIScreen.main.bounds.height / 2.5)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(fsCalendar.snp.bottom)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(4)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        infoButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.top).offset(8)
            make.trailing.equalTo(tableView.snp.trailing).offset(-12)
        }
        
        sortButton.snp.makeConstraints { make in
            make.top.equalTo(infoButton.snp.top)
            make.trailing.equalTo(infoButton.snp.leading).offset(-8)
            make.centerY.equalTo(infoButton)
        }
    }
    
    override func setNavigationController() {
        self.title = "Nickname의 작심일지"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(moveToSetting))
        navigationItem.rightBarButtonItem?.tintColor = .systemMint
    }
    
    
    // MARK: Floaty Button Customize
    private func setFloatyButton(){
        floaty.paddingY = UIScreen.main.bounds.height / 12
        floaty.buttonColor = .systemMint
        floaty.hasShadow = true
        floaty.itemTitleColor = .systemGray6
        
        
        floaty.addItem("새로운 작심", icon: UIImage(systemName: "square.and.pencil")) { item in
            
            self.transitionViewController(viewController: NewTaskViewController(), transitionStyle: .presentFullNavigation)
        }
        
        floaty.addItem("이전 작심", icon: UIImage(systemName: "checkmark.square")) { item in
            self.transitionViewController(viewController: DoneTaskViewController(), transitionStyle: .presentFullNavigation)
        }
        
    }
    
    // MARK: FSCalendar Customize
    private func setFSCalendar(){
        fsCalendar.backgroundColor = .systemBackground
        fsCalendar.appearance.headerTitleColor = .black
        fsCalendar.appearance.weekdayTextColor = .black
        fsCalendar.appearance.todayColor = .clear
        fsCalendar.appearance.todaySelectionColor = .none
        fsCalendar.appearance.selectionColor = .systemMint
        fsCalendar.appearance.titleTodayColor = .systemMint
        fsCalendar.appearance.headerTitleFont = .boldSystemFont(ofSize: 16)
    }
    
    
    @objc func moveToSetting(){
        
    }
    
    @objc func infoButtonTapped(){
        showAlertMessage(title: "작심한 일은...", message: "좋은 습관을 만들어주기 위해\n최대 5개의 목표를 다루고 있습니다!", button: "확인")
    }
    
    @objc func sortButtonTapped(){
        tasks = repository.fetchRealm()
    }
    
}

// MARK: TableView Delegate, Datasource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: JacsimHeaderView.reuseIdentifier) as? JacsimHeaderView else { return UIView() }
        
        headerView.headerLabel.text = "작심한 일"
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .clear
        cell.titleLabel.text = tasks?[indexPath.row].title
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = TaskDetailViewController()
        vc.task = tasks?[indexPath.item]
        self.navigationItem.backButtonTitle = ""
        self.transitionViewController(viewController: vc, transitionStyle: .presentFullNavigation)
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
        
        tasks = repository.fetchDate(date: date)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        switch formatter.string(from: date) {
        case formatter.string(from: Date()):
            return "오늘"
        default:
            return nil
        }
    }
    
    
}
