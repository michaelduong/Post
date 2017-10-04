//
//  PostController.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

protocol PostControllerDelegate: class {
	func postsWereUpdated()
}

class PostController {
	
	static let shared = PostController()
	
	let baseURL = URL(string: "https://dm-post.firebaseio.com/posts")!
	
	init() {
		fetchPosts()
	}
	
	// MARK: Request
	
	func fetchPosts() {
		
		let requestURL = baseURL.appendingPathExtension("json")
		
		let dataTask = URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
			
			do {
				if let error = error { throw error }
				guard let data = data else {
					throw NSError(domain: "Post", code: -1, userInfo: [NSLocalizedDescriptionKey : "Empty response"])
				}
				
				let postList = try JSONDecoder().decode(PostList.self, from: data)
				let sortedPosts = postList.posts.sorted(by: { $0.timestamp > $1.timestamp })
				self.posts = sortedPosts
			} catch {
				NSLog("Unable to fetch posts: \(error)")
				return
			}
		}
		
		dataTask.resume()
	}
	
	func addPost(username: String, text: String) {
		
		let post = Post(username: username, text: text)
		guard let json = try? JSONEncoder().encode(post) else { return }
		
		let requestURL = baseURL.appendingPathComponent(post.identifier.uuidString)
		var request = URLRequest(url: requestURL)
		request.httpMethod = "PUT"
		request.httpBody = json
		
		let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
			if let error = error {
				NSLog("Error saving post to server: \(error)")
				return
			}
			
			self.fetchPosts()
		}
		
		dataTask.resume()
	}
	
	// MARK: Properties
	
	weak var delegate: PostControllerDelegate?
	
	var posts: [Post] = [] {
		didSet {
			delegate?.postsWereUpdated()
		}
	}
}
