//
//  NewTaskViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import Photos
import PhotosUI

import CropViewController

final class NewTaskViewController: BaseViewController {
    
    let repository = JacsimRepository()
    
    var alarm: Date?
    
    let timeFormatter = DateFormatter()
    
    //MARK: Property
    
    let mainView = NewTaskView()
    
    lazy var imagePicker: UIImagePickerController = {
            let view = UIImagePickerController()
            view.delegate = self
            return view
    }()
    
    let configuration: PHPickerConfiguration = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        return configuration
    }()
    
    lazy var phPicker: PHPickerViewController = {
        let view = PHPickerViewController(configuration: configuration)
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        self.view = mainView
    }
    
    var someTextField: UITextField?

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //print("Realm is located at:", repository.localRealm.configuration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func configure() {
        
        view.backgroundColor = Constant.BaseColor.backgroundColor

        [mainView.newTaskTitleTextfield, mainView.startDateTextField, mainView.endDateTextField, mainView.successTextField].forEach { $0.delegate = self }
        [mainView.newTaskTitleTextfield, mainView.startDateTextField, mainView.endDateTextField].forEach { $0.returnKeyType = .done }
        
        tapGesture()
        
        mainView.imageAddButton.menu = addImageButtonTapped()
        
        mainView.startDateTextField.setInputViewDatePicker(target: self, selector: #selector(startDateTextFieldTapped))
        mainView.endDateTextField.setInputViewDatePicker(target: self, selector: #selector(endDateTextFieldTapped))
        
        mainView.alarmSwitch.addTarget(self, action: #selector(alarmSwitchTapped), for: .valueChanged)
    }
    
    override func setNavigationController() {
        self.title = "새로운 작심"
        
        navigationController?.navigationBar.tintColor = Constant.BaseColor.textColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Constant.BaseColor.backgroundColor
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func tapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapEndEditing))
        view.addGestureRecognizer(tap)
    }
    
    //MARK: UIMenu
    private func addImageButtonTapped() -> UIMenu {
        
        let camera = UIAction(title: "카메라", image: UIImage(systemName: "camera")) { [weak self]_ in
            guard let self = self else { return }
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self.showAlertMessage(title: "카메라 사용이 불가합니다.", button: "확인")
                    return
                }
                DispatchQueue.main.async {
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true)
                }
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    guard let self = self else { return }
                    if granted {
                        DispatchQueue.main.async {
                            self.imagePicker.sourceType = .camera
                            self.imagePicker.allowsEditing = true
                            self.present(self.imagePicker, animated: true)
                        }
                    }
                }
            default:
                self.showAlertSetting(message: "작심이(가) 카메라 접근 허용되어 있지 않습니다. \r\n 설정화면으로 가시겠습니까?")
            }
            
        }
        let gallery = UIAction(title: "갤러리", image: UIImage(systemName: "photo.on.rectangle")) {[weak self] _ in
            guard let self = self else { return }
            self.present(self.phPicker, animated: true)
        }
        let menu = UIMenu(title: "사진의 경로를 정해주세요.", options: .displayInline, children: [gallery,camera])
       
        return menu
    }
    
    @objc func tapEndEditing(){
        view.endEditing(true)
    }
    
    @objc func backButtonTapped(){
        self.dismiss(animated: true)
    }
    // 수정 화면에서 알람이 등록되어 있을 때, 알림이 없을 때로 나눠서 생각해보기
    @objc func alarmSwitchTapped(){
        
        if !mainView.alarmSwitch.isOn {
            
            mainView.alarmTimeLabel.text = nil
            return
            
        } else {
            
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("granted, but Error in notification permission:\(error.localizedDescription)")
                }
                
                if granted {
                    
                    DispatchQueue.main.async {
                        let vc = AlarmViewController()
                        
                        vc.completion = { date in
                            
                            guard let date = date else {
                                self.mainView.alarmSwitch.isOn = false
                                return
                            }
                            
                            self.formatter.dateFormat = "a hh:mm"
                            DispatchQueue.main.async {
                                self.mainView.alarmTimeLabel.text = self.formatter.string(from: date)
                            }
                        }
                        
                        self.present(vc, animated: true)
                    }
                    
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.mainView.alarmSwitch.isOn = false
                        self.showAlertSetting(message: "작심이(가) 알림 허용되어 있지 않습니다. \r\n '설정>개인정보 보호'에서 알림 설정을 허용으로 설정해주세요")
                    }
                    
                }
            }
        }
    }
    
    // MARK: Realm Create
    @objc func saveButtonTapped(){
        
        timeFormatter.dateFormat = "yyyy년 M월 d일 EEEE a hh:mm"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.timeZone = TimeZone(identifier: "ko_KR")
        
        if mainView.newTaskTitleTextfield.text == "" {
            view.makeToast("제목을 입력해주세요!", duration: 0.8, position: .center, title: nil, image: nil, style: .init()) { _ in
            }
            return
        } else if mainView.startDateTextField.text == "" {
            view.makeToast("시작일을 입력해주세요!", duration: 0.8, position: .center, title: nil, image: nil, style: .init()) { _ in
            }
            return
        } else if mainView.endDateTextField.text == "" {
            view.makeToast("종료일을 입력해주세요!", duration: 0.8, position: .center, title: nil, image: nil, style: .init()) { _ in
            }
            return
        }
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        guard let title = mainView.newTaskTitleTextfield.text else { return }
        //print(formatter.date(from: mainView.startDateTextField.text ?? ""))
        guard let startDate = formatter.date(from: mainView.startDateTextField.text ?? "") else { return }
        guard let endDate = formatter.date(from: mainView.endDateTextField.text ?? "") else { return }
        guard let success = Int(mainView.successTextField.text ?? "") else { return }
        if startDate - endDate > 0 {
            view.makeToast("종료일은 시작일보다 빠를 수 없습니다.", duration: 1.0, position: .center, title: nil, image: nil, style: .init()) { [weak self]_ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainView.endDateTextField.text = ""
                }
            }
            return
        } else {
            let days = calculateDays(startDate: startDate, endDate: endDate)
            if success > days || success <= 0 {
                view.makeToast("최소 성공 횟수는 작심 진행 일수 보다 많을 수 없습니다.", duration: 2.0, position: .center, title: nil, image: nil, style: .init()) { [weak self]_ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.mainView.successTextField.text = ""
                    }
                }
                return
            }
        }
        
        if let alarm = mainView.alarmTimeLabel.text {
            
            let valueA = "\(formatter.string(from: startDate)) \(alarm)"
            guard let fireDate = timeFormatter.date(from: valueA) else { return }
            print("\(fireDate): 알림 시작일")
            
            guard fireDate.timeIntervalSinceNow > 0 else {
                self.showAlertMessage(title: "알람 시간이 이미 지난 날짜 입니다", message: "알람을 다시 설정해주세요" ,button: "확인")
                return
            }
            
            let task = UserJacsim(title: title, startDate: startDate, endDate: endDate, success: success, alarm: fireDate)
            for _ in 0...calculateDays(startDate: startDate, endDate: endDate) - 1 {
                let certified = Certified(memo: "인증해주세요")
                task.memoList.append(certified)
            }
            
            guard let baseImage = UIImage(named: "jacsim") else { return }
            saveImageToDocument(fileName: "\(String(describing: task.id)).jpg", image: mainView.newTaskImageView.image ?? baseImage)
            repository.addJacsim(item: task)
            
            scheduleNotification(title: title, fireDate: fireDate)
           
            dismiss(animated: true)
        } else {
           
            let task = UserJacsim(title: title, startDate: startDate, endDate: endDate, success: success, alarm: nil)
            for _ in 0...calculateDays(startDate: startDate, endDate: endDate) - 1 {
                let certified = Certified(memo: "인증해주세요")
                task.memoList.append(certified)
            }
            
            guard let baseImage = UIImage(named: "jacsim") else { return }
            saveImageToDocument(fileName: "\(String(describing: task.id)).jpg", image: mainView.newTaskImageView.image ?? baseImage)
            repository.addJacsim(item: task)
            
            dismiss(animated: true)
        }
        
    }
}

