//
//  AppDelegate.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 9/25/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Add log destination
        let console = ConsoleDestination()  // log to Xcode Console
//        console.minLevel = .info // just log .info, .warning & .error
        log.addDestination(console)
        
        if User.currentUser != nil {
            // Go straight into the tweets screen and skip login
            
            log.verbose("There is a current user")
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let containerViewController = storyboard.instantiateViewController(withIdentifier: "ContainerViewController") as? ContainerViewController
            window?.rootViewController = containerViewController
            
            let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
            menuViewController?.containerViewController = containerViewController
            
            containerViewController?.menuViewController = menuViewController
            
        } else {
            log.verbose("Nobody home")
        }
        
        // Register to receive logout notifications
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil, queue: OperationQueue.main) { (note: Notification) in
            // switch back to the login page
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = vc
        }
        
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
//        print(url.description)
                
        let twitterClient = TwitterClient.sharedInstance
        twitterClient?.handleOpenUrl(url: url)
        
        return true
    }

}

