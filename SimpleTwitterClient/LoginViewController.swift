//
//  LoginViewController.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let baseUrl = URL(string: "https://api.twitter.com")
let consumerKey: String = "2I62mbCjt75gMmxa6zgACtNij"
let consumerSecret: String = "Wz9iQTnjpCEQXT5o5KMLj7asB7qUI9sbGNYAvNDEGF9Y3hzzcA"

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        
        let twitterClient = BDBOAuth1SessionManager(baseURL: baseUrl, consumerKey: consumerKey, consumerSecret: consumerSecret)
        
        // Logout to clear the keychain from previous sessions
        twitterClient?.deauthorize()
        
        guard let callbackURL = URL(string:"simpletwitterclient://oauth") else {
            print("something went wrong creating the callback url")
            return
        }
        
        // Fetch the request token to prove we are who we say we are.
        twitterClient?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: callbackURL, scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            print("I got a token! 🎉")
            
            let str = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)"
            print(str)
            guard let url = URL(string: str) else {
                print("something went wrong creating the authorize url")
                return
            }
            
            // Open the URL in Safari
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (success: Bool) in
                    if success {
                        print("YAY!")
                    }
                })
            } else {
                UIApplication.shared.open(url)
            }
            
            
            
        }, failure: { (error:Error!) in
            print("error: \(error.localizedDescription)")
        })
        
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
