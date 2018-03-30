//
//  WebService.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/28/18.
//  Copyright © 2018 grider. All rights reserved.
//

import Foundation
import UIKit

public final class WebService<T> where T: Any {
    
    private static func makeRequest(_ request: URLRequest, completion: @escaping (_ json: [String: Any]?,_ error: Error?)->Void) -> URLSessionTask {
        let session = URLSession.shared
        let dataTask: URLSessionDataTask
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                let code = (error! as NSError).code
                guard code != -999 else { completion(nil, nil); return }
            }
            
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            if data != nil && error == nil && statusCode == 200 {
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
                completion(json, nil)
            } else {
                completion(nil, error)
            }
        })
        dataTask.resume()
        return dataTask
    }
    
    fileprivate static func makeGetRequest(url urlString: String, completion: @escaping (_ json: [String: Any]?,_ error: Error?)->Void) -> URLSessionTask {
        let url = URL.init(string: urlString)
        var request = URLRequest.init(url: url!)
        request.httpMethod = "GET"
        return self.makeRequest(request, completion: completion)
    }
    
}

public extension WebService where T == EntityModel {
    
    public class func getTopReddit(after: String? = nil, range: PostsDatesRange = .all, completion: @escaping ((_ entities: [T]?,_ last: String?,_ error: Error?)->Void))->URLSessionTask {
        var requestString = "https://www.reddit.com/r/all/top.json?limit=50&t=\(range)"
        if after != nil {
            requestString += "&after=\(after!)"
        }
        
        return self.makeGetRequest(url: requestString) { (json, error) in
            var last: String? = nil
            var entities: [T]? = nil
            if json != nil {
                let data = json!["data"] as? [String: Any]
                last = data?["after"] as? String
                let children = data?["children"] as? [Any]
                entities = []
                if children != nil {
                    for child in children! {
                        entities?.append(EntityModel.init(withJsonDictionary: child as! [String : Any]))
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(entities, last, error)
            }
        }
    }

}
