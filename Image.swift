//
//  Image.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift

class Image: Object {
    
    dynamic var url: String!
    dynamic var width: Int = 0
    dynamic var height: Int = 0
    
    convenience init(url: String!, width: Int, height: Int) {
        self.init()
        self.url = url
        self.width = width
        self.height = height
    }
    
}
