//
//  WatchViewModel.swift
//  ClapWatch
//
//  Created by Jun Ogino on 2023/09/14.
//

import Foundation
import Combine
import UIKit
import RealmSwift

final class WatchViewModel {
    enum stopWatchMode {
        case running
        case stopped
        case paused
    }

    // MARK: - Outputs

    @Published private(set) var mainWatchTime: WatchTime = WatchTime()
    @Published private(set) var splitWatchTime: WatchTime = WatchTime()
    @Published private(set) var mode: stopWatchMode = .stopped
    @Published private(set) var splitMode: stopWatchMode = .stopped
    @Published private(set) var laps: [String] = []
    @Published private(set) var lapsForOutput: [String] = []
    @Published private(set) var copyTargetText: String = ""

    var secondsElapsed = 0.0 {
        didSet {
            mainWatchTime.minute = Int((secondsElapsed / 60).truncatingRemainder(dividingBy: 60))
            mainWatchTime.second = Int(secondsElapsed.truncatingRemainder(dividingBy: 60.0))
            mainWatchTime.milliSecond = Int((secondsElapsed * 100).truncatingRemainder(dividingBy: 100))
        }
    }
    var secondsSplitElapsed = 0.0 {
        didSet {
            splitWatchTime.minute = Int((secondsSplitElapsed / 60).truncatingRemainder(dividingBy: 60))
            splitWatchTime.second = Int(secondsSplitElapsed.truncatingRemainder(dividingBy: 60.0))
            splitWatchTime.milliSecond = Int((secondsSplitElapsed * 100).truncatingRemainder(dividingBy: 100))
        }
    }

    var timer = Timer()
    var splitTimer = Timer()
    var mSecForBackground : Date?

    let realmInstance = try! Realm()

    // MARK: - Constructors
    init() {

    }

    // MARK: - Inputs
    func startButtonDidTap() {
        switch mode {
        case .stopped, .paused:
            startTimer()
        case .running:
            stopTimer()
        }
    }

    func resetButtonDidTap() {
        switch mode {
        case .paused:
            resetTimer()
        case .running:
            lap()
        default:
            break
        }
    }

    func didEnterBackground(isViewLoaded: Bool, window: UIWindow?) {
        timer.invalidate()
        splitTimer.invalidate()
        if (isViewLoaded && window != nil) {
            if mode == .running {
                mSecForBackground = Date()
            }
        }
    }

    func willEnterForeground() {
        guard mode == .running else { return }
        let timeInterval = Date().timeIntervalSince(mSecForBackground!)
        var ms = Double(timeInterval)
        ms = round(ms * 100) / 100
        // 若干の誤差があるので0.05sだけ足す
        self.secondsElapsed += (ms + 0.05)
        // 全体のタイマーをスタート
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

        guard splitMode == .running else { return }
        self.secondsSplitElapsed += (ms + 0.05)
        // スプリットタイマーをスタート
        splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer), userInfo: nil, repeats: true)
    }

    func willDisappear() {
        timer.invalidate()
        splitTimer.invalidate()
    }

    // MARK: - Private functions
    private func startTimer() {
        mode = .running
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)

        if splitMode == .paused && !laps.isEmpty {
            splitMode = .running
            splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(splitTimer, forMode: RunLoop.Mode.common)
        }
    }

    private func resetTimer() {
        // 最後にストップしたところまでのラップを入れる
        lap()
        timer.invalidate()
        splitTimer.invalidate()

        mode = .stopped
        splitMode = .stopped

        // Save Laps to Local Storage
        let object: RecordModel = RecordModel()
        let recordLap = List<Lap>()

        for i in lapsForOutput {
            let lap = Lap()
            lap.time = i
            recordLap.append(lap)
        }

        // 記録した時刻,ラップを入れる
        object.date = Date()
        object.laps = recordLap
        object.totalTime = "\(mainWatchTime.stringMinute):\(mainWatchTime.stringSecond).\(mainWatchTime.stringMilliSecond)"
        try! realmInstance.write {
            realmInstance.add(object)
        }

        secondsElapsed = 0.0
        secondsSplitElapsed = 0.0
        // lap reset
        laps.removeAll(keepingCapacity: false)
        lapsForOutput.removeAll(keepingCapacity: false)
    }

    private func stopTimer() {
        timer.invalidate()
        splitTimer.invalidate()
        mode = .paused
        splitMode = laps.isEmpty ? .stopped : .paused

        var lapText: String = ""
        var num: Int = 1
        for val in lapsForOutput {
            lapText += "Lap\(num):  \(val)\n"
            num += 1
        }
        lapText += "Lap\(num):  \(OutputLapText(removeSpace: true))"
        copyTargetText = lapText
    }

    private func lap() {
        laps.insert(OutputLapText(removeSpace: false), at: 0)
        lapsForOutput.append(OutputLapText(removeSpace: true))

        switch splitMode {
        case .running:
            secondsSplitElapsed = 0.0
        case .stopped, .paused:
            splitMode = .running
            splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(splitTimer, forMode: RunLoop.Mode.common)
        }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    private func OutputLapText(removeSpace:Bool) -> String {
        var lapText = "Split: \(mainWatchTime.stringMinute):\(mainWatchTime.stringSecond).\(mainWatchTime.stringMilliSecond)    Lap: \(splitWatchTime.stringMinute):\(splitWatchTime.stringSecond).\(splitWatchTime.stringMilliSecond)"
        if laps.isEmpty || lapsForOutput.isEmpty {
            lapText = "Lap: \(mainWatchTime.stringMinute):\(mainWatchTime.stringSecond).\(mainWatchTime.stringMilliSecond)"
        }

        if removeSpace, let theRange = lapText.range(of: "  ") {
            lapText.removeSubrange(theRange)
        }
        return lapText
    }

    @objc private func updateTimer(){
        self.secondsElapsed += 0.01
    }

    @objc private func updateSplitTimer(){
        self.secondsSplitElapsed += 0.01
    }
}
