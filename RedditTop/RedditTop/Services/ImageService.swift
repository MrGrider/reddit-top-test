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
    
    private var imagesStorage: [String: Node] = [:]
    var head: Node?
    var tail: Node?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(memoryWarning(notification:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func memoryWarning(notification: NSNotification) {
        var cleanCount = imagesStorage.count / 3
        while cleanCount>0 {
            guard head != nil else { break }
            self.remove(node: head!)
            cleanCount -= 1
        }
    }
    
    func add(node: Node, key: String) {
        if let oldNode: Node = imagesStorage[key] {
            self.remove(node: oldNode)
        }
        
        if let tailNode = tail {
            node.previous = tailNode
            tailNode.next = node
        } else {
            head = node
        }
        tail = node
        imagesStorage[key] = node
    }
    
    func remove(node: Node) {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        if next == nil {
            tail = prev
        }
        
        node.previous = nil
        node.next = nil
        imagesStorage.removeValue(forKey: node.key)
    }

}

public class Node {

    var value: Any
    var key: String
    var next: Node?
    weak var previous: Node?

    init(value: Any, key: String) {
        self.value = value
        self.key = key
    }

}

public extension ImageService {
    
    public static func getImage(forURL URLString: String, completion: @escaping Completion) {
        let storedData = imageService.imagesStorage[URLString]
        
        if storedData == nil {
            let node = Node.init(value: [completion], key:URLString)
            imageService.add(node: node, key: URLString)
            self.downloadImage(fromURL: URLString, completion: { (image) in
                let observers = imageService.imagesStorage[URLString]!.value as! [Completion]
                
                if image == nil {
                    let node = Node.init(value: -1, key:URLString)
                    imageService.add(node: node, key: URLString)
                } else {
                    let node = Node.init(value: image!, key:URLString)
                    imageService.add(node: node, key: URLString)
                }
                
                let nonNilImage = image != nil ? image : UIImage.init(named: "icon-no-thumbnail")
                for observer in observers {
                    observer(nonNilImage)
                }

            })
        } else if let image = storedData!.value as? UIImage {
            completion(image)
        } else if var observers = storedData!.value as? Array<Completion> {
            observers.append(completion)
            let node = Node.init(value: observers, key:URLString)
            imageService.add(node: node, key: URLString)
        } else {
            completion(UIImage.init(named: "icon-no-thumbnail"))
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
