//
//  TwitterClient.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {


    // Singleton instance
    static let sharedInstance = TwitterClient(baseURL: baseUrl, consumerKey: consumerKey, consumerSecret: consumerSecret)    
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    
    func homeTimeline(sinceId: String?, maxId: String?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        var params: [String: Any?] = ["exclude_replies": false]
        
        if maxId != nil {
            params["max_id"] = maxId
        }
        
        if sinceId != nil {
            params["since_id"] = sinceId
        }
        
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil,
            success: { (task: URLSessionDataTask, response:Any?) in
                
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
                                
                success(tweets)
            
        }, failure: { (task:URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func retweet(tweetId: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        
        let postUrlString = "1.1/statuses/retweet/\(tweetId).json"
        log.info("postUrlString: \(postUrlString)")
        
        post(postUrlString, parameters: nil, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                
                log.verbose(response ?? "No Response")
                success(true)
                
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            
            failure(error)
        })
    }
    
    func unretweet(tweetId: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        
        let postUrlString = "1.1/statuses/unretweet/\(tweetId).json"
        log.info("postUrlString: \(postUrlString)")
        
        post(postUrlString, parameters: nil, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                
                log.verbose(response ?? "No Response")
                success(true)
                
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            
            failure(error)
        })
    }
    
    func composetTweet(status: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        
        let params: NSDictionary = ["status": status]
        
        post("1.1/statuses/update.json", parameters: params, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
            
                log.verbose(response ?? "No Response")
                
                let dictionary = response as! NSDictionary
                let tweet = Tweet(dictionary: dictionary)
                
                // Send notification that there is a new Tweet
                let notificationName = NSNotification.Name(rawValue: Tweet.tweetsDidUpdateNotification)
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["tweet": tweet])
                
                success(true)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func replyToTweet(tweetId: String, username: String, status: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        
        // Prepend the username to the status with @username
        let formattedStatus = "@\(username) \(status)"
        log.verbose(formattedStatus)
        
        let params: NSDictionary = ["status": formattedStatus, "in_reply_to_status_id": tweetId]
        
        post("1.1/statuses/update.json", parameters: params, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                
                log.verbose(response ?? "No Response")
                
                let dictionary = response as! NSDictionary
                let tweet = Tweet(dictionary: dictionary)
                
                // Send notification that there is a new Tweet
                let notificationName = NSNotification.Name(rawValue: Tweet.tweetsDidUpdateNotification)
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["tweet": tweet])
                
                success(true)
                
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func deleteTweet(tweetId: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        
        let postUrlString = "1.1/statuses/destroy/\(tweetId).json"
        log.info("postUrlString: \(postUrlString)")
        
        post(postUrlString, parameters: nil, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                
                log.verbose(response ?? "No Response")
                success(true)
                
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            
            failure(error)
        })
    }

    
    func likeTweet(tweetId: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        
        let params: NSDictionary = ["id": tweetId]
        
        post("1.1/favorites/create.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            log.verbose(response ?? "No Response")
            success(true)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            failure(error)
        }
    }
    
    func unlikeTweet(tweetId: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {
        
        let params: NSDictionary = ["id": tweetId]
        
        post("1.1/favorites/destroy.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            log.verbose(response ?? "No Response")
            success(true)
            
        }) { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            failure(error)
        }
    }

    
    
    func currentAccount(success: @escaping (User) ->(), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            print("account: \(String(describing: response))")
            
            let userDictionary = response as! NSDictionary
            
            let user = User(dictionary: userDictionary)
          
            success(user)
            
            print("name: \(String(describing: user.name))")
//            print("name: \(user.name)")
//            print("screenname: \(user.screenname)")
//            print("profile url: \(user.profileUrl)")
//            print("description: \(user.tagline)")
            
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            log.error("Error: \(error.localizedDescription)")
            
            failure(error)
        })
    }
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        
        // Logout to clear the keychain from previous sessions
        deauthorize()
        
        guard let callbackURL = URL(string:"simpletwitterclient://oauth") else {
            print("something went wrong creating the callback url")
            return
        }
        
        // Fetch the request token to prove we are who we say we are.
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: callbackURL, scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            log.verbose("I got a token! 🎉")
            
            let str = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)"
            log.verbose(str)
            guard let url = URL(string: str) else {
                log.error("something went wrong creating the authorize url")
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
            log.error("error: \(error.localizedDescription)")
            self.loginFailure!(error)
        })
        
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        // Send notification that the user has logged out.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
        
    }
    
    
    func handleOpenUrl(url: URL) {
        
        // hold on to the request token from the url
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "https://api.twitter.com/oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            log.verbose("I got the access token! 👻")
            
            self.requestSerializer.saveAccessToken(accessToken)
            
            
            self.currentAccount(success: { (user: User) in
                
                // Set the current user
                User.currentUser = user

                // Invoke loginSuccess
                self.loginSuccess?()
                
            }, failure: { (error: Error) in
                
                // Invoke login failure
                self.loginFailure?(error)
            })
            
            
        }, failure: { (error: Error!) in
            log.error("Error: \(error.localizedDescription)")
            
            // Invoke login failure
            self.loginFailure?(error)
        })
        
    }
    
    

    
}
