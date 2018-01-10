//
//  Post.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct Post: Codable {
	
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {

        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
	
	// MARK: Properties
	
	let username: String  
	let text: String
	let timestamp: TimeInterval
    
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
}

