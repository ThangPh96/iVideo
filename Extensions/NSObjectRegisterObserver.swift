//
//  NSObjectRegisterObserver.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 12/20/15.
//  Copyright © 2015 V2T Multimedia. All rights reserved.
//

import UIKit

extension NSObject {
    func registerObserver(name: String?, object obj: AnyObject?, queue: OperationQueue?, usingBlock block: @escaping (NSNotification) -> Void) {
        NotificationCenter.default.addObserver(forName: name.map { NSNotification.Name(rawValue: $0) }, object: nil, queue: nil, using: { (notification) -> Void in
            block(notification as NSNotification)
        })
    }
}
