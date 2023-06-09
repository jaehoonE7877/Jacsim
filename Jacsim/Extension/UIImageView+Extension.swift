//
//  UIImageView+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2023/06/09.
//

import UIKit

import Kingfisher

extension UIImageView {
    func setImage(with urlString: String,_ placeHolder: String) {
        //새로운 이미지가 도착전 이전 이미지가 보이는 경우가 있어 이미지를 삭제
        self.image = nil
        let imageBackgroundColor = self.backgroundColor
        self.backgroundColor =  UIColor(hexString: "#FAFAFA")
        let cache = ImageCache.default
        cache.retrieveImage(forKey: urlString, options: nil) { result in // 캐시에서 키를 통해 이미지를 가져온다.
            switch result {
            case .success(let value):
                if let image = value.image { // 만약 캐시에 이미지가 존재한다면
                    self.image = image // 바로 이미지를 셋한다.
                } else {
                    if urlString.isEmpty { return }
                    let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    guard let url = URL(string: encodedStr) else { return }
                    let uiImage = UIImage(named: placeHolder)
                    let resource = ImageResource(downloadURL: url, cacheKey: urlString) // URL로부터 이미지를 다운받고 String 타입의 URL을 캐시키로 지정하고
                    self.kf.setImage(with: resource, placeholder: uiImage, options: nil, progressBlock: nil) { _ in
                    }
                }
                self.backgroundColor = imageBackgroundColor
            case .failure(let error):
                self.backgroundColor = imageBackgroundColor
                print(error)
            }
        }
    }
}
