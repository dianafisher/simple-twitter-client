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

    static let sharedInstance = TwitterClient(baseURL: baseUrl, consumerKey: consumerKey, consumerSecret: consumerSecret)
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
//    var loginCompletion: ((_ user: User?, _ error: Error?) -> ())?  // hold on to this closure until we need to use it.
    
//    func homeTimeline_old(completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> Void) {
//        
//        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response:Any?) in
//            
//            let dictionaries = response as! [NSDictionary]
//            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
//
//            completion(tweets, nil)
//            
//        }, failure: { (task:URLSessionDataTask?, error: Error) in
//            completion(nil, error)            
//        })
//
//    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response:Any?) in
            
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task:URLSessionDataTask?, error: Error) in
            failure(error as Error)
        })
    }
    
    func currentAccount() {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            print("account: \(String(describing: response))")
            
            let userDictionary = response as! NSDictionary
            
            let user = User(dictionary: userDictionary)
            print("name: \(String(describing: user.name))")
//            print("name: \(user.name)")
//            print("screenname: \(user.screenname)")
//            print("profile url: \(user.profileUrl)")
//            print("description: \(user.tagline)")
            
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error: \(error.localizedDescription)")
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
            self.loginFailure!(error)
        })
        
    }
    
//    func loginWithCompletion(completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
//        
//        loginCompletion = completion
//        
//        // Logout to clear the keychain from previous sessions
//        deauthorize()
//        
//        guard let callbackURL = URL(string:"simpletwitterclient://oauth") else {
//            print("something went wrong creating the callback url")
//            return
//        }
//        
//        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: callbackURL, scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
//            print("I got a token! 🎉")
//            
//            let str = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)"
//            print(str)
//            guard let url = URL(string: str) else {
//                print("something went wrong creating the authorize url")
//                return
//            }
//            
//            // Open the URL in Safari
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: { (success: Bool) in
//                    if success {
//                        print("YAY!")
//                    }
//                })
//            } else {
//                UIApplication.shared.open(url)
//            }
//        }, failure: { (error:Error!) in
//            print("error: \(error.localizedDescription)")
//            self.loginCompletion?(nil, error)
//        })
//    }
    
//    func login_old(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
//        
//        // Logout to clear the keychain from previous sessions
//        deauthorize()
//        
//        guard let callbackURL = URL(string:"simpletwitterclient://oauth") else {
//            print("something went wrong creating the callback url")
//            return
//        }
//        
//        // Fetch the request token to prove we are who we say we are.
//        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: callbackURL, scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
//            print("I got a token! 🎉")
//            
//            let str = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)"
//            print(str)
//            guard let url = URL(string: str) else {
//                print("something went wrong creating the authorize url")
//                return
//            }
//            
//            // Open the URL in Safari
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: { (success: Bool) in
//                    if success {
//                        print("YAY!")
//                    }
//                })
//            } else {
//                UIApplication.shared.open(url)
//            }
//            
//            
//            
//        }, failure: { (error:Error!) in
//            print("error: \(error.localizedDescription)")
//        })
//    }
    
    func handleOpenUrl(url: URL) {
        
        // hold on to the request token from the url
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "https://api.twitter.com/oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            print("I got the access token! 👻")
            
            // invoke loginSuccess
            self.loginSuccess?()
            
        }, failure: { (error: Error!) in
            print("Error: \(error.localizedDescription)")
            self.loginFailure?(error)
        })
        
    }

    
}
