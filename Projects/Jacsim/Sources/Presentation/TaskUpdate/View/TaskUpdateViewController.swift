//
//  TaskUpdateViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit
import PhotosUI

import DSKit

import CropViewController

final class TaskUpdateViewController: BaseViewController {
    
    let mainView = TaskUpdateView()
    
    let repository = JacsimRepository.shared
    let documentManager = DocumentManager.shared
    
    let viewModel = TaskUpdateViewModel()
    
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
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Configure
    override func configure() {
        view.backgroundColor = .backgroundNormal
        
        mainView.memoTextfield.delegate = self
        tapGesture()
        mainView.certifyButton.addTarget(self, action: #selector(certifyButtonTapped), for: .touchUpInside)
        mainView.imageAddButton.menu = addImageButtonTapped()
        
    }
    
    override func setNavigationController() {
        super.setNavigationController()
        setBackButton(type: .pop)
    }
    
    private func addImageButtonTapped() -> UIMenu {
        let cameraImage = DSKitAsset.Assets.camera.image.withTintColor(.labelNormal)
        let camera = UIAction(title: "카메라", image: cameraImage) { [weak self]_ in
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
        let galleryImage = DSKitAsset.Assets.gallery.image.withTintColor(.labelNormal)
        let gallery = UIAction(title: "갤러리", image: galleryImage) { [weak self] _ in
            guard let self = self else { return }
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
        
        if mainView.memoTextfield.text == "" {
            view.makeToast("한 줄 메모를 입력해주세요!", duration: 0.8, position: .center, title: nil, image: nil, style: .init()) { _ in
            }
            return
        }
        guard let task = task,
              let index = index,
              let memo = mainView.memoTextfield.text,
              let dateText = dateText else { return }
        
        repository.updateMemo(item: task, index: index, memo: memo)
        
        self.documentManager.saveImageToDocument(fileName: "\(task.id)_\(dateText).jpg", image: mainView.certifyImageView.image ?? DSKitAsset.Assets.jacsim.image)
        
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: TextField Delegate
extension TaskUpdateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
            view.makeToast("한 줄 메모는 2글자 이상으로 남겨주세요!", duration: 0.5, position: .center, title: nil, image: nil, style: .init()) { [weak self]_ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    textField.text = ""
                    self.mainView.memoCountLabel.text = "0/20"
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
    extension TaskUpdateViewController: PHPickerViewControllerDelegate {
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true)
            
            let itemProvider = results.first?.itemProvider
            
            if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
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
    
    extension TaskUpdateViewController: CropViewControllerDelegate {
        
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            mainView.certifyImageView.image = image
            self.dismiss(animated: true)
        }
        
    }
