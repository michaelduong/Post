//
//  Post.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct PostList: Codable {
	struct PostKey: CodingKey {
		var stringValue: String
		init?(stringValue: String) {
			self.stringValue = stringValue
		}
		
		var intValue: Int? { return nil }
		init?(intValue: Int) { return nil }
		
		static let username = PostKey(stringValue: "username")!
		static let text = PostKey(stringValue: "text")!
		static let timestamp = PostKey(stringValue: "timestamp")!
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: PostKey.self)
		var posts = [Post]()
		for key in container.allKeys {
			let nested = try container.nestedContainer(keyedBy: PostKey.self, forKey: key)
			let username = try nested.decode(String.self, forKey: .username)
			let text = try nested.decode(String.self, forKey: .text)
			let timestamp = try nested.decode(TimeInterval.self, forKey: .timestamp)
			guard let uuid = UUID(uuidString: key.stringValue) else {
				throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Identifier \(key.stringValue) isn't a UUID")
			}
			let post = Post(username: username, text: text, timestamp: timestamp, identifier: uuid)
			posts.append(post)
		}
		self.posts = posts
	}
	
	let posts: [Post]
}

struct Post: Codable {
	
	init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, identifier: UUID = UUID()) {
		
		self.username = username
		self.text = text
		self.timestamp = timestamp
		self.identifier = identifier
	}
	
	let username: String
	let text: String
	let timestamp: TimeInterval
	let identifier: UUID
}
