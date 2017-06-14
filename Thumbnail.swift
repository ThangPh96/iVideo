//
//  Thumbnail.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift

class Thumbnail: Object {
    
    dynamic var basic: Image!
    dynamic var medium: Image!
    dynamic var high: Image!
    dynamic var standard: Image!
    dynamic var maxres: Image!
}
