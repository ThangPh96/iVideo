//
//  SearchHistory.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift

class SearchHistory: Object {
    dynamic var name: String!
    //
    dynamic var createdAt = NSDate()
    dynamic var modifiedAt = NSDate()
    
}

