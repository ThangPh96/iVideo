//
//  SearchHistories.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift

class SearchHistories: Object {
    dynamic var name: String!
    let searchHistories = List<SearchHistory>()
}
