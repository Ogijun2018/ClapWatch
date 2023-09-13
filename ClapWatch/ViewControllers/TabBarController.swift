//
//  TabBarController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2021/05/11.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class TabBarController: UITabBarController {
    var mainVC: MainViewController!
    var recordVC: RecordViewController!
    var settingVC: SettingViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainVC = MainViewController()
        recordVC = RecordViewController()
        settingVC = SettingViewController()

        let mainNavController = UINavigationController(rootViewController: mainVC)
        let recordNavController = UINavigationController(rootViewController: recordVC)
        let settingNavController = UINavigationController(rootViewController: settingVC)

        mainVC.tabBarItem = .init(title: "Watch", image: .init(systemName: "timer.square"), tag: 1)
        recordVC.tabBarItem = .init(title: "Records", image: .init(systemName: "clock.arrow.2.circlepath"), tag: 2)
        settingVC.tabBarItem = .init(title: "Setting", image: .init(systemName: "gear"), tag: 3)

        self.setViewControllers([mainNavController, recordNavController, settingNavController], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
