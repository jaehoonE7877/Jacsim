//
//  SettingViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/22.
//

import UIKit
import MessageUI

import AcknowList
final class SettingViewController: BaseViewController {
    
    //MARK: Property
    lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = 44
        $0.separatorInset = .zero
        $0.backgroundColor = Constant.BaseColor.backgroundColor
        $0.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
    }
    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        view.backgroundColor = Constant.BaseColor.backgroundColor
        self.view.addSubview(tableView)
    }
    
    override func setConstraint() {
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.width.equalTo(view).multipliedBy(0.88)
            make.centerX.equalToSuperview()
        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.backgroundColor = Constant.BaseColor.backgroundColor
        
        if indexPath.row == 4 {
            
            cell.pushImage.removeFromSuperview()
            
            cell.versionLabel.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(cell.snp.trailing).offset(-12)
            }
        }
        cell.titleLabel.text = SettingModel.allCases[indexPath.row].title
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            switch indexPath.row {
            case 0:
                let vc = AlarmViewController()
                self.transitionViewController(viewController: vc, transitionStyle: .push)
            case 1:
                showAlertMessage(title: "업데이트 예정입니다.", button: "확인")
            case 2:
                sendMail()
            case 3:
                if let appstoreUrl = URL(string: "https://apps.apple.com/app/id6443532893}") {
                    var urlComp = URLComponents(url: appstoreUrl, resolvingAgainstBaseURL: false)
                    urlComp?.queryItems = [
                        URLQueryItem(name: "action", value: "write-review")
                    ]
                    guard let reviewUrl = urlComp?.url else {
                        return
                    }
                    UIApplication.shared.open(reviewUrl, options: [:], completionHandler: nil)
                }
            case 4:
                return
            case 5:
                guard let url = Bundle.main.url(forResource: "Package", withExtension: "resolved"),
                             let data = try? Data(contentsOf: url),
                             let acknowList = try? AcknowPackageDecoder().decode(from: data) else {
                           return
                       }
                
                let vc = AcknowListViewController(acknowledgements: acknowList.acknowledgements, style: .insetGrouped)
                navigationController?.pushViewController(vc, animated: true)
            default:
                return
            }
    }
}

// Mail문의
extension SettingViewController : MFMailComposeViewControllerDelegate {
    
    private func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            //메일 보내기
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["sjh7877@naver.com"])
            mail.setSubject("작심 문의사항 -")
            mail.mailComposeDelegate = self   //
            self.present(mail, animated: true)
            
        } else {
            
            showAlertMessage(title: "메일 등록을 해주시거나 sjh7877@naver.com으로 문의주세요.", button: "확인")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // mail view가 떴을때 정상적으로 보내졌다. 실패했다고 Toast 띄워줄 수 있음
        // 어떤식으로 대응 할 수 있을지 생각해보기
        switch result {
        case .failed: //사용자가 실패
            view.makeToast("메일 전송에 실패했습니다.", duration: 1, position: .center, title: nil, image: nil, completion: nil)
        case .cancelled:
            view.makeToast("메일 전송을 취소했습니다.", duration: 1, position: .center, title: nil, image: nil, completion: nil)
        case .saved: //임시저장
            view.makeToast("메일을 임시 저장했습니다.", duration: 1, position: .center, title: nil, image: nil, completion: nil)
        case .sent: // 보내짐
            view.makeToast("메일이 정상적으로 발송됐습니다.", duration: 1, position: .center, title: nil, image: nil, completion: nil)
        @unknown default:
            fatalError()
        }
        
        controller.dismiss(animated: true)
    }
}
