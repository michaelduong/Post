# Post

### Level 3

Post is a simple global messaging service. Students will review MVC principles and work with URLSession, JSON parsing, and closures to build an app that lists and submits posts to a global feed.

Post is a single view application, with the main view being a list of all posts from the global feed listed in reverse-chronological order. The user can add posts via an alert controller presented after tapping an Add (+) bar button item.

Students who complete this project independently are able to:

#### Part One - Model Objects, Model Controller, URLSessionDataTask (HTTP GET method), Refresh Control

* use URLSession to make asynchronous GET HTTP requests
* parse JSON data and generate model objects from requests
* use closures to execute code when an asynchronous task is complete
* use UIRefreshControl to reload data for a table view

#### Part Two - Alert Controllers, URLSessionDataTask (HTTP POST method), Paging Requests

* use URLSession to make asynchronous POST HTTP requests
* build custom table views that support paging through network requests

## Part One - Model Objects, Model Controller, URLSessionDataTask (HTTP GET method), Refresh Control

* use URLSession to make asynchronous GET HTTP requests
* parse JSON data and generate model objects from requests
* use closures to execute code when an asynchronous task is complete
* use UIRefreshControl to reload data for a table view

Build your model object, post controller, and post list view controller. Add some polish to the view controller to allow the user to reload posts and know when network requests are happening. Focus on the network requests and serializing the data to display posts in the post list view controller.

### Implement Model

Create a `Post` model type that will hold the information of a post to display to the user.

Create a model object that will represent the `Post` objects that are listed in the feed. This model object will be generated locally, but must also be able to be generated from JSON dictionaries.

