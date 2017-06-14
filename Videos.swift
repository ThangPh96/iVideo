//
//  Videos.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift

class Videos: Object {
    
    let videos = List<Video>()
    dynamic var total: Int = 0
    dynamic var videoPerPage: Int = 0
    dynamic var nextPage: String!
    dynamic var prevPage: String!
    dynamic var name: String!
    
}
