# Post

### Level 3

Post is a simple global messaging service. Students will review MVC principles and work with URLSession, JSON parsing, and closures to build an app that lists and submits posts to a global feed.

Post is a single view application, with the main view being a list of all posts from the global feed listed in reverse-chronological order. The user can add posts via an alert controller presented after tapping an Add (+) bar button item.

Students who complete this project independently are able to:

#### Part One - Model Objects, Model Controller, URLSessionDataTask (HTTP GET method), Refresh Control

* use URLSession to make asynchronous GET HTTP requests
* implement the Codable protocol to decode JSON data and generate model objects from requests
* use closures to execute code when an asynchronous task is complete
* use UIRefreshControl to reload data for a table view

#### Part Two - Alert Controllers, URLSessionDataTask (HTTP POST method), Paging Requests

* use URLSession to make asynchronous POST HTTP requests
* build custom table views that support paging through network requests

## Part One - Model Objects, Model Controller, URLSessionDataTask (HTTP GET method), Refresh Control

* use URLSession to make asynchronous GET HTTP requests
* implement the Codable protocol to decode JSON data and generate model objects from requests
* use closures to execute code when an asynchronous task is complete
* use UIRefreshControl to reload data for a table view

Build your model object, post controller, and post list view controller. Add some polish to the view controller to allow the user to reload posts and know when network requests are happening. Focus on the network requests and decoding the data to display posts in the post list view controller.

### Implement Model

Create a `Post` model type that will hold the information of a post to display to the user.

Create a model object that will represent the `Post` objects that are listed in the feed. This model object will be generated locally, but must also be able to be initialized by decoding JSON data after "GETting" from the backend database.

