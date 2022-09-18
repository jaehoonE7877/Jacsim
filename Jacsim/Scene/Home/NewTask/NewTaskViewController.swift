//
//  NewTaskViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import PhotosUI

import Toast

final class NewTaskViewController: BaseViewController {
    
    let repository = JacsimRepository()
    
    var selectedImageURL: String?
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
        
        view.backgroundColor = .white
        
        
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
        
        [mainView.newTaskTitleTextfield, mainView.startDateTextField, mainView.endDateTextField].forEach { $0.delegate = self }
        [mainView.newTaskTitleTextfield, mainView.startDateTextField, mainView.endDateTextField].forEach { $0.returnKeyType = .done }
        tapGesture()
        
        mainView.imageAddButton.menu = addImageButtonTapped()
        
        mainView.startDateTextField.setInputViewDatePicker(target: self, selector: #selector(startDateTextFieldTapped))
        mainView.endDateTextField.setInputViewDatePicker(target: self, selector: #selector(endDateTextFieldTapped))
    }
    
    override func setNavigationController() {
        self.title = "새로운 작심"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Constant.BaseColor.buttonColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
    }
    
    private func tapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapEndEditing))
        view.addGestureRecognizer(tap)
    }
    
    
    //MARK: UIMenu
    private func addImageButtonTapped() -> UIMenu {
        let search = UIAction(title: "웹으로 검색", image: UIImage(systemName: "magnifyingglass")) { [weak self]_ in
            let vc = ImageSearchViewController()
            vc.delegate = self
            self?.transitionViewController(viewController: vc, transitionStyle: .push)
            
        }
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
        let menu = UIMenu(title: "사진의 경로를 정해주세요.", options: .displayInline, children: [search,camera,gallery])
       
        return menu
    }
    
    @objc func tapEndEditing(){
        view.endEditing(true)
    }
    
    @objc func backButtonTapped(){
        self.dismiss(animated: true)
    }
    
    
    
    // MARK: Realm Create
    @objc func saveButtonTapped(){
        
        guard let title = mainView.newTaskTitleTextfield.text else { return }
        guard let startDate = formatter.date(from: mainView.startDateTextField.text ?? "") else { return }
        guard let endDate = formatter.date(from: mainView.endDateTextField.text ?? "") else { return }
        
        let task = UserJacsim(title: title, startDate: startDate, endDate: endDate, mainImage: selectedImageURL, isDone: false)
        
        repository.addItem(item: task)
        
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
    
    }
    // 첫번째 텍스트 필드만
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count <= 2 {
            view.makeToast("작심한 일의 제목은 2글자 이상이어야 합니다!", duration: 0.4, position: .center, title: nil, image: nil, style: .init()) { _ in
                DispatchQueue.main.async {
                    textField.text = ""
                }
            }
            return
        }
    }
    
    @objc func keyboardWillShow(_ sender: Notification){
        
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            if someTextField == mainView.endDateTextField {
                UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 110)}, completion: nil)
            } else if someTextField == mainView.startDateTextField {
                UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 100)}, completion: nil)
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
            self.mainView.newTaskImageView.image = newImage
        }
        picker.dismiss(animated: true)
        
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
                    self.mainView.newTaskImageView.image = image as? UIImage
                }
            }
            
        } else {
            showAlertMessage(title: "오류 발생으로 사진이 적용되지 않았습니다.", message: "다시 한 번 부탁드릴게요!", button: "확인")
        }
    }
}

protocol SelectImageDelegate {
    func sendImage(image: UIImage, urlString: String)
}

extension NewTaskViewController: SelectImageDelegate {
    
    func sendImage(image: UIImage, urlString: String) {
        mainView.newTaskImageView.image = image
        selectedImageURL = urlString
    }

}
