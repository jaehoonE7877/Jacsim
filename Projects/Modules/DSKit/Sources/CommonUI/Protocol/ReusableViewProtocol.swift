//
//  ReusableViewProtocol.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit

public protocol ReusableViewProtocol: AnyObject {
    static var reuseIdentifier: String { get }
}

extension UITableViewCell: ReusableViewProtocol {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: ReusableViewProtocol {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView: ReusableViewProtocol {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}
