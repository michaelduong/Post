//
//  Post.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct Post {
    
    fileprivate let usernameKey = "username"
    fileprivate let textKey = "text"
    fileprivate let timestampKey = "timestamp"
	
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
	
}

// MARK: JSON Conversion

extension Post {
	
	init?(json: [String: Any], identifier: String) {  
		
		guard let username = json[usernameKey] as? String,
			let text = json[textKey] as? String,
			let timestamp = json[timestampKey] as? Double,
			let identifier = UUID(uuidString: identifier) else { return nil }
		
		self.username = username
		self.text = text
		self.timestamp = timestamp
		self.identifier = identifier
	}
    
    var dictionaryRepresentation: [String: Any] {
        
        return [usernameKey: username, textKey: text, timestampKey: timestamp]
    }
    
    var jsonData: Data? {
        return (try? JSONSerialization.data(withJSONObject: dictionaryRepresentation, options: .prettyPrinted))
    }
    
}
