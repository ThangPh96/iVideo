//
//  SearchSuggest.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift
import SwiftyJSON

class SearchSuggests: NSObject {
    
    dynamic var searchSuggests: [String] = []
    
    convenience init(fromJson json: JSON){
        self.init()
        if json == nil{
            return
        }
        if json.arrayValue.count != 0 {
            for item in json.arrayValue[1].arrayValue {
                self.searchSuggests.append(item.stringValue)
            }
        }
    }
}
