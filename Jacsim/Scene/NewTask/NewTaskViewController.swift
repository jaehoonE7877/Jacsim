//
//  NewTaskViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import PhotosUI
import UserNotifications

import CropViewController

final class NewTaskViewController: BaseViewController {
    
    let repository = JacsimRepository()
    
    var alarmDate: Date?
    
    let notificationCenter = UNUserNotificationCenter.current()
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

        print("Realm is located at:", repository.localRealm.configuration.fileURL!)
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
        
        let camera = UIAction(title: "카메라", image: UIImage(systemName: "camera")) { _ in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.showAlertMessage(title: "카메라 사용이 불가합니다.", button: "확인")
                return
            }
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true)
        }
        let gallery = UIAction(title: "갤러리", image: UIImage(systemName: "photo.on.rectangle")) { _ in
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
    
    @objc func alarmSwitchTapped(){
        
        if !mainView.alarmSwitch.isOn {
            mainView.alarmTimeLabel.text = ""
            return
        } else {
            let vc = AlarmViewController()
            vc.completion = { date in
                self.alarmDate = date
                self.formatter.dateFormat = "a hh:mm"
                self.mainView.alarmTimeLabel.text = self.formatter.string(from: self.alarmDate ?? Date())
            }
            self.present(vc, animated: true)
        }
        
        
    }
    
    // MARK: Realm Create
    @objc func saveButtonTapped(){
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "ko_KR")
        timeFormatter.dateFormat = "yyyy년 M월 d일 EEEE a hh:mm"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.timeZone = TimeZone(identifier: "ko_KR")
        
        guard let title = mainView.newTaskTitleTextfield.text else { return }
        
        if title.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            view.makeToast("제목을 입력해주세요! ", duration: 0.8, position: .center, title: nil, image: nil, style: .init()) { _ in
            }
            return
        }
        
        guard let startDate = dateFormatter.date(from: mainView.startDateTextField.text ?? "") else { return }
        guard let endDate = dateFormatter.date(from: mainView.endDateTextField.text ?? "") else { return }
        
        guard let success = Int(mainView.successTextField.text ?? "") else { return }
        

        if startDate - endDate > 0 {
            view.makeToast("종료일은 시작일보다 빠를 수 없습니다.", duration: 1.0, position: .center, title: nil, image: nil, style: .init()) { _ in
                DispatchQueue.main.async {
                    self.mainView.endDateTextField.text = ""
                }
            }
            return
        } else {
            let days = calculateDays(startDate: startDate, endDate: endDate)
            if success > days || success <= 0 {
                view.makeToast("최소 성공 횟수는 작심 진행 일수 보다 많을 수 없습니다.", duration: 2.0, position: .center, title: nil, image: nil, style: .init()) { _ in
                    DispatchQueue.main.async {
                        self.mainView.successTextField.text = ""
                    }
                }
                return
            }
        }
        
        guard let alarm = mainView.alarmTimeLabel.text else { return }
        let valueA = "\(dateFormatter.string(from: startDate)) \(alarm)"
        let alarmDate = timeFormatter.date(from: valueA)
        print(alarmDate)
        
        let task = UserJacsim(title: title, startDate: startDate, endDate: endDate, success: success)
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
            if text.count <= 2 {
                view.makeToast("작심한 일의 제목은 2글자 이상이어야 합니다!", duration: 0.4, position: .center, title: nil, image: nil, style: .init()) { _ in
                    DispatchQueue.main.async {
                        textField.text = ""
                    }
                }
                return
            }
        case mainView.successTextField:
            guard let text = textField.text else { return }
            if Int(text) ?? 0 < 1 {
                view.makeToast("성공 횟수는 1보다 커야합니다.", duration: 0.3, position: .center, title: nil, image: nil, style: .init()) { _ in
                    DispatchQueue.main.async {
                        textField.text = "1"
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
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
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
    
    func sendNotificationRequest(title: String, alarm: Date, index: Int) {
        
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = "확인해주세요"
        content.sound = .default
        content.badge = 1
        
        let component = Calendar.current.dateComponents([.year, .month, .day , .hour, .minute], from: alarm)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
        
        let request = UNNotificationRequest(identifier: title + "\(alarm)", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
}
