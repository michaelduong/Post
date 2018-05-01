//
//  Post.swift
//  Post
//
//  Created by Michael Duong on 1/29/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import Foundation

struct Post: Codable {
    var username: String
    var text: String
    var timestamp: TimeInterval
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
    
}


