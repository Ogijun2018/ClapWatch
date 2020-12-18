//
//  ViewController.swift
//  PhysicalButtonWatch_storyboard
//
//  Created by 荻野隼 on 2020/12/18.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    
    var volumeValue : Float = 0.0
    var volumeView: MPVolumeView!
    
    enum stopWatchMode {
        case running
        case stopped
        case paused
    }
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var minute: UILabel!
    @IBOutlet weak var second: UILabel!
    @IBOutlet weak var mSec: UILabel!
    
    
    var secondsElapsed = 0.0
    var mode: stopWatchMode = .stopped
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("success")
        let volumeView = MPVolumeView(frame: CGRect(origin:CGPoint(x:-3000, y:0), size:CGSize.zero))
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.volumeChanged(notification:)), name:
        NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(ViewController.viewDidEnterBackground(_:)),
                    name: UIApplication.didEnterBackgroundNotification,
                    object: nil)
        
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
            print("フォアグラウンド")
        }
    }

    @objc func viewDidEnterBackground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("バックグラウンド")
        }
    }
    
    @IBAction func startTimer() {
        mode = .running
        print("press start")
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true){_ in
            self.secondsElapsed += 0.01
            
            // secondsElapsedは小数点2桁までのDouble値
            let minute = Int((self.secondsElapsed / 60).truncatingRemainder(dividingBy: 60))
            let second = Int(self.secondsElapsed.truncatingRemainder(dividingBy: 60.0))
            let mSec = Int((self.secondsElapsed * 100).truncatingRemainder(dividingBy: 100))
           
            self.minute.text = String(format:"%02d", minute)
            self.second.text = String(format:"%02d", second)
            self.mSec.text = String(format:"%02d", mSec)
        }
        
        startButton.isHidden = true
        stopButton.isHidden = false
        resetButton.isHidden = true
        lapButton.isHidden = false
        // 一時的にfalse
        lapButton.isEnabled = false
    }
    
    
    @IBAction func resetTimer() {
        timer.invalidate()
        secondsElapsed = 0.0
        self.minute.text = "00"
        self.second.text = "00"
        self.mSec.text = "00"
        mode = .stopped
        
        startButton.isHidden = false
        stopButton.isHidden = true
        resetButton.isHidden = true
        lapButton.isHidden = false
        lapButton.isEnabled = false
    }
    
    @IBAction func stopTimer() {
        timer.invalidate()
        mode = .paused
        
        startButton.isHidden = false
        stopButton.isHidden = true
        resetButton.isHidden = false
        lapButton.isHidden = true
    }
    
    var strings = [String]()
    
//    @IBAction func lap() {
//        //あらかじめデータソースを編集しておく。
//        self.strings.insert("insert1", at: 0)
//        self.strings.insert("insert2", at: 0)
//
//        //テーブルビュー挿入開始
//        self.tableView.beginUpdates()
//
//        //挿入するIndexPath
//        var paths = [IndexPath]()
//        paths.append(IndexPath(row: 0, section: 0))
//        paths.append(IndexPath(row: 1, section: 0))
//
//        //挿入処理
//        self.tableView.insertRows(at: paths, with: .automatic)
//
//        //テーブルビュー挿入終了
//        self.tableView.endUpdates()
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        timer.invalidate()
//    }

    @objc func volumeChanged(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    print(userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as Any)
                    if volumeValue > userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float{
                        print("volume down")
                        // 一時停止中ならタイマーをリセットさせる
                        if (mode == .paused) {
                            resetTimer()
                            print("reset timer!")
                        } else if (mode == .running){
                            // ラップを測れるようにしたい
                            // lap()
                        }
                    }
                    else if volumeValue < userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float{
                        print("volume up")
                        // 停止中, 一時停止中ならタイマーをスタートさせる
                        if (mode == .paused || mode == .stopped) {
                            print("start timer!")
                            startTimer()
                        } else if (mode == .running){
                            // 実行中ならタイマー停止
                            print("stop timer!")
                            stopTimer()
                        }
                    }
                    else if volumeValue == userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float && volumeValue == 1{
                        print("volume max")
                        // 停止中, 一時停止中ならタイマーをスタートさせる
                        if (mode == .paused || mode == .stopped) {
                            startTimer()
                            print("start timer!")
                        } else if (mode == .running){
                            // 実行中ならタイマーを停止させる
                            stopTimer()
                            print("stop timer!")
                        }
                        
                    }
                    else if volumeValue == userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float && volumeValue == 0{
                        print("volume min")
                        // 一時停止中ならタイマーをリセットさせる
                        if (mode == .paused) {
                            resetTimer()
                            print("reset timer!")
                        } else if (mode == .running){
                            // ラップを測れるようにしたい
                            // lap()
                        }
                    }
                    volumeValue = userInfo[AnyHashable("AVSystemController_AudioVolumeNotificationParameter")] as! Float
                }
            }
        }
    }
}
