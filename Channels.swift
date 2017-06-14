//
//  Channels.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift

class Channels: Object {
    dynamic var name : String!
    let channels = List<Channel>()
}
