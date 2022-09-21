//
//  TaskUpdateViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import PhotosUI

final class TaskUpdateViewController: BaseViewController {
    
    let mainView = TaskUpdateView()
    let repository = JacsimRepository()
    
    var task: UserJacsim?
    var dateText: String? //image 저장시에 objectId_dateText로 넣어주기
    var index: Int? //realm memo의 해당하는 index에 textfield 데이터 넣어주기

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        mainView.certifyButton.addTarget(self, action: #selector(certifyButtonTapped), for: .touchUpInside)
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
        
        mainView.memoTextfield.delegate = self
        tapGesture()
        
        mainView.imageAddButton.menu = addImageButtonTapped()
        
    }
    
    override func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Constant.BaseColor.buttonColor
    }
    
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
        let menu = UIMenu(title: "사진의 경로를 정해주세요.", options: .displayInline, children: [camera,gallery])
       
        return menu
    }
    
    private func tapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapEndEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc func tapEndEditing(){
        view.endEditing(true)
    }
    
    @objc func certifyButtonTapped(){
       
        guard let task = task else { return }
        guard let index = index else { return }
        guard let memo = mainView.memoTextfield.text else { return }
        guard let dateText = dateText else { return }

        repository.updateMemo(item: task, index: index, memo: memo)
        
        guard let baseImage = UIImage(systemName: "xmark") else { return }
        saveImageToDocument(fileName: "\(task.id)_\(dateText).jpg", image: mainView.certifyImageView.image ?? baseImage)
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension TaskUpdateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ sender: Notification){
        
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 110)}, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification){
        self.view.transform = .identity
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: string)
        mainView.memoCountLabel.text = "\(changedText.count)/20"
        return changedText.count <= 19
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count <= 2 {
            view.makeToast("한 줄 메모는 2글자 이상으로 남겨주세요!", duration: 0.4, position: .center, title: nil, image: nil, style: .init()) { _ in
                DispatchQueue.main.async {
                    textField.text = ""
                }
            }
            return
        }
    }
}

//MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension TaskUpdateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            self.mainView.certifyImageView.image = newImage
        }
        picker.dismiss(animated: true)
        
    }
    
}

//MARK: PHPickerViewControllerDelegate
extension TaskUpdateViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.mainView.certifyImageView.image = image as? UIImage
                }
            }
            
        } else {
            showAlertMessage(title: "오류 발생으로 사진이 적용되지 않았습니다.", message: "다시 한 번 부탁드릴게요!", button: "확인")
        }
    }
}
