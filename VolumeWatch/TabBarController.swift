//
//  TabBarController.swift
//  VolumeWatch
//
//  Created by 荻野隼 on 2021/05/11.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class TabBarController: UITabBarController {
    //最初からあるコード
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = self.viewControllers?[0] as? UINavigationController,
           let vc = nc.viewControllers[0] as? MainViewController {
            vc.delegate = self
        }
    }
    
    //最初からあるコード
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TabBarController: FirstDelegate {
    func saveLapToRecord(text: String) {
        if let nc = self.viewControllers?[1] as? UINavigationController,
           let vc = nc.viewControllers[0] as? RecordViewController {
            print("saveButtonTapped発動")
            print("savedString=\(text)")
            vc.savedString = text
            self.selectedIndex = 0
        }
    }
}
