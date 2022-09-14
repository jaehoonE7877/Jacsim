//
//  NewTaskViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class NewTaskViewController: BaseViewController {
    
    let mainView = NewTaskView()
    
    override func loadView() {
        self.view = mainView
    }
    
    var textFieldBottom: CGFloat = 0.0

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
        
        
        self.title = "새로운 작심"
        [mainView.newTaskTitleTextfield, mainView.startDateTextField, mainView.endDateTextField].forEach { $0.delegate = self }
        [mainView.newTaskTitleTextfield, mainView.startDateTextField, mainView.endDateTextField].forEach { $0.returnKeyType = .done }
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
        navigationController?.navigationBar.tintColor = Constant.BaseColor.buttonColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
        
        
        
        tapGesture()
        
    }
    
    private func tapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapEndEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc func tapEndEditing(){
        view.endEditing(true)
    }
    
    @objc func backButtonTapped(){
        self.dismiss(animated: true)
    }
    
    
    
    // MARK: Realm Create
    @objc func saveButtonTapped(){
        
    }
}

extension NewTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBottom = textField.frame.origin.y + textField.frame.height
        print(textFieldBottom)
    }
    // TextField 높이에 따라서 keyboard 제어하기
    @objc func keyboardWillShow(_ sender: Notification){
        
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print(keyboardSize.height)
            guard textFieldBottom >= self.view.frame.height - keyboardSize.height else { return }
            if textFieldBottom == 44 {
            UIView.animate(withDuration: 0.3, animations: {self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 150)}, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification){
        self.view.transform = .identity
    }
    
}
