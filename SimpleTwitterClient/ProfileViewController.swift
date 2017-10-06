//
//  ProfileViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

private let tweetCellIdentifier = "TweetCell"


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
        
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1148131862, green: 0.6330112815, blue: 0.9487846494, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Remove the drop shadow from the navigation bar
//        navigationController!.navigationBar.clipsToBounds = true

        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.hamburgerViewTapped))
        hamburgerView = HamburgerView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        hamburgerView!.addGestureRecognizer(tapGestureRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerView!)
        
        
        if User.currentUser != nil {
            
            let user = User.currentUser!
            
            nameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenname ?? "")"
            taglineLabel.text = user.tagline
            followersCountLabel.text = "\(user.followersCount)"
            followingCountLabel.text = "\(user.friendsCount)"
            tweetCountLabel.text = "\(user.statusesCount)"
            locationLabel.text = user.location
            
            
            if let profileImageUrl = user.profileUrl
            {
                let imageRequest = URLRequest(url: profileImageUrl)
                profileImageView.setImageWith(imageRequest, placeholderImage: #imageLiteral(resourceName: "placeholder_profile"), success: { (imageRequest, imageResponse, image) in
                    self.profileImageView.alpha = 0.0
                    self.profileImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        self.profileImageView.alpha = 1.0
                    })
                }, failure: { (imageRequest, imageResponse, error) in
                    log.error(error)
                    self.profileImageView.image = #imageLiteral(resourceName: "placeholder_profile")
                })
            } else {
                // Use a placeholder image instead.
                profileImageView.image = #imageLiteral(resourceName: "placeholder_profile")
            }
            
            if let headerImageUrl = user.profileBackgroundUrl {
                let imageRequest = URLRequest(url: headerImageUrl)
                headerImageView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                    self.headerImageView.alpha = 0.0
                    self.headerImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        self.headerImageView.alpha = 1.0
                    })
                }, failure: { (imageRequest, imageResponse, error) in
                    log.error(error)
                })
            }
        }
        
        // Set the corner radius to 50% of width to get round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tweets = self.tweets else {
            return 0
        }
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetCellIdentifier, for: indexPath) as! TweetCell
        cell.mediaImageView.image = nil
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
}
