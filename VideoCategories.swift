//
//  VideoCategories.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/9/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import SwiftyJSON

class VideoCategories: NSObject {
    dynamic var videoCategoriesId: [String] = []
    dynamic var titles: [String] = []
    
    convenience init(fromJson json: JSON){
        self.init()
        if json == nil{
            return
        }
        for item in json["items"].arrayValue {
            self.titles.append(item["snippet"]["title"].stringValue)
            self.videoCategoriesId.append(item["id"].stringValue)
        }
    }
}
