//
//  AlarmViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/23.
//

import UIKit
import NotificationCenter
import UserNotifications

class AlarmViewController: BaseViewController {
    
    let repository = JacsimRepository()
    
    var alarms: [Alarm] = []
    let userNotificationCenter = UNUserNotificationCenter.current()
        
    lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.rowHeight = 64
        $0.backgroundColor = .white
        $0.delegate = self
        $0.dataSource = self
        $0.sectionHeaderHeight = 64
        $0.register(JacsimHeaderView.self, forHeaderFooterViewReuseIdentifier: JacsimHeaderView.reuseIdentifier)
        $0.register(AlarmTableViewCell.self, forCellReuseIdentifier: AlarmTableViewCell.reuseIdentifier)
    }
    
    //MARK: View LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "작심 알람"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alarms = alarmList()
    }
    
    override func configure() {
        view.addSubview(tableView)
        
    }
    
    override func setConstraint() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setNavigationController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addAlertButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .systemMint
    }
    
    @objc func addAlertButtonTapped(){
        
        let vc = AddAlarmViewController()
        vc.delegate = { [weak self] date in
            guard let self = self else { return }
            var alarmList = self.alarmList()
            let newAlarm = Alarm(date: date, isOn: true)
            alarmList.append(newAlarm)
            alarmList.sort { $0.date < $1.date }
            self.alarms = alarmList
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alarms), forKey: "alarms")
            
            self.userNotificationCenter.sendNotificationRequest(by: newAlarm)
            
            self.tableView.reloadData()
        }
        self.transitionViewController(viewController: vc, transitionStyle: .presentNavigation)
        
    }
    
    func alarmList() -> [Alarm] {
        guard let data = UserDefaults.standard.value(forKey: "alarms") as? Data,
              let alarms = try? PropertyListDecoder().decode([Alarm].self, from: data) else {
            return [] }
        return alarms
    }
    
}


extension AlarmViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: JacsimHeaderView.reuseIdentifier) as? JacsimHeaderView else { return UIView() }
        headerView.foldButton = UIButton(frame: .null)
        headerView.foldImage = UIImageView(frame: .null)
        headerView.headerLabel.text = "작심이 미완성 됐을 때 울립니다!"
        headerView.headerLabel.font = .boldSystemFont(ofSize: 24)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.reuseIdentifier, for: indexPath) as? AlarmTableViewCell else { return UITableViewCell() }
        
        cell.alertSwitch.isOn = alarms[indexPath.row].isOn
        cell.timeLabel.text = alarms[indexPath.row].time
        cell.meridiumLabel.text = alarms[indexPath.row].meridiem
        cell.alertSwitch.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.alarms.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alarms), forKey: "alarms")
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alarms[indexPath.row].id])
            self.tableView.reloadData()
        default:
            break
        }
    }
    
}
