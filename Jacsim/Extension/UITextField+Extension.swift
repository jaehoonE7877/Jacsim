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
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.sizeToFit()
        datePicker.minimumDate = Date()
        
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44.0))
        let cancel = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: #selector(cancelTapped))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "저장", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, done], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func cancelTapped(){
        self.resignFirstResponder()
    }
}
