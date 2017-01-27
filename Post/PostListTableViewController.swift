//
//  PostListTableViewController.swift
//  Post
//
//  Created by Caleb Hicks on 5/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    let postController = PostController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        postController.delegate = self
    }
    
    // MARK: Actions
    
    @IBAction func refreshControlPulled(_ sender: UIRefreshControl) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        postController.fetchPosts(reset: true) { (newPosts) in
            sender.endRefreshing()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    // MARK: UITableViewDataSource/Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postController.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
        
        return cell
    }
}

// MARK: - PostControllerDelegate

extension PostListTableViewController: PostControllerDelegate {
    
    func postsWereUpdatedTo(posts: [Post], on postController: PostController) {
        
        tableView.reloadData()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
