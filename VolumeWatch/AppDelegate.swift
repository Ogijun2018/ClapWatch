//
//  AppDelegate.swift
//  PhysicalButtonWatch_storyboard
//
//  Created by 荻野隼 on 2020/12/18.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var backgroundTaskID : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//            // アプリがバックグラウンドへ移行するタイミングを通知
//        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
//        print("aaaaaa")
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // アプリがフォアグラウンドへ移行するタイミングを通知
//        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
//    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        backgroundTaskID = application.beginBackgroundTask(){
            [weak self] in
            application.endBackgroundTask((self?.backgroundTaskID)!)
            self?.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.endBackgroundTask(self.backgroundTaskID)
    }
}

