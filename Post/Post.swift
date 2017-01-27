//
//  Post.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct Post {
    
    fileprivate let UsernameKey = "username"  
    fileprivate let TextKey = "text"  
    fileprivate let TimestampKey = "timestamp"  
	
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, identifier: UUID = UUID()) {  
        
        self.username = username
        self.text = text
        self.timestamp = timestamp
        self.identifier = identifier
    }
	
	// MARK: Properties
	
	let username: String  
	let text: String
	let timestamp: TimeInterval
	let identifier: UUID
	
	var queryTimestamp: TimeInterval {
		return timestamp - 0.000001  
	}
}

// MARK: JSON Conversion

extension Post {
	
	init?(json: [String: Any], identifier: String) {  
		
		guard let username = json[UsernameKey] as? String,
			let text = json[TextKey] as? String,
			let timestamp = json[TimestampKey] as? Double,
			let identifier = UUID(uuidString: identifier) else { return nil }
		
		self.username = username
		self.text = text
		self.timestamp = TimeInterval(floatLiteral: timestamp)
		self.identifier = identifier
	}
}
