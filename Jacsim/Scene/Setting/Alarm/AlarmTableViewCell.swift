//
//  AlarmTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/23.
//

import UIKit

class AlarmTableViewCell : BaseTableViewCell {
    
    let repository = JacsimRepository()
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    let meridiumLabel = UILabel().then {
        $0.text = "오전"
        $0.font = .systemFont(ofSize: 24)
        $0.textColor = .label
    }
    
    let timeLabel = UILabel().then {
        $0.text = "88:88"
        $0.font = .systemFont(ofSize: 40)
        $0.textColor = .label
    }
    
    let alertSwitch = UISwitch().then {
        $0.isOn = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        alertSwitch.addTarget(self, action: #selector(alarmSwitchValueChanged(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        [meridiumLabel, timeLabel, alertSwitch].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        meridiumLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(12)
            make.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(meridiumLabel.snp.trailing)
        }
        
        alertSwitch.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-24)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(24)
        }
    }
    
    @objc func alarmSwitchValueChanged(_ sender: UISwitch) {
        guard let data = UserDefaults.standard.value(forKey: "alarms") as? Data,
              var alarms = try? PropertyListDecoder().decode([Alarm].self, from: data) else { return }
        
        alarms[sender.tag].isOn = sender.isOn
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alarms), forKey: "alarms")
        
        if sender.isOn {
            
            userNotificationCenter.sendNotificationRequest(by: alarms[sender.tag])
            
        } else {
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alarms[sender.tag].id])
        }
        
    }
    
}
