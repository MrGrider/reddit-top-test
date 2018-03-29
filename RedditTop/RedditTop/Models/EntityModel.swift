//
//  EntityModel.swift
//  RedditTop
//
//  Created by Alexander Grischenko on 3/28/18.
//  Copyright © 2018 grider. All rights reserved.
//

import UIKit

public class EntityModel: NSObject {
    
    let title: String!
    let author: String!
    let timestamp: Double!
    let commentsCount: Int!
    var thumbnail: String?
    var images: [String]?

    public init(withJsonDictionary json: [String: Any]) {
        let data = json["data"] as! [String: Any]
        self.title = data["title"] as! String
        self.author = data["author"] as! String
        self.timestamp = data["created_utc"] as! Double
        self.commentsCount = data["num_comments"] as! Int
        
        let thumbnail = data["thumbnail"] as! String
        // This is a self post, leave thumbnail nil
        if thumbnail != "self" {
            self.thumbnail = thumbnail
        }

        let preview = data["preview"] as? [String: Any]
        if let images = preview?["images"] as? [[String: Any]] {
            self.images = []
            for image in images {
                let source = image["source"] as! [String: Any]
                self.images! += [source["url"] as! String]
            }
        }
    }

}
