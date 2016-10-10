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
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        postController.delegate = self
    }
	
	// MARK: Actions
    
    @IBAction func addPostTapped(sender: AnyObject) {
        
        presentNewPostAlert()
    }
    
    @IBAction func refreshControlPulled(sender: UIRefreshControl) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        postController.fetchPosts(reset: true) { (newPosts) in
            sender.endRefreshing()
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }

    
    // MARK: UITableViewDataSource/Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return postController.posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath)

        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(NSDate(timeIntervalSince1970: post.timestamp))"

        return cell
    }
	
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row+1 == postController.posts.count {
            
            postController.fetchPosts(reset: false, completion: { (newPosts) in
                
                if !newPosts.isEmpty {
                    
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    
    // MARK: Alerts
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .Alert)
        
        var usernameTextField: UITextField?
        var messageTextField: UITextField?
        
        alertController.addTextFieldWithConfigurationHandler { (usernameField) in
            usernameField.placeholder = "Display name"
            usernameTextField = usernameField
        }
        
        alertController.addTextFieldWithConfigurationHandler { (messageField) in
            
            messageField.placeholder = "What's up?"
            messageTextField = messageField
        }
        
        let postAction = UIAlertAction(title: "Post", style: .Default) { (action) in
            
            guard let username = usernameTextField?.text where !username.isEmpty,
                let text = messageTextField?.text where !text.isEmpty else {
                    
                    self.presentErrorAlert()
                    return
            }
            
            self.postController.addPost(username, text: text)
        }
        alertController.addAction(postAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        
        let alertController = UIAlertController(title: "Uh oh!", message: "You may be missing information or have network connectivity issues. Please try again.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: - PostControllerDelegate

extension PostListTableViewController: PostControllerDelegate {
    
    func postsUpdated(posts: [Post]) {
        
        tableView.reloadData()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
