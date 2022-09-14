//
//  HomeViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import FSCalendar
import Floaty

final class HomeViewController: BaseViewController {
    
    // MARK: Label, FSCalendar, TableView
    let nicknameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.text = "Nickname의 챌린지"
    }
    
    lazy var calendar = FSCalendar(frame: .zero).then {
        $0.delegate = self
        $0.dataSource = self
        $0.appearance.headerMinimumDissolvedAlpha = 0.0
        $0.headerHeight = 32
        $0.appearance.subtitleOffset = CGPoint(x: 0, y: 6)
        $0.locale = Locale(identifier: "ko_KR")
        $0.appearance.headerDateFormat = "yyyy년 M월"
        $0.backgroundColor = .systemBackground
    }
    
    lazy var infoButton = UIButton().then {
        $0.setImage(UIImage(systemName: "questionmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
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
    
    let formatter = DateFormatter().then{
        $0.dateFormat = "yyyyMMdd"
    }
    
    let floaty = Floaty()
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = .systemBackground
    }
    
    
    override func configure() {
        
        [nicknameLabel, calendar, tableView, infoButton, floaty].forEach { view.addSubview($0) }
        layoutFAB()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(moveToSetting))
        navigationItem.rightBarButtonItem?.tintColor = Constant.BaseColor.buttonColor
        
        calendarSwipeEvent()
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    override func setConstraint() {
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.snp.leading).offset(16)
        }
        // 달력 높이 비율로 잡기
        calendar.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(UIScreen.main.bounds.height / 2.5)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(4)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        infoButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.top).offset(8)
            make.trailing.equalTo(tableView.snp.trailing).offset(-12)
        }
    }
    // MARK: Floaty Button Customize
    private func layoutFAB(){
        floaty.addItem("새로운 작심", icon: UIImage(systemName: "square.and.pencil")) { item in
            self.transitionViewController(viewController: NewTaskViewController(), transitionStyle: .presentFullNavigation)
        }
        
        floaty.addItem("이전 작심", icon: UIImage(systemName: "checkmark.square")) { item in
            self.transitionViewController(viewController: DoneTaskViewController(), transitionStyle: .presentFullNavigation)
        }
    }
    // right navi item
    @objc func moveToSetting(){
        
    }
    
    private func calendarSwipeEvent(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeUp.direction = .up
        self.calendar.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeDown.direction = .down
        self.calendar.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipeEvent(_ swipe: UISwipeGestureRecognizer){
        if swipe.direction == .up{
            calendar.scope = .week
        } else if swipe.direction == .down {
            calendar.scope = .month
        }
    }
    
    @objc func infoButtonTapped(){
        showAlertMessage(title: "작심한 일은...", message: "좋은 습관을 만들어주기 위해\n최대 5개의 목표를 다루고 있습니다!", button: "확인")
    }
    
    
}
// MARK: TableView Delegate, Datasource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: JacsimHeaderView.reuseIdentifier) as? JacsimHeaderView else { return UIView() }
        
        headerView.headerLabel.text = "작심한 일"
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .clear
        
        return cell
    }
    
    
}
// MARK: FSCalendar Delegate, Datasource
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.removeConstraint(calendar.constraints.last!)
        calendar.snp.remakeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    // 오늘부터만 선택 가능하도록 하는 기능
//    func minimumDate(for calendar: FSCalendar) -> Date {
//        return Date()
//    }
    
    // 다음 달 특정일이 눌렸을 때 다음달로 페이지 자동 이동
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
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
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        switch formatter.string(from: date) {
        case formatter.string(from: Date()):
            return "2/5"
        default:
            return nil
        }
    }
}
