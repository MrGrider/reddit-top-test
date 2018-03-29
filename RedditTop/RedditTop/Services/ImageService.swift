//
//  ImageService.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/29/18.
//  Copyright © 2018 grider. All rights reserved.
//

import Foundation
import UIKit

public final class ImageService {
    
    public typealias Completion = (UIImage?) -> Void

    static let imageService = ImageService()
    private var imagesStorage: [String: Any] = [:]
    
    public static func getImage(forURL URLString: String, completion: @escaping Completion) {
        let storedData = imageService.imagesStorage[URLString]
        
        if storedData == nil {
            imageService.imagesStorage[URLString] = [completion]
            self.downloadImage(fromURL: URLString, completion: { (image) in
                let observers = imageService.imagesStorage[URLString] as! [Completion]
                imageService.imagesStorage[URLString] = image != nil ? image : -1
                
                guard image != nil else { return }
                
                for observer in observers {
                    observer(image)
                }
            })
        } else if (storedData as AnyObject).isKind(of: UIImage.self) {
            completion(storedData as? UIImage)
        } else if (storedData as! Int) != -1 {
            var observersList: [Completion] = storedData as! [Completion]
            observersList.append(completion)
        }
    }
    
    private static func downloadImage(fromURL URLString: String, completion: @escaping Completion) {
        let url = URL.init(string: URLString)
        let request = URLRequest.init(url: url!)

        let session = URLSession.shared
        let dataTask: URLSessionDataTask

        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            let image: UIImage?
            if data != nil {
                image = UIImage.init(data: data!)
            } else {
                image = nil
            }
            DispatchQueue.main.async {
                completion(image)
            }
        })
        dataTask.resume()
    }
    
}
