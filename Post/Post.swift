//
//  Post.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct Post {
    
    private let UsernameKey = "username"
    private let TextKey = "text"
    private let TimestampKey = "timestamp"
    private let UUIDKey = "uuid"

	/* FIXME: This makes me cringe a little. We should do better. -Andrew */
    var endpoint: NSURL? {
        return PostController.baseURL?.URLByAppendingPathComponent(self.identifier.UUIDString)!.URLByAppendingPathExtension("json")
    }
	
    init(username: String, text: String, identifier: NSUUID = NSUUID()) {
        
        self.username = username
        self.text = text
        self.timestamp = NSDate().timeIntervalSince1970
        self.identifier = identifier
    }
	
	// MARK: Properties
	
	let username: String
	let text: String
	let timestamp: NSTimeInterval
	let identifier: NSUUID
	
	var queryTimestamp: NSTimeInterval {
		return timestamp - 0.000001
	}
}

// MARK: JSON Conversion

extension Post {
	
	init?(json: [String: AnyObject], identifier: String) {
		
		guard let username = json[UsernameKey] as? String,
			let text = json[TextKey] as? String,
			let timestamp = json[TimestampKey] as? Double,
			let identifier = NSUUID(UUIDString: identifier) else { return nil }
		
		self.username = username
		self.text = text
		self.timestamp = NSTimeInterval(floatLiteral: timestamp)
		self.identifier = identifier
	}
	
	var jsonValue: [String: AnyObject] {
		
		let json: [String: AnyObject] = [
			UsernameKey: self.username,
			TextKey: self.text,
			TimestampKey: self.timestamp,
			]
		
		return json
	}
	
	var jsonData: NSData? {
		
		return try? NSJSONSerialization.dataWithJSONObject(self.jsonValue, options: NSJSONWritingOptions.PrettyPrinted)
	}
}
