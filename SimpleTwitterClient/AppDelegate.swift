//
//  AppDelegate.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Handle openURL
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url.description)
        
        // hold on to the request token from the url
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        let twitterClient = BDBOAuth1SessionManager(baseURL: baseUrl, consumerKey: consumerKey, consumerSecret: consumerSecret)
        
        twitterClient?.fetchAccessToken(withPath: "https://api.twitter.com/oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            print("I got the access token! 👻")
            
            // Now that we have the access token, we can make any API call that we want.
            
            twitterClient?.get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
                print("account: \(String(describing: response))")
                
                let user = response as! NSDictionary
                
                print("name: \(String(describing: user["name"]))")
                
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("Error: \(error.localizedDescription)")
            })
            
            twitterClient?.get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response:Any?) in
                
                let tweets = response as! [NSDictionary]
                
                for tweet in tweets {
                    print("\(tweet["text"]!)")
                }
                
            }, failure: { (task:URLSessionDataTask?, error: Error) in
                print("Error: \(error.localizedDescription)")
            })
            
        }, failure: { (error: Error!) in
            print("Error: \(error.localizedDescription)")
        })

        
        
        return true
    }

}

