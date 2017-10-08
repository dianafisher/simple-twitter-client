//
//  ProfileViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var tweetCountLabel: UILabel!
    
    var hamburgerView: HamburgerView?
    var tweets: [Tweet]!
    var user: User!
    
    var refreshControl: UIRefreshControl!
    var loadingMoreView: InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var lastLoadedTweetId: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            user = User.currentUser
        }

        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        navigationItem.title = user.name
        
        
        // Remove the drop shadow from the navigation bar
//        navigationController!.navigationBar.clipsToBounds = true
                
        // Set the corner radius to 50% of width to get round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        populateHeaderView()
        setupTableView()
        setupRefreshControl()
        setupLoadingMoreView()
        requestUserTweets()
    }
    
    func populateHeaderView() {
        
        if let user = user {
            nameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenname ?? "")"
            taglineLabel.text = user.tagline
            followersCountLabel.text = "\(user.followersCount)"
            followingCountLabel.text = "\(user.friendsCount)"
            tweetCountLabel.text = "\(user.statusesCount)"
            locationLabel.text = user.location
            
            if let profileImageUrl = user.profileUrl
            {
                Utils.fadeInImageAt(url: profileImageUrl, placeholderImage: #imageLiteral(resourceName: "placeholder_profile"), imageView: profileImageView)
            }
            
            if let headerImageUrl = user.profileBackgroundUrl {
                Utils.fadeInImageAt(url: headerImageUrl, placeholderImage: nil, imageView: headerImageView)
            }
        } else {
            nameLabel.text = ""
            screenNameLabel.text = ""
            taglineLabel.text = ""
            followersCountLabel.text = "0"
            followingCountLabel.text = "0"
            tweetCountLabel.text = "0"
            locationLabel.text = "0"
        }
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
        tweetsTableView.refreshControl = refreshControl
        
    }
    
    fileprivate func setupLoadingMoreView() {
        // Set up the InfiniteScrollActivityView loading indicator
        let loadingViewFrame = CGRect(x: 0,
                                      y: tweetsTableView.contentSize.height,
                                      width: tweetsTableView.bounds.size.width,
                                      height: InfiniteScrollActivityView.defaultHeight)
        
        loadingMoreView = InfiniteScrollActivityView(frame: loadingViewFrame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        // Adjust the table view insets to make room for the activity view
        var insets = tweetsTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tweetsTableView.contentInset = insets
        
    }
    
    fileprivate func requestUserTweets() {
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        TwitterClient.sharedInstance?.userTimeline(user: user, sinceId: nil, maxId: nil, success: { [weak self] (tweets: [Tweet]) in
            
             self?.tweets = tweets
            
            self?.lastLoadedTweetId = tweets.last?.idString
            
            self?.tweetsTableView.reloadData()
            
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
        
        TwitterClient.sharedInstance?.userTimeline(user: user, sinceId: nil, maxId: lastLoadedTweetId, success: { [weak self] (tweets: [Tweet]) in
            
            self?.tweets.append(contentsOf: tweets)
            
            self?.lastLoadedTweetId = tweets.last?.idString
            
            self?.tweetsTableView.reloadData()
            
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
    
    fileprivate func setupTableView() {
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        
        let tweetTableViewCellNib = UINib(nibName: "TweetTableViewCell", bundle: nil)
        tweetsTableView.register(tweetTableViewCellNib, forCellReuseIdentifier: Constants.CellReuseIdentifier.TweetTableCell)
        
        // Set the rowHeight to UITableViewAutomaticDimension to get the self-sizing behavior we want for the cell.
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set estimatedRowHeight to improve performance of loading the tableView
        tweetsTableView.estimatedRowHeight = 330
    }
    
    func hamburgerViewTapped() {
        let navigationController = parent as! UINavigationController
        
//        let containerViewController = navigationController.parent as! ContainerViewController
//        containerViewController.hideOrShowMenu()
        
        guard navigationController.parent != nil else {
            print("parent is nil")
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UIRefreshControl action
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {        
        requestUserTweets()
    }

}

extension ProfileViewController: UITableViewDataSource {
    
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

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show the details view for the selected tweet
        
        let tweet = tweets[indexPath.row]
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifier.DetailViewController) as? DetailViewController
        vc?.tweet = tweet
        
        navigationController?.pushViewController(vc!, animated: true)
    }
}

extension ProfileViewController: TweetTableViewCellDelegate {
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, replyTo tweet: Tweet) {
   
        // show the compose controller
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifier.ComposeNavigationController) as? UINavigationController
        
        let vc = navVC?.topViewController as? ComposeViewController
        if vc != nil {
            vc!.replyToTweet = tweet
            present(navVC!, animated: true, completion: {
                
            })
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, retweet tweet: Tweet) {
        
        let indexPath = tweetsTableView.indexPath(for: tweetTableViewCell)!
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
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
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
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, favorite tweet: Tweet) {
        
        let indexPath = tweetsTableView.indexPath(for: tweetTableViewCell)!
        let row = indexPath.row
        
        if let tweetId = tweet.idString {
            
            // Determine if this is a favorite or an unfavorite action.
            if tweet.hasFavorited {
                
                // Call the unretweet api
                TwitterClient.sharedInstance?.unlikeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
                
            } else {
                TwitterClient.sharedInstance?.likeTweet(tweetId: tweetId, success: { [weak self] (updatedTweet) in
                    
                    self?.tweets[row] = updatedTweet
                    
                    DispatchQueue.main.async {
                        self?.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }
                    
                    }, failure: { (error: Error) in
                        log.verbose("Error: \(error.localizedDescription)")
                })
            }
        }
    }
    
    func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, showUserProfile user: User) {
        log.verbose("Show profile for user: \(String(describing: user))")
        
        let navVC = Utils.instantiateNavController(identifier: Constants.ViewControllerIdentifier.ProfileNavigationController)
        let vc = navVC?.topViewController as? ProfileViewController
        if vc != nil {
            vc!.user = user
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}
