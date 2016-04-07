//
//  Extensions.swift
//  NotesDB
//
//  Created by Gabriel Theodoropoulos on 2/20/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SwiftyDB

extension CGRect {
    func toNSData() -> NSData {
        return NSStringFromCGRect(self).dataUsingEncoding(NSUTF8StringEncoding)!
    }
}


extension NSData {
    func toCGRect() -> CGRect {
        return CGRectFromString(NSString(data: self, encoding: NSUTF8StringEncoding) as! String)
    }
}


// SwiftyDB 定义了一个协议来定义primaryKey.
extension Note: PrimaryKeys {
    class func primaryKeys() -> Set<String> {
        return ["noteID"]
    }
}

//not all properties of a class should always be stored to the database, and you should explicitly order SwiftyDB not to include them, use following protocol to do that.
extension Note: IgnoredProperties {
    class func ignoredProperties() -> Set<String> {
        return ["images", "database"]
    }
}

