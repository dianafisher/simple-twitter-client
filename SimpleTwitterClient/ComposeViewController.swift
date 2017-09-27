//
//  ComposeViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/27/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var placeHolderTextLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = User.currentUser {
            if let profileImageUrl = user.profileUrl
            {
                let imageRequest = URLRequest(url: profileImageUrl)
                profileImageView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                    self.profileImageView.alpha = 0.0
                    self.profileImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        self.profileImageView.alpha = 1.0
                    })
                }, failure: { (imageRequest, imageResponse, error) in
                    print(error)
                })
            } else {
                // TODO: Use placeholder image
            }    
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
       
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
//        let userInfo = notification.userInfo
        
        log.info("Keyboard notification")
    }
    

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func tweetButtonPressed(_ sender: Any) {
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
                
    }
    
    func textViewDidChange(_ textView: UITextView) {

        // Determine whether or not to hide the placeholder label
        self.placeHolderTextLabel.isHidden = !textView.text.isEmpty
        
        // Count number of characters remaining
        let characterCount = textView.text.characters.count
        
        let remainingCount = 140 - characterCount
        
        // Change the count label color to red if there are less than 20 characters remaining
        if remainingCount < 20 {
            characterCountLabel.textColor = UIColor.red
        }
        
        // Disable the tweet button if the character remaining count goes below zero.
        tweetButton.isEnabled = (remainingCount >= 0)
                
        // Update the count label text
        characterCountLabel.text = "\(remainingCount)"
        
    }
}
