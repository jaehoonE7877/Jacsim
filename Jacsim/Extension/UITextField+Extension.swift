//
//  UITextField+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/14.
//

import UIKit
// DatePicker넣는 TextField
extension UITextField {
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone(identifier: "UTC+9")
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.sizeToFit()
        datePicker.minimumDate = Date()
        
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44.0))
        let cancel = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: #selector(doneTapped))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "저장", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, done], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func doneTapped(){
        self.resignFirstResponder()
    }
    
    func addDoneButtonOnKeyboard() {
        let screenWidth = UIScreen.main.bounds.width
        let doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 44.0))
        doneToolbar.barStyle = .default
        doneToolbar.backgroundColor = .white
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(doneTapped))
        
        doneToolbar.setItems([flexSpace, done], animated: false)
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
}
