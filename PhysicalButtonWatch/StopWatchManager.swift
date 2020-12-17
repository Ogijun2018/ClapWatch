//
//  StopWatchManager.swift
//  PhysicalButtonWatch
//
//  Created by 荻野隼 on 2020/12/15.
//

import SwiftUI
import AVFoundation

class StopWatchManager: ObservableObject {
    // ウォッチを開始してから経過した時間の変数
    @Published var secondsElapsed = 0.0
    // ウォッチの現在状態
    @Published var mode: stopWatchMode = .stopped

    // Documentを参照
    var timer = Timer()
    
    func start() {
        mode = .running
        print("press start")
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){_ in
            self.secondsElapsed += 0.01
        }
    }
    
    func stop() {
        timer.invalidate()
        secondsElapsed = 0.0
        mode = .stopped
    }
    
    func pause() {
        timer.invalidate()
        mode = .paused
    }
    
    var volumeValue : Float = 1.0
    
    func plusAction(){
        print("plus pressed.")
    }
    
    func minusAction(){
        print("minus pressed.")
    }
    
    @objc func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    print(userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")])
                    if volumeValue > userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float{
                        print("volume down")
                    }
                    else if volumeValue < userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float{
                        print("volume up")
                    }
                    else if volumeValue == userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float && volumeValue == 1{
                        print("volume max")
                    }
                    else if volumeValue == userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float && volumeValue == 0{
                        print("volume min")
                    }
                    volumeValue = userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float
                }
            }
        }
    }
}

enum stopWatchMode {
    case running
    case stopped
    case paused
}
