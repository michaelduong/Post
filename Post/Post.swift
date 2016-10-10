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
    fileprivate let UUIDKey = "uuid"

	/* FIXME: This makes me cringe a little. We should do better. -Andrew */
    var endpoint: URL? {
        return PostController.baseURL?.appendingPathComponent(self.identifier.uuidString).appendingPathExtension("json")
    }
	
    init(username: String, text: String, identifier: UUID = UUID()) {
        
        self.username = username
        self.text = text
        self.timestamp = Date().timeIntervalSince1970
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
	
	init?(json: [String: AnyObject], identifier: String) {
		
		guard let username = json[UsernameKey] as? String,
			let text = json[TextKey] as? String,
			let timestamp = json[TimestampKey] as? Double,
			let identifier = UUID(uuidString: identifier) else { return nil }
		
		self.username = username
		self.text = text
		self.timestamp = TimeInterval(floatLiteral: timestamp)
		self.identifier = identifier
	}
	
	var jsonRepresentation: [String: Any] {
		
		let json: [String: Any] = [
			UsernameKey: username,
			TextKey: text,
			TimestampKey: timestamp,
			]
		
		return json
	}
	
	var jsonData: Data? {
		
		return try? JSONSerialization.data(withJSONObject: jsonRepresentation, options: [.prettyPrinted])
	}
}
