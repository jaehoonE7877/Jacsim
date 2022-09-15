//
//  APIManager.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit

import Alamofire

enum APIError: Error {
    case invalidResponse
    case noData
    case failedRequest
    case invalidData
}

class ImageSearchAPIManager {
    
    static let shared = ImageSearchAPIManager()
    
    private init() { }
    
    typealias completion = (ImageModel) -> ()
    
    func fetchImageDate(query: String, page: Int, completion: @escaping completion) {
        
        let text = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let text = text else { return }
        
        let url = EndPoint.imageSearchURL + "query=\(String(describing: text))&display=20&start=\(page)"
        let header: HTTPHeaders = ["X-Naver-Client-Id": APIKey.NAVER_ID, "X-Naver-Client-Secret": APIKey.NAVER_SECRET]
        
        AF.request(url, method: .get, headers: header).validate(statusCode: 200...400).responseData(queue: .global()) { data in
            
            switch data.result {
            // 통신 성공
            case .success(let value):
                dump(value)
                do {
                    
                    let dataJSON = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    
                    let imageResult = try JSONDecoder().decode(ImageModel.self, from: dataJSON)
                    
                    completion(imageResult)
                } catch {
                    print(error.localizedDescription)
                }
            // 통신 실패
            case .failure(let error):
                print(error)
            }

        }
    }
}