1. Create a `Post.swift` file and define a new `Post` struct.
2. Go to a sample endpoint of the [Post API](https://dm-post.firebaseio.com/posts.json) and see what JSON (information) you will get back for each post.
3. Using this information, add the properties on `Post`.
* `let username: String`
* `let text: String`
* `let timestamp: TimeInterval`

3. Create a memberwise initializer that takes parameters for the `username` and `text`. Add a parameter for the `timestamp`, but set a default value for it.
* note: This memberwise initializer will only be used locally to generate new model objects. When initializing a new `Post` model object we will use the `.timeIntervalSince1970` from the current date for the `timestamp`.

* Remember, unless you customize it to do otherwise, `JSONEcoder` will use the names of each property as the keys for the JSON data it creates. (EXACT spelling matters!)

There is one more computed property you will add to the `Post` type called `queryTimestamp`, but we will discuss that in Part 2.

### Post Controller

Create a `PostController` class. This class will contain a function that will use a `URLSessionDataTask` to fetch data and will serialize the results into `Post` objects. This class will be used by the view controllers to fetch `Post` objects through completion closures.

Because you will only use one View Controller in this project, there is no reason to make this controller a singleton or shared controller. To learn more about when singletons may not be the best tool, review this article on [Singleton Abuse](https://www.objc.io/issues/13-architecture/singletons/#global-state). The key takeaway for now is that singletons aren't always the right tool for the job and you should carefully consider if it is the best pattern for accessing data in your project.

1. Add a static constant `baseURL` for the `PostController` to know the base URL for the /posts/ subdirectory. This URL will be used to build other URLs throughout the app.
2. Add a `posts` property that will hold the `Post` objects that you pull and decode from the API.
3. Add a method `fetchPosts` that provides a completion closure.

* In the next steps you will create an instance of `URLSessionDataTask` that will get the data at the endpoint URL.
    * Create an unwrapped instance of the `baseURL.
    * Create a constant `getterEndpoint` which takes the unwrapped `baseURL` and appends a path extension of `"json"`
    * Create an instance of `URLRequest` and give it the `getterEndpoint`. (It's very important that you _not_ forget to set the request's httpMethod and httpBody.)
    * Create an instance of `URLSessionDataTask` (Don't forget to call `resume()` after creating this instance.) This method will make the network call and call the completion closer with the `Data?`, `URLResponse?` and `Error?` results.
    * In the closure of the `dataTask(with: URLRequest, completionHandler: ...)`, you will need to handle the results it comes back with:
    *  You will need to give the `Data?`, `URLResponse?` and `Error?` results each a name. We suggest `(data, _, error)`. (You can use the '_' (wildcard) when naming the response because we will not be using it in this project)
    * If the dataTask was successful at retrieving data, `data` will have value, and `error` will not. The opposite is also true. If unsuccessful, `data` will be nil and `error` will have value. 
    * Check for an error. If there is an error, print that error, call `completion()`, and `return`.
    * Unwrap `data` if there is any.
    * Create an instance of `JSONDecoder`
    * Before adding the next step you will need your `Post` struct to adopt the `Codable` protocol.
    * Call `decode(from:)` on your instance of the JSONDecoder. You will need to assign the return of this function to a constant named `postsDictionary`. This function takes in two arguments: a type `[String:Post].self`, and your instance of `data` that came back from the network request. This will decode the data into a [String:Post] _(a dictionary with keys being the UUID that they are stored under on the database as you will see by inspecting the json returned from the network request, and values which should be actual instances of post)_.
        * NOTE: You will also notice that this function `throws`. That means that if you call this function and it doesn't work the way it should, it will _`throw`_ an error. Functions that throw need to be marked with `try` in front of the function call. You will also need to put this call inside of a **do-catch block** and `catch` the error that might be thrown. If there is an error caught, you will want to print the error, call `completion()` and `return`. _Review the documentation if you need to learn about do catch blocks._
    * Call flatmap on this dictionary, pulling out the post from each key-value pair. Assign the new array of posts to a constant named `posts`. 
    * Next, you'll need to sort these posts by timestamp in reverse chronological order (*the newest one is first).
    * Now assign the array of sorted posts to self.posts and call completion.

    _If you call `return` anywhere in this function, remember to call `completion()` before returning. This way you will avoid "leaving the caller hanging" if return ever gets called before adding the fetched posts to your array._

As of iOS 9, Apple is boosting security and requiring developers to use the secure HTTPS protocol and require the server to use the proper TLS Certificate version. The Post API does support HTTPS but does not use the correct TLS Certificate version. So for this app, you will need to turn off the App Transport Security feature.

1. Open your `Info.plist` file and add a key-value pair to your Info.plist. This key-value pair should be:
`App Transport Security Settings : [Allow Arbitrary Loads : YES].`

At this point you should be able to pull the `Post` data from the API and decode it into a list of `Post` objects. Test this functionality with a Playground or by calling this function in your App Delegate and trying to print the results from the API to the console.

1. Because you will always want to fetch posts whenever the tableview appears, you will want to call `fetchPosts()` in `viewDidLoad()` of your `PostListTableViewController`. This will start the call to fetch posts and assign them to the `posts` property. (_You will create this TableViewController in the next step_)

### Post List Table View Controller

Build a view that lists all posts. Implement dynamic height for the cells so that messages are not truncated. Include a Refresh Control that allows the user to 'pull to refresh' to load new, recent posts. 

#### Table View Setup

1. Add a `UITableViewController` as your root view controller in Main.storyboard and embed it in a `UINavigationController`
2. Create an `PostListTableViewController` file as a subclass of `UITableViewController` and set the class of your root view controller scene
3. Add a `postController` property to `PostListTableViewController` and set it to an instance of `PostController`
4. Implement the UITableViewDataSource functions using the included `postController.posts` array
5. Set the `cell.textLabel` to the message, and the `cell.detailTextLabel` to the author and post date.
* note: It may also help to temporarily add the `indexPath.row` to the `cell.detailTextLabel` to quickly determine if the posts are showing up where you expect them to be.

#### Reload with Posts

Create a function that we'll call in several places to reload the tableview on the main thread after `fetchPosts()` is called and the completion closure runs.

1. Create a function called `reloadTableView()`. In this function you will want to both reload the tableview and turn off the network activity spinner. Make sure you run both of these on the `main` thread.

#### Dynamic Cell Height

The length of the text on each `Post` is variable. Add support for dynamic resizing cells to your table view so messages are not truncated.

1. Set the `tableView.estimatedRowHeight` in the `viewDidLoad()` function
2. Set the `tableView.rowHeight` to `UITableViewAutomaticDimension`
3. Update the `textLabel` and `detailTextLabel` on the Post List storyboard scene to support multiple lines by setting the number of lines to 0 in the attributes inspector.

#### Refresh Control

Add a `UIRefreshControl` to the table view to support the 'pull to refresh' gesture.

1. Add a `UIRefreshControl` object to the table view on the storyboard scene. _***It's kind of hard to find**_
2. Add an IBAction from the `UIRefreshControl` to your `PostListTableViewController` class file
3. Implement the IBAction by telling the `postController` to fetch new posts. Make sure you reload the tableview after the posts come back.
4. Tell the `UIRefreshControl` to end refreshing when the `fetchPosts` is complete.

#### Network Activity Indicator

It is good practice to let the user know that a network request is processing. This is most commonly done using the Network Activity Indicator in the status bar.

1. Look up the documentation for the `isNetworkActivityIndicatorVisible` property on `UIApplication` to turn on the indicator when fetching new posts
2. Turn it off when the network call is complete. You should have added this to the `reloadTableView()` function.

Part One is now complete. You should be able to run the app, fetch all of the posts from the API, and have them display in the table view. Look for bugs and fix any that you may find.

### Black Diamonds

* Use a computed `.date` property, `DateComponent`s and `DateFormatter`s to display the `Post` date in the correct time zone
* Make your table view more efficient by inserting cells for new posts instead of reloading the entire tableview

## Part Two - Alert Controllers, URLSessionDataTask (HTTP POST method), Paging Requests

* use URLSession to make asynchronous POST HTTP requests
* build custom table views that support paging through network requests

Build functionality to allow the user to submit new posts to the feed. Make the network requests more efficient by adding paging functionality to the Post Controller. Update the table view to support paging.

### Add Posting Functionality to the Post type

If we make our Post model adopt and conform to the `Codable` protocol it can do some pretty nice work for us. Without it, we'd need to write quite a bit more code in our model. `Codable` is really just a typealias for two other protocols, `Decodable` and `Encodable`. By adopting this protcol our object is now Decodable and Encodable. We'll need `Decodable` when using `GET` and `Encodable` in order to `POST`.

1. Go to your `Post` struct and adopt the `Codable` protocol. That's it! In this app we won't need any further work as long as we name our properties the exact same way the API returns them.

<!-- * note: This will be used when you set the HTTP Body on the `URLRequest`, which requires Data?, not a [String: Any] -->

### Add Posting Functionality to the PostController

Update your `PostController` to initialize a new `Post` and use an `URLSessionDataTask` to post it to the API.

1. Add an `addNewPostWith(username:text:completion:)` function.
2. Implement this function:
* Initialize a `Post` object with the memberwise initializer
* Create a variable called `postData` of type `Data` but don't give it a value.
* Inside of a do-catch block:
    * Create an instance of `JSONEncoder`
    * Create a variable called `postData` to hold the post after it has been encoded into data. Call `encode(value: Encodable) throws` on your instance of the JSONEncoder, passing in the post as an argument. You will need to assign the return of this function to a constant to the `postData` variable you created in the previous step. *Hint - This is a throwing function so make sure to catch the possible error.*
* Next, unwrap your baseURL.
* Next, create a property `postEndpoint` that will hold the unwrapped `baseURL` with a path extension appended to it. Go back and look at your sample url to see what this extension should be.
* Create an instance of URLRequest and give it the `postEndpoint`. (Once again, DO NOT forget to set the request's httpMethod -> `"POST"` and httpBody -> `postData`)
* As we did in the `fetchPosts()` function in Part 1, you need to create and run(`resume()`) a `URLSessionDataTask` and handle it's results:
* Check for errors. (_See Firebase's documentation for details on catching errors from the Post API._)
* note: You can use `String(data: data, encoding: .utf8)` to capture and print a readable representation of the returned data. Because of the quirks of this specific API, you will want to check this string to see if the returned data indicates an error.
* If there are no errors, log the success and the response to the console.
* After posting to the API, call `fetchPosts()` to load the new `Post` and any other new `Post` objects from the server.
* This is a little tricky but you'll need to call `completion()` for the `addNewPostWith(username:text:completion:)` function inside of the completion closure that gets called when the `fetchPosts()` is finished.

### Add Posting Functionality to the User Interface

1. Add a (+) `UIBarButtonItem` to the `PostListTableViewController` scene in storyboard
2. Add an IBAction to the `PostListTableViewController` class file from the bar button item
3. Write a `presentNewPostAlert()` function that initializes a `UIAlertController`.
* Add a `usernameTextField` and a `messageTextField` that the user will use to create their message.
* Add a 'Post' alert action that guards for username and message text, and uses the `PostController` to add a post with the username and text.
4. Write a `presentErrorAlert()` function that initializes a `UIAlertController` that says the user is missing information and should try again. Call the function if the user doesn't include include text in the `usernameTextField` or `messageTextField`
5. Call the `presentErrorAlert()` function in the `else` statement of the `guard` statement that checks for username and message text.
6. Create a 'Cancel' alert action, add both alert actions to the alert controller, and then present the alert controller.
7. Call the `presentNewPostAlert()` function from the IBaction of the + `UIBarButtonItem`

### Improving Efficiency of the Network Requests

You may have noticed that the network request to load the global feed can take multiple seconds to run. As more students build this project and submit more messages, the data returned from the `PostController` will get larger and larger. When you are working with hundreds of objects this is not a problem, but once you start dealing with thousands, tens of thousands, or more, things will start slowing down considerably.

Additionally, consider that the user is unlikely to scroll all the way to the first message in the global feed if there are thousands of posts. We can be more efficient by not loading it in the first place.

To avoid the inefficiency of loading data that will never be displayed, many APIs support 'querying' or 'paging'. The Post API you are using for this project supports paging. We will implement paging on the `PostController` and add support on the Post List Scene to load new posts as the user scrolls.

#### Add Paging Functionality to the Post Controller

Update the `PostController` to fetch a limited number of `Post` objects from the API by using the URL parameters detailed in the API documentation.

Consider that there are two use cases for using the `fetchPosts` function:

* To load a fresh list of `Post` objects for when the user wants to see the latest posts.
* To add the next set (or 'page') of posts to the already fetched posts for when the user wants to see older posts than the ones already loaded.

So you must update the `fetchPosts` function to support both of these cases.

1. Add a Bool `reset` parameter to the beginning of the `fetchPosts` function and assign a default value of `true`.
* This value will be used to determine whether you should replace the `posts` property or append posts to the end of it.
2. Review the API Documentation [Firebase documentation](https://firebase.google.com/docs/database/rest/retrieve-data?authuser=1#section-rest-filtering) to determine what URL parameters you need to pass to fetch a subset of posts.
* note: Experiment with the URL parameters using PostMan, Paw, or your web browser.
3. Consider the following concepts. Attempt to implement the different ways you have considered. Continue to the next step after 10 minutes.
* Consider how you can get the range of timestamps for the request
* Consider how many `Post` dictionaries you want returned in the request
* Use a whiteboard to draw out scenarios and potential sorting and filtering mechaninisms to get the data you want
4. Use the following logic to generate the URL parameters to get the desired subset of `Post` JSON. This can be complex, but think through it before using the included sample code below.
* You want to order the posts in reverse chronological order.
* Request the posts ordered by `timestamp` to put them in chronological order (`orderBy`).
* Specify that you want the list to end at the `timestamp` of the least recent `Post` you have already fetched (or at the current date if you haven't posted any). Specify that you want the posts at the end of that ordered list (`endAt`).
* Specify that you want the last 15 posts (`limitToLast`).
5. Determine the necessary `timestamp` for your query based on whether you are resetting the list (where you would want to use the current time), or appending to the list (where you would want to use the time of the earlier fetched `Post`). 
6. As this is quite a bit to modify we will walk you through this: 
* Add this code inside of the `fetchPosts()` function, being the first line of code it will run:
```
let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
```
* Build a `[String: String]` Dictionary literal of the URL Parameters you want to use. Add this code after you unwrap the `baseURL`
```
let urlParameters = [
"orderBy": "\"timestamp\"",
"endAt": "\(queryEndInterval)",
"limitToLast": "15",
]
```
* Create a constant called `queryItems`. We need to flatmap over the urlParameters, turning them into `URLQueryItem`s.
```
let queryItems = urlParameters.flatMap( { URLQueryItem(name: $0.key, value: $0.value) } )
```
* Create a variable called `urlComponents` of type `URLComponents`. Pass in the unwrapped `baseURL` and `true` as arguments to the initializer.
* Set the `urlComonents.queryItems` to the `queryItems` we just created from the `urlParameters`.
* Then, create a `url` constant. Assign it the value returned from `urlComponents?.url`. *This will need to be placed inside a guard statement to unwrap it.
* Lastly, modify the `getterEndpoint` to append the extension to the `url` not to the `baseURL`.
* Now you'll need to make changes to the code where the data has already come back from the request. Replace the `self.posts = sortedPosts` with logic that uses the `reset` parameter to to determine whether you should replace `self.posts` or append to `self.posts`.
* note: If you want to reset the list, you want to replace, otherwise, you want to append. **Review the method on Array called `append(contentsOf:)`*

#### Add Paging Functionality to the User Inferface

Add paging functionality to the List View by adding logic that checks for when the user has scrolled to the end of the table view, and calls the updated `fetchPosts` function with the correct parameters.

1. Review the `UITableViewDelegate` [Protocol Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableViewDelegate_Protocol/index.html) to find a function that could be used to determine when the user has scrolled to the bottom of the table view.
* note: Move on to the next step after reviewing for potential solutions to implement this feature.
2. Add and implement the `tableView(_:willDisplay:forRowAt:)` function
* Check if the indexPath.row of the cell parameter is greater than or equal to the number of posts currently loaded - 1 on the `postController`
* If so, call the `fetchPosts` function with reset set to false
* In the completion closure, reload the tableview if the returned [Post] is not empty

#### Test and Refine the Paging Logic

Review the newly implemented paging feature. Scroll through the posts on the feed. Pay special attention to any abnormalities (unordered posts, repeated posts, empty posts, etc).

You will notice that there is a repeated post where every new fetch occurred. If you review the API documentation, you'll find that our `endAt` query parameter is inclusive, meaning that it will _include_ any posts that match the exact `timestamp` of the last post. So each time we run the `fetchPosts` function, the API will return a duplicate of the last post.

We can fix this bug by adjusting the `timestamp` we use for the query by a single digit.

1. Add a computed property `queryTimestamp` to the `Post` type that returns a `TimeInterval` adjusted by 0.00001 from the `self.timestamp`
2. Update the `queryEndInterval` variable in the `fetchPosts` function to use the `posts.last?.queryTimestamp` instead of the regular `timestamp`

Run the app, check for bugs, and fix any you may find.

### Black Diamonds

* Any app that displays user submitted content is required to provide a way to report and hide content, or it will be rejected during App Review. Add reporting functionality to the project.
* Update the user interface to cue to the user that a post is new.
* Make your table view more efficient by inserting cells for new posts instead of reloading the entire tableview.
* Implement streaming with web sockets.

## Contributions

Please refer to CONTRIBUTING.md.

## Copyright

© DevMountain LLC, 2015. Unauthorized use and/or duplication of this material without express and written permission from DevMountain, LLC is strictly prohibited. Excerpts and links may be used, provided that full and clear credit is given to DevMountain with appropriate and specific direction to the original content.
