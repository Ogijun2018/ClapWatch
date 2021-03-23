//
//  ViewController.swift
//  PhysicalButtonWatch_storyboard
//
//  Created by 荻野隼 on 2020/12/18.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var volumeValue : Float = 0.0
    var volumeView: MPVolumeView!
    
    enum stopWatchMode {
        case running
        case stopped
        case paused
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var minute: UILabel!
    @IBOutlet weak var second: UILabel!
    @IBOutlet weak var mSec: UILabel!
    
    // スプリットタイム用UILabel
    @IBOutlet weak var splitMinute: UILabel!
    @IBOutlet weak var splitSecond: UILabel!
    @IBOutlet weak var splitMSec: UILabel!
    
    var calcuratedMinute : Int = 0
    var calcuratedSecond : Int = 0
    var calcuratedMSec : Int = 0
    
    var calcuratedSplitMinute : Int = 0
    var calcuratedSplitSecond : Int = 0
    var calcuratedSplitMSec : Int = 0
    
    var secondsElapsed = 0.0
    var secondsSplitElapsed = 0.0
    var mode: stopWatchMode = .stopped
    var splitMode: stopWatchMode = .stopped
    
    var laps: [String] = []
    var timer = Timer()
    var splitTimer = Timer()
    var mSecForBackground : Date!
    
    @objc func updateTimer(_ timer: Timer){
        self.secondsElapsed += 0.01
        
        // secondsElapsedは小数点2桁までのDouble値
        self.calcuratedMinute = Int((self.secondsElapsed / 60).truncatingRemainder(dividingBy: 60))
        self.calcuratedSecond = Int(self.secondsElapsed.truncatingRemainder(dividingBy: 60.0))
        self.calcuratedMSec = Int((self.secondsElapsed * 100).truncatingRemainder(dividingBy: 100))
        
        self.minute.text = String(format:"%02d", self.calcuratedMinute)
        self.second.text = String(format:"%02d", self.calcuratedSecond)
        self.mSec.text = String(format:"%02d", self.calcuratedMSec)
    }
    
    @objc func updateSplitTimer(_ timer: Timer){
        self.secondsSplitElapsed += 0.01
        
        // secondsElapsedは小数点2桁までのDouble値
        self.calcuratedSplitMinute = Int((self.secondsSplitElapsed / 60).truncatingRemainder(dividingBy: 60))
        self.calcuratedSplitSecond = Int(self.secondsSplitElapsed.truncatingRemainder(dividingBy: 60.0))
        self.calcuratedSplitMSec = Int((self.secondsSplitElapsed * 100).truncatingRemainder(dividingBy: 100))
        
        self.splitMinute.text = String(format:"%02d", self.calcuratedSplitMinute)
        self.splitSecond.text = String(format:"%02d", self.calcuratedSplitSecond)
        self.splitMSec.text = String(format:"%02d", self.calcuratedSplitMSec)
    }
    
    // Table View Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
        cell.backgroundColor = self.view.backgroundColor
        cell.textLabel?.text = "Lap \(laps.count - indexPath.row)"
        cell.detailTextLabel?.text = "\(laps[indexPath.row])"
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 15)
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 15)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           // 登録
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewWillEnterForeground(
                                                _:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewDidEnterBackground(
                                                _:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("success")
        let volumeView = MPVolumeView(frame: CGRect(origin:CGPoint(x:-3000, y:0), size:CGSize.zero))
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.volumeChanged(notification:)), name:
        NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        startButton.isHidden = false
        stopButton.isHidden = true
        resetButton.isHidden = true
        lapButton.isHidden = false
        lapButton.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            let timeInterval = Date().timeIntervalSince(mSecForBackground)
            var ms = Double(timeInterval)
            ms = round(ms * 100) / 100
            if mode == .running {
                // 若干の誤差があるので0.05sだけ足す
                self.secondsElapsed += (ms + 0.05)
                // 全体のタイマーをスタート
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: true)
            }
            if splitMode == .running {
                self.secondsSplitElapsed += (ms + 0.05)
                // スプリットタイマーをスタート
                splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer(_:)), userInfo: nil, repeats: true)
            }
        }
    }

    @objc func viewDidEnterBackground(_ notification: Notification?) {
        timer.invalidate()
        splitTimer.invalidate()
        if (self.isViewLoaded && (self.view.window != nil)) {
            if mode == .running {
                mSecForBackground = Date()
            }
        }
    }
    
    @IBAction func startTimer() {
        mode = .running
        print("press start")
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
        if splitMode == .paused && !laps.isEmpty {
            splitMode = .running
            splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(splitTimer, forMode: RunLoop.Mode.common)
        }
        
        // スタートしたら明るくする
        lapButton.backgroundColor = UIColor.lightGray
        lapButton.setTitleColor(UIColor.white, for: .normal)
        
        startButton.isHidden = true
        stopButton.isHidden = false
        resetButton.isHidden = true
        lapButton.isHidden = false
        // 一時的にfalse
        lapButton.isEnabled = true
    }
    
    
    @IBAction func resetTimer() {
        timer.invalidate()
        splitTimer.invalidate()
        secondsElapsed = 0.0
        secondsSplitElapsed = 0.0
        
        self.minute.text = "00"
        self.second.text = "00"
        self.mSec.text = "00"
        self.splitMinute.text = "00"
        self.splitSecond.text = "00"
        self.splitMSec.text = "00"
        calcuratedSplitSecond = 0
        calcuratedSplitMinute = 0
        calcuratedSplitMSec = 0
        mode = .stopped
        splitMode = .stopped
        
        lapButton.backgroundColor = UIColor.darkGray
        lapButton.setTitleColor(UIColor.gray, for: .normal)
        
        startButton.isHidden = false
        stopButton.isHidden = true
        resetButton.isHidden = true
        lapButton.isHidden = false
        lapButton.isEnabled = false
        
        // lap reset
        laps.removeAll(keepingCapacity: false)
        tableView.reloadData()
    }
    
    @IBAction func stopTimer() {
        timer.invalidate()
        splitTimer.invalidate()
        mode = .paused
        splitMode = .paused
        
        startButton.isHidden = false
        stopButton.isHidden = true
        resetButton.isHidden = false
        lapButton.isHidden = true
    }
    
    @IBAction func lap() {
        // スプリットタイマーをスタート
        if splitMode == .stopped {
            splitMode = .running
            splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(splitTimer, forMode: RunLoop.Mode.common)
        } else if splitMode == .running {
            splitMode = .running
            secondsSplitElapsed = 0.0
        }
        
        let lapMinute = String(format:"%02d", self.calcuratedMinute)
        let lapSecond = String(format:"%02d", self.calcuratedSecond)
        let lapMSec = String(format:"%02d", self.calcuratedMSec)
        
        let splitLapMinute = String(format:"%02d", self.calcuratedSplitMinute)
        let splitLapSecond = String(format:"%02d", self.calcuratedSplitSecond)
        let splitLapMSec = String(format:"%02d", self.calcuratedSplitMSec)
        
        var lapText = "Split: \(lapMinute):\(lapSecond).\(lapMSec)    Lap: \(splitLapMinute):\(splitLapSecond).\(splitLapMSec)"
        if laps.isEmpty {
            lapText = "Lap: \(lapMinute):\(lapSecond).\(lapMSec)"
        }
        laps.insert(lapText, at: 0)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
        splitTimer.invalidate()
    }

    @objc func volumeChanged(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    print(userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as Any)
                    if volumeValue > userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float{
                        print("volume down")
                        if (mode == .paused) {
                            resetTimer()
                        } else if (mode == .running){
                            lap()
                        }
                    }
                    else if volumeValue < userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float{
                        print("volume up")
                        if (mode == .paused || mode == .stopped) {
                            print("start timer!")
                            startTimer()
                        } else if (mode == .running){
                            print("stop timer!")
                            stopTimer()
                        }
                    }
                    else if volumeValue == userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float && volumeValue == 1{
                        print("volume max")
                        if (mode == .paused || mode == .stopped) {
                            print("start timer!")
                            startTimer()
                        } else if (mode == .running){
                            print("stop timer!")
                            stopTimer()
                        }
                    }
                    else if volumeValue == userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float && volumeValue <= 0.0625{
                        print("volume min")
                        if (mode == .paused) {
                            print("reset timer!")
                            resetTimer()
                        } else if (mode == .running){
                            lap()
                        }
                    }
                    volumeValue = userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float
                }
            }
        }
    }
}
