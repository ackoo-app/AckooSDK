//
//  AppDelegate.swift
//  AckooSDK
//
//  Created by mihirpmehta on 06/06/2020.
//  Copyright (c) 2020 mihirpmehta. All rights reserved.
//

import UIKit
import AckooSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("Continue User Activity called: ")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            print(url.absoluteString)
            
            let item:OrderItem = OrderItem.init(sku: "CM01-R", name: "Item A", amount: 13.35)
            let date:TimeInterval = Date().timeIntervalSince1970
            let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
            let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com", order: order)
            
            
            
            AckooSDKManager.shared().reportActivity(type: .purchase, activity: activity) { (succeeded, response) in
                print(succeeded)
            }
            
            
            
            
            let alert = UIAlertController(title: "\(url.absoluteString)", message: "Please Select an Option", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                print("User click Approve button")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                print("User click Delete button")
            }))

            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
                print("User click Dismiss button")
            }))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        return true
    }
    


}

