//
//  StopWatchManager.swift
//  PhysicalButtonWatch
//
//  Created by 荻野隼 on 2020/12/15.
//

import SwiftUI

class StopWatchManager: ObservableObject {
    // ウォッチを開始してから経過した時間の変数
    @Published var secondsElapsed = 0.0
    // ウォッチの現在状態
    @Published var mode: stopWatchMode = .stopped
    // Documentを参照
    var timer = Timer()
    
    func start() {
        mode = .running
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
}

enum stopWatchMode {
    case running
    case stopped
    case paused
}
