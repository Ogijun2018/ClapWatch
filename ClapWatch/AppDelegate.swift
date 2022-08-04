//
//  AppDelegate.swift
//  ClapWatch
//
//  Created by jun.ogino on 2020/12/18.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var viewController: MainViewController!
    var window: UIWindow?
    var backgroundTaskID : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 15.0, *) {
            // disable UITab bar transparent
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let _ = userActivity.interaction?.intent as?
            BackTapIntent {
            switch appDelegate.viewController.mode {
            case .stopped, .paused:
                appDelegate.viewController.startTimer()
            case .running:
                appDelegate.viewController.stopTimer()
            }
        }
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