// MARK: UITextFieldDelegate
extension NewTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: string)
        mainView.titleCountLabel.text = "\(changedText.count)/20"
        return changedText.count <= 19
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        someTextField = textField
    
        if textField == mainView.startDateTextField || textField == mainView.endDateTextField {
            formatter.dateFormat = "yyyy년 M월 d일 EEEE"
            textField.tintColor = .clear
        } else if textField == mainView.successTextField {
            textField.text = ""
        }
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case mainView.newTaskTitleTextfield:
            guard let text = textField.text else { return }
            if text.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                view.makeToast("작심한 일의 제목은 2글자 이상이어야 합니다!", duration: 0.4, position: .center, title: nil, image: nil, style: .init()) { [weak self] _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        textField.text = ""
                        self.mainView.titleCountLabel.text = "0/20"
                    }
                }
                return
            }
        case mainView.successTextField:
            guard let text = textField.text else { return }
            if Int(text) ?? 0 < 1 {
                view.makeToast("성공 횟수는 1보다 커야합니다.", duration: 0.3, position: .center, title: nil, image: nil, style: .init()) { [weak self]_ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.mainView.successTextField.text = "1"
                    }
                }
                return
            }
            
        default:
            return
        }
    }
    @objc func keyboardWillShow(_ sender: Notification){
        
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            if someTextField == mainView.endDateTextField {
                UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 116)}, completion: nil)
            } else if someTextField == mainView.startDateTextField {
                UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 116)}, completion: nil)
            } else if someTextField == mainView.successTextField {
                UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 100)  }, completion: nil)
            } else {
                return
            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification){
        self.view.transform = .identity
    }
    // start와 end textfield는 중복이 되는데, parameter를 이용해서 줄일 수 있는 방법 찾기!
    @objc func startDateTextFieldTapped(){
        if let datePicker = self.mainView.startDateTextField.inputView as? UIDatePicker {
            
            self.mainView.startDateTextField.text = formatter.string(from: datePicker.date)
        }
        self.mainView.startDateTextField.resignFirstResponder()
    }
    
    @objc func endDateTextFieldTapped(){
        if let datePicker = self.mainView.endDateTextField.inputView as? UIDatePicker {
            
            self.mainView.endDateTextField.text = formatter.string(from: datePicker.date)
        }
        self.mainView.endDateTextField.resignFirstResponder()
    }
}

//MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage? = nil
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage
        }
        
        DispatchQueue.main.async {
            
            guard let newImage = newImage else { return }
            
            let crop = CropViewController(image: newImage)
            
            crop.delegate = self
            crop.doneButtonTitle = "완료"
            crop.cancelButtonTitle = "취소"
            
            picker.dismiss(animated: true)
            
            self.present(crop, animated: true)
            
        }
        
        
    }
    
}

//MARK: PHPickerViewControllerDelegate
extension NewTaskViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self]image, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    
                    guard let image = image as? UIImage else { return }
                    
                    let crop = CropViewController(image: image)
                    
                    crop.delegate = self
                    crop.doneButtonTitle = "완료"
                    crop.cancelButtonTitle = "취소"
                    
                    self.present(crop, animated: true)
                    
                }
            }
            
        } else {
            showAlertMessage(title: "사진이 적용되지 않았습니다.", message: "다시 한 번 부탁드릴게요!", button: "확인")
        }
    }
}

extension NewTaskViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        mainView.newTaskImageView.image = image
        self.dismiss(animated: true)
    }
    
}

extension NewTaskViewController {
    
    func scheduleNotification(title: String, fireDate: Date) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "\(title) 작심을 확인해주세요"
        content.sound = .default
        

        notificationCenter.requestAuthorization(
            options: [.alert, .badge ,.sound])
        {
            (granted, error) in

            if let error = error {
                print("granted, but Error in notification permission:\(error.localizedDescription)")
            }
            self.formatter.dateFormat = "yyyy년 M월 d일 EEEE a hh:mm"
            let dateString = self.formatter.string(from: fireDate)
            let fireTrigger = UNTimeIntervalNotificationTrigger(timeInterval: fireDate.timeIntervalSinceNow , repeats: false)

            let fireDateRequest = UNNotificationRequest(identifier: "\(title)\(dateString).starter", content: content, trigger: fireTrigger)

            UNUserNotificationCenter.current().add(fireDateRequest) {(error) in
                if let error = error {
                    print("Error adding firing notification: \(error.localizedDescription)")
                } else {
                    
                    if let firstRepeatingDate = Calendar.current.date(byAdding: .day, value: 1, to: fireDate) {
                        print("\(firstRepeatingDate): 반복 알림 시작일")
                        let repeatingTrigger = UNTimeIntervalNotificationTrigger(timeInterval: firstRepeatingDate.timeIntervalSinceNow, repeats: true)
                        
                        let repeatingRequest = UNNotificationRequest(identifier: "\(title)\(dateString).repeater", content: content, trigger: repeatingTrigger)
                        
                        UNUserNotificationCenter.current().add(repeatingRequest) { (error) in
                            if let error = error {
                                print("Error adding repeating notification: \(error.localizedDescription)")
                            } else {
                                print("Successfully scheduled")
                            }
                        }
                    }
                }
            }
        }
    }
    
}
