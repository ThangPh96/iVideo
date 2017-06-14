//
//  Channel.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import SwiftyJSON
import RealmSwift

class Channel: Object {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var thumb: String!
    dynamic var descriptionChannel: String!
    dynamic var youtube_id: String!
    dynamic var category_id: Int = 0
    
    // Offline properties
    dynamic var offlinePath: String!
    dynamic var createdAt = NSDate()
    dynamic var modifiedAt = NSDate()
    //
    
    convenience init(fromJson json: JSON!) {
        self.init()
        if json == nil{
            return
        }
        id = json["id"].stringValue
        name = json["name"].stringValue
        thumb = json["thumb"].stringValue
        descriptionChannel = json["description"].stringValue
        youtube_id = json["youtube_id"].stringValue
        category_id = json["category_id"].intValue
    }
}
