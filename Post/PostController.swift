//
//  PostController.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class PostController {
	
	static let baseURL = URL(string: "https://devmtn-post.firebaseio.com/posts/")
	static let endpoint = baseURL?.appendingPathExtension("json")
	
	init() {
		fetchPosts()
	}
	
	// MARK: Save Post
	
	func addNewPostWith(username: String, text: String) {
		
		let post = Post(username: username, text: text)
		
		guard let requestURL = post.endpoint else { fatalError("URL optional is nil") }
		
		NetworkController.performRequest(for: requestURL, httpMethod: .Put, body: post.jsonData)  { (data, error) in
			
			let responseDataString = String(data: data!, encoding: .utf8) ?? ""
			
			if error != nil {
				print("Error: \(error)")
			} else if responseDataString.contains("error") {
				print("Error: \(responseDataString)")
			} else {
				print("Successfully saved data to endpoint. \nResponse: \(responseDataString)")
			}
			
			self.fetchPosts()
		}
	}
	
	// MARK: Request
	
	func fetchPosts(reset: Bool = true, completion: (([Post]) -> Void)? = nil) {
		
		guard let requestURL = PostController.endpoint else { fatalError("Post Endpoint url failed") }
		
		let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
		
		//TODO update to query timestamp
		
		let urlParameters = [
			"orderBy": "\"timestamp\"",
			"endAt": "\(queryEndInterval)",
			"limitToLast": "15",
			]
		
		NetworkController.performRequest(for: requestURL, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
			
			let responseDataString = String(data: data!, encoding: .utf8)
			
			guard let data = data,
				let postDictionaries = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: [String: AnyObject]] else {
					
					NSLog("Unable to deserialize JSON. \nResponse: \(responseDataString)")
					completion?([])
					return
			}
			
			let posts = postDictionaries.flatMap { Post(json: $0.1, identifier: $0.0) }
			let sortedPosts = posts.sorted(by: { $0.0.timestamp > $0.1.timestamp })
			
			DispatchQueue.main.async {
				
				if reset {
					self.posts = sortedPosts
				} else {
					self.posts.append(contentsOf: sortedPosts)
				}
				
				completion?(sortedPosts)
			}
		}
	}
	
	// MARK: Properties
	
	weak var delegate: PostControllerDelegate?
	
	var posts: [Post] = [] {
		didSet {
			delegate?.postsWereUpdatedTo(posts: posts, on: self)
		}
	}
}

protocol PostControllerDelegate: class {
	
	func postsWereUpdatedTo(posts: [Post], on postController: PostController)
}