1. Create a `Post.swift` file and define a new `Post` struct.
2. Go to a sample endpoint of the [Post API](https://devmtn-post.firebaseio.com/posts.json) and see what JSON (information) you will get back for each post.
3. Using this information, add the properties on `Post`.
* `let username: String`
* `let text: String`
* `let timestamp: TimeInterval`
* `let identifier: UUID`
* note: UUID stands for Universal Unique Identifier. The `Foundation` framework comes with a `UUID` class that helps generate and initialize `UUID`s from strings. Review the [Class Reference](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSUUID_Class/) to review how to create a new UUID, extract the string value, and initalize an `UUID` from a `String`.
4. Create a memberwise initializer that takes parameters for the `username` and `text`. Optionally, add parameters for the `identifier` and `timestamp`, but set default values for them.
* note: This memberwise initializer will only be used locally to generate new model objects. You can safely assume that initializing a new `Post` model object will require a new UUID for the `identifier`, and will use the `.timeIntervalSince1970` from the current date for the `timestamp`.
5. Create a failable initializer function with a parameter of a JSON dictionary (`[String: Any]`) and an identifier (`String`). This is the method you will use to initialize your `Post` object from a JSON dictionary. Remember to use a sample endpoint to inspect the JSON you will get back and the keys you will use to get each piece of data. You will also need to create a `UUID` from the identifier you pass into the initializer. Guard against required values, and return `nil` if all required information for a post is not available.
* note: The failable initializer is _extremely_ important in this project. Bad users of the API could post improperly formatted JSON that could otherwise break your model objects or cause your application to crash. Make sure you always guard for the required information.
* note: Remember to avoid using magic strings. Create private keys to help you unwrap your JSON.

There is one more computed property you will add to the `Post` type called `queryTimestamp`, but we will discuss that in Part 2.

### Post Controller

Create a `PostController` class. This class will contain a function that will use a `URLSessionDataTask` to fetch data and will serialize the results into `Post` objects. This class will be used by the view controllers to fetch `Post` objects through completion closures.

Because you will only use one View Controller in this project, there is no reason to make this controller a singleton or shared controller. To learn more about when singletons may not be the best tool, review this article on [Singleton Abuse](https://www.objc.io/issues/13-architecture/singletons/#global-state). The key takeaway for now is that singletons aren't always the right tool for the job and you should carefully consider if it is the best pattern for accessing data in your project.

1. Add a static constant `baseURL` for the `PostController` to know the base URL for the /posts/ subdirectory. This URL will be used to build other URLs throughout the app.
2. Add a static constant `getterEndpoint` to the `PostController` to know where to fetch `Post` objects from. Use the `baseURL` and `appendingPathExtension(_:)` function to build the correct endpoint for the API to fetch posts. (This URL will be passed to the `URLRequest`initializer that you will pass to create your `dataTask` in order to fetch posts.)
3. Add a `posts` property that will hold the `Post` objects that you pull and serialize from the API.
4. Add a method `fetchPosts` that provides an optional completion closure.
* In the next steps you will create an instance of `URLSessionDataTask` that will get the data at the endpoint URL.
* Create an instance of `URLRequest` and give it the getterEndpoint. (It's very important that you _not_ forget to set the request's httpMethod and httpBody.)
* Create an instance of `URLSessionDataTask`(Don't forget to call `resume()` after creating this instance.) This method will make the network call and call the completion closer with the `Data?` result. If successful, `Data?` will contain the response, if unsuccessful, `Data?` will be nil. The class or function that calls this function needs to be able handle nil data.
* In the closure of the `dataTask(with: URLRequest, completionHandler: ...)`, you will need to handle the results it comes back with:
* Check for an error. If there is an error, print that error, call completion, and return.
* Next, guard for data and create a constant called `postDictionaries` by serializing the JSON using `JSONSerialization`. You will need to use the `try` keyword to use `JSONSerialization` to serialize the `Data`. Note that the API returns a Dictionary with UUID Strings as the keys, and the [String: Any] representation as the value for each key. If the guard fails, print an error message, run the optional completion, and return from the function.
* note: The syntax for this function can be very difficult. Do your best to complete this without looking at the solution code.
* note: You _must_ run your completion closure even if the data is unavailable, otherwise the object that calls this function will be waiting for a response forever.
* note: You can use `String(data: data, encoding: .utf8)` to capture and print a readable representation of the returned data.
* If the Data can be serialized, initialize the `Post` objects and call the completion closure with the populated array. (Hint: Use a for loop or `.flatMap()` to iterate through the dictionaries and initialize a new array of `Post` objects.)
* note: Because Dictionaries are unsorted, the `[Post]` you generated in this step will not be in any logical order.
* Use the `sorted(by:)` function to sort the posts by the `timestamp` property in reverse chronological order.
* Set `self.posts` to the sorted posts.
* Unwrap the completion and run the closure.
* Because a primary use case for `fetchPosts()` will be to reload the user interface when the request is finished, use Grand Central Dispatch to force the completion closure to run on the main thread. (Hint: `DispatchQueue.main.async`)

There are many different patterns and techniques to serialize JSON data into Model objects. Feel free to experiment with different techniques to get at the `[String: Any]` dictionaries within the Data returned from the `URLSessionDataTask`.

As of iOS 9, Apple is boosting security and requiring developers to use the secure HTTPS protocol and require the server to use the proper TLS Certificate version. The Post API does support HTTPS but does not use the correct TLS Certificate version. So for this app, you will need to turn off the App Transport Security feature.

5. Open your `Info.plist` file and add a key-value pair to your Info.plist. This key-value pair should be:
`App Transport Security Settings : [Allow Arbitrary Loads : YES].`

At this point you should be able to pull the `Post` data from the API and serialize a list of `Post` objects. Test this functionality with a Playground or in your App Delegate by trying to print the results from the API to the console.

5. Because you will always want to fetch posts whenever you initialize the `PostController`, add an `init()` function and call `fetchPosts()`. This will start the call to fetch posts and assign them to the `posts` property.
6. Other classes that use the `PostController` will be interested to know whenever the `posts` property is updated. Implement the delegate pattern to allow the `PostController` to notify an observer of updates to the `posts` property.
* Add a `PostControllerDelegate` protocol with a `postsWereUpdatedTo(posts:, on postController:)` function with a parameter that will be used to pass an array of the posts.
* Add an optional, weak `delegate` variable of type `PostControllerDelegate`.
* Use the `didSet` property observer on the `posts` variable to call the `postsWereUpdatedTo(posts:, on:)` function on the delegate.

### Post List Table View Controller

Build a view that lists all posts. Implement dynamic height for the cells so that messages are not truncated. Include a Refresh Control that allows the user to 'pull to refresh' to load new, recent posts. Conform to the `PostControllerDelegate` protocol to reload the tableview when the `PostController` serializes new posts from the API.

#### Table View Setup

1. Add a `UITableViewController` as your root view controller in Main.storyboard and embed it in a `UINavigationController`
2. Create an `PostListTableViewController` file as a subclass of `UITableViewController` and set the class of your root view controller scene
3. Add a `postController` property to `PostListTableViewController` and set it to an instance of `PostController`
4. Implement the UITableViewDataSource functions using the included `postController.posts` array
5. Set the `cell.textLabel` to the message, and the `cell.detailTextLabel` to the author and post date.
* note: It may also help to temporarily add the `indexPath.row` to the `cell.detailTextLabel` to quickly determine if the posts are showing up where you expect them to be.

#### Reload with Posts

Adopt the `PostControllerDelegate` protocol to observe the `posts` property on the `PostController` to reload the tableview when there are new results.

1. Adopt the `PostControllerDelegate` protocol in the `PostListTableViewController`.
2. Implement the required `postsWereUpdatedTo(posts:on:)` function by reloading the table view
3. Set the delegate in the `viewDidLoad()`

#### Dynamic Cell Height

The length of the text on each `Post` is variable. Add support for dynamic resizing cells to your table view so messages are not truncated.

1. Set the `tableView.estimatedRowHeight` in the `viewDidLoad()` function
2. Set the `tableView.rowHeight` to `UITableViewAutomaticDimension`
3. Update the `textLabel` and `detailTextLabel` on the Post List storyboard scene to support multiple lines by setting the number of lines to 0 in the attributes inspector.

#### Refresh Control

Add a `UIRefreshControl` to the table view to support the 'pull to refresh' gesture.

1. Add a `UIRefreshControl` object to the table view on the storyboard scene
2. Add an IBAction from the `UIRefreshControl` to your `PostListTableViewController` class file
3. Implement the IBaction by telling the `postController` to fetch new posts
4. Tell the `UIRefreshControl` to end refreshing when the `fetchPosts` is complete.

#### Network Activity Indicator

It is good practice to let the user know that a network request is processing. This is most commonly done using the Network Activity Indicator in the status bar.

1. Look up the documentation for the `isNetworkActivityIndicatorVisible` property on `UIApplication` to turn on the indicator when fetching new posts
2. Turn it off when the network call is complete

Part One is now complete. You should be able to run the app, fetch all of the posts from the API, and have them display in the table view. Look for bugs and fix any that you may find.

### Black Diamonds

* Use a computed `.date` property, `DateComponent`s and `DateFormatter`s to display the `Post` date in the correct time zone
* Make your table view more efficient by inserting cells for new posts instead of reloading the entire tableview

## Part Two - Alert Controllers, URLSessionDataTask (HTTP POST method), Paging Requests

* use URLSession to make asynchronous POST HTTP requests
* build custom table views that support paging through network requests

Build functionality to allow the user to submit new posts to the feed. Make the network requests more efficient by adding paging functionality to the Post Controller. Update the table view to support paging.

### Add Posting Functionality to the Post type

Update the `Post` type with a `jsonRepresentation` that will be used to send `Post` objects to the API.

1. Add a `jsonRepresentation` computed property that returns a `[String: Any]` representation of the `Post` object.
* note: Remember to use the correct keys. This will be the same Dictionary that you use in the failable initializer.
2. Add a `jsonData` computed property as a convenient accessor that uses JSONSerialization to get a `Data?` representation of the `jsonRepresentation` dictionary.
* note: This will be used when you set the HTTP Body on the `URLRequest`, which requires Data?, not a [String: Any]

### Add Posting Functionality to the PostController

Update your `PostController` to initialize a new `Post` and use an `URLSessionDataTask` to post it to the API.

1. Add an `addNewPostWith(username:text:)` function.
2. Implement the `addNewPostWith(username:text:)` function:
* Initialize a `Post` object with the memberwise initializer
* Create a property `putEndpoint` that appends a path component and a path extension to the `baseURL`. Use the `identifier` property from the `Post` object you just initialized to append the path component.
* Create an instance of URLRequest and give it the `putEndpoint`. (Once again, DO NOT forget to set the request's httpMethod -> `"PUT"` and httpBody -> `post.jsonData`)
* As we did in the `fetchPosts()` function in Part 1, you need to create and run(`resume()`) a `URLSessionDataTask` and handle it's results:
* Check for errors in the body of the `completion` closure. Check the included API documentation for details on catching errors from the Post API.
* note: You can use `String(data: data, encoding: .utf8)` to capture and print a readable representation of the returned data. Because of the quirks of this specific API, you will want to check this string to see if the returned data indicates an error.
* If there are no errors, log the success and the response to the console.
* After posting to the API, call `fetchPosts()` to load the new `Post` and any other new `Post` objects from the server.

### Add Posting Functionality to the User Interface

1. Add a + `UIBarButtonItem` to the `PostListTableViewController` scene in storyboard
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

To avoid the inefficiency of loading data that will never be displayed, many APIs support querying or paging. The Post API you are using for this project supports paging. We will implement paging on the `PostController` and add support on the Post List Scene to load new posts as the user scrolls.

#### Add Paging Functionality to the Post Controller

Update the `PostController` to fetch a limited number of `Post` objects from the API by using the URL parameters detailed in the API documentation.

Consider that there are two use cases for using the `fetchPosts` function:

* To load a fresh list of `Post` objects for when the user wants to see the latest posts.
* To add the next set (or 'page') of posts to the already fetched posts for when the user wants to see older posts than the ones already loaded.

So you must update the `fetchPosts` function to support both of these cases.

1. Add a Bool `reset` parameter to the beginning of the `fetchPosts` function and assign a default value of `true`.
* This value will be used to determine whether you should replace the `posts` property or append posts to the end of it.
2. Review the API Documentation to determine what URL parameters you need to pass to fetch a subset of posts.
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

```
let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
```

6. Build a `[String: String]` Dictionary literal of the URL Parameters you want to use.

```
let urlParameters = [
"orderBy": "\"timestamp\"",
"endAt": "\(queryEndInterval)",
"limitToLast": "15",
]
```

7. Pass the URL parameters in the `performRequest(for:...)` function.
8. Replace the `self.posts = sortedPosts` with logic that uses the `reset` parameter to to determine whether you should replace `self.posts` or append to `self.posts`.
* note: If you want to reset the list, you want to replace, otherwise, you want to append.

#### Add Paging Functionality to the User Inferface

Add paging functionality to the List View by adding logic that checks for when the user has scrolled to the end of the table view, and calls the updated `fetchPosts` function with the correct parameters.

1. Review the `UITableViewDelegate` [Protocol Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableViewDelegate_Protocol/index.html) to find a function that could be used to determine when the user has scrolled to the bottom of the table view.
* note: Move on to the next step after reviewing for potential solutions to implement this feature.
2. Add and implement the `tableView(_:willDisplay:forRowAt:)` function
* Check if the indexPath.row of the cell parameter is greater than the number of posts currently loaded on the `postController`
* If so, call the `fetchPosts` function with reset set to false
* In the completion closure, reload the tableview if the returned [Post] is not empty

#### Test and Refine the Paging Logic

Review the newly implemented paging feature. Scroll through the posts on the feed. Pay special attention to any abnormalities (unordered posts, repeated posts, empty posts, etc).

You will notice that there is a repeated post where every new fetch occurred. If you review the API documentation, you'll find that our `endAt` query parameter is inclusive, meaning that it will _include_ any posts that match the exact `timestamp` of the last post. So each time we run the `fetchPosts` function, the API will return a duplicate of the last post.

We can fix this bug by adjusting the `timestamp` we use for the query by a single digit.

1. Add a computed property `queryTimestamp` to the `Post` type that returns a `TimeInterval` adjusted by 0.000001 from the `self.timestamp`
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
