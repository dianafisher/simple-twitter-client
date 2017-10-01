//
//  ComposeViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var placeHolderTextLabel: UILabel!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var characterCountButtonItem: UIBarButtonItem!
    @IBOutlet weak var replyingToLabel: UILabel!
        
    var replyToTweet: Tweet?
    var profileImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Add the toolbar as an accessory view to the textview
        tweetTextView.inputAccessoryView = toolbar
        
        if replyToTweet != nil {
            if let replyToUser = replyToTweet?.user?.screenname {
                replyingToLabel.text = "↓ Replying to @\(replyToUser)"
            }
            
            tweetButton.title = "Reply"
            placeHolderTextLabel.text = "Tweet your reply"
        } else {
            replyingToLabel.text = ""
            tweetButton.title = "Tweet"
            placeHolderTextLabel.text = "What's happening?"            
        }
        
        if let user = User.currentUser {
            if let profileImageUrl = user.profileUrl
            {
                // Place the user's profile image in the left bar button item.
                let imageRequest = URLRequest(url: profileImageUrl)
                let profileImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
                
                profileImageView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                    profileImageView.alpha = 0.0
                    profileImageView.image = image
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        profileImageView.alpha = 1.0
                    })
                    
                    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
                    profileImageView.clipsToBounds = true
                    
                    let profileItem: UIBarButtonItem = UIBarButtonItem.init(customView: profileImageView)
                    self.navigationItem.leftBarButtonItem = profileItem
                    
                    
                }, failure: { (imageRequest, imageResponse, error) in
                    print(error)
                })
            } else {
                // User a placeholder image instead
                profileImageView?.image = #imageLiteral(resourceName: "placeholder_profile")
            }    
        }
        
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tweetTextView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard Event Notifications
    
    func handleKeyboardNotification(_ notification: Notification) {
        
        log.info("Keyboard notification")
    }
    
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true) { }
    }
    
    @IBAction func tweetReplyButtonPressed(_ sender: Any) {
        if let statusText = tweetTextView.text {
            
            if replyToTweet != nil {
                
                let tweet = replyToTweet!
                let screenname = tweet.user?.screenname ?? ""
                
                TwitterClient.sharedInstance?.replyToTweet(tweetId: tweet.idString!, username: screenname, status: statusText, success: { [weak self] (success: Bool) in
                    // dismiss 
                    self?.dismiss(animated: true, completion: nil)
                }, failure: { [weak self] (error: Error) in
                    log.error(error.localizedDescription)
                    self?.showErrorAlert(title: "Error Replying", message: error.localizedDescription)
                })
                
            } else {
                TwitterClient.sharedInstance?.composetTweet(status: statusText, success: { [weak self] (success: Bool) in
                    self?.dismiss(animated: true, completion: nil)
                }, failure: { [weak self] (error: Error) in
                    log.error(error.localizedDescription)
                    self?.showErrorAlert(title: "Error Tweeting", message: error.localizedDescription)
                })
            }
        }
    }
        
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response
        }
        
        alertController.addAction(okAction)        
        present(alertController, animated: true) {
            
        }

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

extension ComposeViewController: UITextViewDelegate {
        
    func textViewDidChange(_ textView: UITextView) {

        // Determine whether or not to hide the placeholder label
        self.placeHolderTextLabel.isHidden = !textView.text.isEmpty
        
        // Count number of characters remaining
        let characterCount = textView.text.characters.count
        
        let remainingCount = 140 - characterCount
        
        // Change the count label color to red if there are less than 20 characters remaining
        if remainingCount < 20 {
            characterCountButtonItem.tintColor = UIColor.red
        } else {
            characterCountButtonItem.tintColor = UIColor.darkGray
        }
        
        // Disable the tweet button if the character remaining count goes below zero.
        tweetButton.isEnabled = (remainingCount >= 0)
        
        // Update the count label text
        characterCountButtonItem.title = "\(remainingCount)"
        
    }
}
