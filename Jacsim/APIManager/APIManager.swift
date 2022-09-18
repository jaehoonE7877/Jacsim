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
        
        let url = EndPoint.imageSearchURL + "query=\(String(describing: text))&display=20&start=\(page)&sort=sim"
        let header: HTTPHeaders = ["X-Naver-Client-Id": APIKey.NAVER_ID, "X-Naver-Client-Secret": APIKey.NAVER_SECRET]
        
        let request = AF.request(url, method: .get, headers: header).validate(statusCode: 200..<300)
        request.responseData { (response) in
            switch response.result {
            case .success(let obj):
                
                do {
                    //let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let getData = try JSONDecoder().decode(ImageModel.self, from: obj)
                    completion(getData)
                } catch {
                    print(error.localizedDescription)
                }
                
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
