//
//  TweetsViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var loadingMoreView: InfiniteScrollActivityView?
    
    var tweets: [Tweet]!
    
    var isMoreDataLoading = false
    
    var lastLoadedTweetId: String?
    
    var apiEndpoint = TwitterAPIEndpoint.HomeTimeline
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Remove the drop shadow from the navigation bar
//        navigationController!.navigationBar.clipsToBounds = true
        
        setupTableView()
        setupRefreshControl()
        setupLoadingMoreView()
        
        requestTweets()
        
        registerForNotifications()
    }    
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let tweetTableViewCellNib = UINib(nibName: Constants.NibName.TweetTableViewCell, bundle: nil)
        tableView.register(tweetTableViewCellNib, forCellReuseIdentifier: Constants.CellReuseIdentifier.TweetTableCell)
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set estimatedRowHeight to improve performance of loading the tableView
        tableView.estimatedRowHeight = 330

    }
    
    fileprivate func setupRefreshControl() {
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        
        // Set the background color and tint of the refresh control
        refreshControl.backgroundColor = UIColor.gray
        refreshControl.tintColor = UIColor.white
        
        // Bind refreshControlAction as the target for our refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        // Add the refresh control to the table view
        tableView.refreshControl = refreshControl
        
    }
    
    fileprivate func setupLoadingMoreView() {
        // Set up the InfiniteScrollActivityView loading indicator
        let loadingViewFrame = CGRect(x: 0,
                                      y: tableView.contentSize.height,
                                      width: tableView.bounds.size.width,
                                      height: InfiniteScrollActivityView.defaultHeight)
        
        loadingMoreView = InfiniteScrollActivityView(frame: loadingViewFrame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)

        // Adjust the table view insets to make room for the activity view
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets

    }
    
    fileprivate func registerForNotifications() {
        // Register to receive new tweet notifications
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Tweet.tweetsDidUpdateNotification),
                                               object: nil, queue: OperationQueue.main) { [weak self] (notification: Notification) in
                                                
                                                let tweet = notification.userInfo!["tweet"] as! Tweet
                                                
                                                log.verbose("A new tweet! 🎉")
                                                
                                                // Add the new tweet to the beginning of the tweets array.                                                
                                                self?.tweets.insert(tweet, at: 0)
                                                
                                                // Reload the table view
                                                self?.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIRefreshControl action
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        requestTweets()
    }
    
    // MARK: - Logout action
        
    @IBAction func onLogoutPressed(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    
    // MARK: Network request
    
    func requestTweets() {
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance?.timeline(endpoint: apiEndpoint, sinceId: nil, maxId: nil, success: { [weak self] (tweets: [Tweet]) in
            log.info("I got the tweets!")
            log.info(tweets.count)
            
            self?.tweets = tweets
            
            self?.lastLoadedTweetId = tweets.last?.idString
            
            self?.tableView.reloadData()
            
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.loadingMoreView?.stopAnimating()
                MBProgressHUD.hide(for: self!.view, animated: true)
            }
            
        }, failure: { (error:Error) in
            log.error(error.localizedDescription)
        })
    }
    
    fileprivate func loadMoreData() {
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance?.timeline(endpoint: apiEndpoint,sinceId: nil, maxId: lastLoadedTweetId, success: { [weak self] (tweets: [Tweet]) in
            log.info("I got more tweets!")
            log.info(tweets.count)
            
            self?.tweets.append(contentsOf: tweets)
            
            self?.lastLoadedTweetId = tweets.last?.idString
            
            self?.tableView.reloadData()
            
            self?.isMoreDataLoading = false
            
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.loadingMoreView?.stopAnimating()
                MBProgressHUD.hide(for: self!.view, animated: true)
            }
            
        }, failure: { (error:Error) in
            log.error(error.localizedDescription)
        })

    }
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifier.DetailsSegue {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let tweet = tweets?[indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.tweet = tweet
        }
        
    }

}

extension TweetsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tweets = self.tweets else {
            return 0
        }
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIdentifier.TweetTableCell, for: indexPath) as! TweetTableViewCell
        cell.mediaImageView.image = nil
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TweetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show the details view for the selected tweet
        
        let tweet = tweets[indexPath.row]
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifier.DetailViewController) as? DetailViewController
        vc?.tweet = tweet
        
        navigationController?.pushViewController(vc!, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior
                
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled beyond the threshold, request more data
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true

                // Update position of loading indicator
                let frame = CGRect(x: 0,
                                   y: tableView.contentSize.height,
                                   width: tableView.bounds.size.width,
                                   height: InfiniteScrollActivityView.defaultHeight)
                
                loadingMoreView?.frame = frame
                
                // Start loading indicator
                loadingMoreView!.startAnimating()
                
                // Request more data
                self.loadMoreData()
                
            }
            
        }
    }
}

extension TweetsViewController: TweetTableViewCellDelegate {
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, replyTo tweet: Tweet) {
        
        // show the compose controller
        let navVC = Utils.instantiateNavController(identifier: Constants.ViewControllerIdentifier.ComposeNavigationController)
        
        let vc = navVC?.topViewController as? ComposeViewController
        if vc != nil {
            vc!.replyToTweet = tweet
            present(navVC!, animated: true, completion: { 
                
            })
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, retweet tweet: Tweet) {
        
        let indexPath = tableView.indexPath(for: tweetTableViewCell)!
        let row = indexPath.row
        
        if let tweetId = tweet.idString {
            
            // Determine if this is a retweet or an unretweet action.
            if tweet.hasRetweeted {
                log.info("Calling unretweet on \(tweetId)")
                
                // Call the unretweet api
                TwitterClient.sharedInstance?.unretweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    log.info("original tweet id: \(tweetId), updated tweet id: \(String(describing: updatedTweet.idString))")
                    
                    updatedTweet.hasRetweeted = false
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }                                        
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
                
            } else {
                log.info("Calling retweet on \(tweetId)")
                TwitterClient.sharedInstance?.retweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    log.info("original tweet id: \(tweetId), updated tweet id: \(String(describing: updatedTweet.idString))")
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, favorite tweet: Tweet) {

        let indexPath = tableView.indexPath(for: tweetTableViewCell)!
        let row = indexPath.row
        
        if let tweetId = tweet.idString {
            
            // Determine if this is a favorite or an unfavorite action.
            if tweet.hasFavorited {
                
                // Call the unretweet api
                TwitterClient.sharedInstance?.unlikeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
                
            } else {
                TwitterClient.sharedInstance?.likeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, showUserProfile user: User) {
//        log.verbose("Show profile for user: \(String(describing: user))")
        
        let navVC = Utils.instantiateNavController(identifier: Constants.ViewControllerIdentifier.ProfileNavigationController)
        let vc = navVC?.topViewController as? ProfileViewController
        if vc != nil {
            vc!.user = user
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

extension TweetsViewController: TweetOptionsCellDelegate {
    
    func tweetOptionsCell(_ tweetOptionsCell: TweetOptionsCell, replyTo tweet: Tweet) {
        
        // show the compose controller
        let navVC = Utils.instantiateNavController(identifier: Constants.ViewControllerIdentifier.ComposeNavigationController)
        
        let vc = navVC?.topViewController as? ComposeViewController
        if vc != nil {
            vc!.replyToTweet = tweet
            present(navVC!, animated: true, completion: {
                
            })
        }
    }
}



