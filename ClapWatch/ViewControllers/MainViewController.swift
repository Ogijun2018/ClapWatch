//
//  ViewController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2020/12/18.
//

import UIKit
import AVFoundation
import MediaPlayer
import RealmSwift

class MainViewController: UIViewController {
    
    enum stopWatchMode {
        case running
        case stopped
        case paused
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        return button
    }()
    
    var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        return button
    }()
    
    var tableView: UITableView = UITableView()

    var timerContainerView = UIView()
    var minute: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 60)
        label.textAlignment = .center
        return label
    }()
    private let colon: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = UIFont(name: "Avenir Next Regular", size: 60)
        label.textAlignment = .center
        return label
    }()
    var second: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 60)
        label.textAlignment = .center
        return label
    }()
    private let dott: UILabel = {
        let label = UILabel()
        label.text = "."
        label.font = UIFont(name: "Avenir Next Regular", size: 60)
        label.textAlignment = .center
        return label
    }()
    var mSec: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 60)
        label.textAlignment = .center
        return label
    }()

    var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "doc.on.clipboard", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()

    var splitTimerContainerView = UIView()
    // スプリットタイム用UILabel
    var splitMinute: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    var splitSecond: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    var splitMSec: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
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
    var lapsForOutput: [String] = []
    var copyTargetText: String = ""
    var timer = Timer()
    var splitTimer = Timer()
    var mSecForBackground : Date?
    
    let realmInstance = try! Realm()

    var swipeRecognizer = UISwipeGestureRecognizer()
    var panGestureRecognizer = UIPanGestureRecognizer()
    var tapTwoFingerRecognizer = UITapGestureRecognizer()
    var tapThreeFingerRecognizer = UITapGestureRecognizer()
    var shakeGestureEnabled: Bool = false

    func OutputLapText(removeSpace:Bool) -> String {
        let lapMinute = String(format:"%02d", self.calcuratedMinute)
        let lapSecond = String(format:"%02d", self.calcuratedSecond)
        let lapMSec = String(format:"%02d", self.calcuratedMSec)
        
        let splitLapMinute = String(format:"%02d", self.calcuratedSplitMinute)
        let splitLapSecond = String(format:"%02d", self.calcuratedSplitSecond)
        let splitLapMSec = String(format:"%02d", self.calcuratedSplitMSec)
        
        var lapText = "Split: \(lapMinute):\(lapSecond).\(lapMSec)    Lap: \(splitLapMinute):\(splitLapSecond).\(splitLapMSec)"
        if laps.isEmpty || lapsForOutput.isEmpty {
            lapText = "Lap: \(lapMinute):\(lapSecond).\(lapMSec)"
        }
        
        if(removeSpace){
            let result = lapText.range(of: "  ")
            if let theRange = result {
                lapText.removeSubrange(theRange)
            }
        }
        return lapText
    }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func resetSensor() {
        UIDevice.current.isProximityMonitoringEnabled = false
        swipeRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = false
        tableView.isScrollEnabled = true
        tapTwoFingerRecognizer.isEnabled = false
        tapThreeFingerRecognizer.isEnabled = false
        shakeGestureEnabled = false
    }

    // 近接センサーの制御
    var proximityLapControl: Bool = false
    func enableProximitySensor(_ isLap: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = true
        proximityLapControl = isLap
    }

    // シェイクの制御
    var shakeGestureLapControl: Bool = false
    func enableShakeGesture(_ isLap: Bool) {
        shakeGestureEnabled = true
        shakeGestureLapControl = isLap
    }

    // スワイプの制御
    var swipeGestureLapControl: Bool = false
    func enableSwipeGesture(_ isLap: Bool) {
        swipeRecognizer.isEnabled = true
        swipeGestureLapControl = isLap
        // ラップを表示しているTableViewのスクロールをできないようにする
        tableView.isScrollEnabled = false
    }

    // パンの制御
    var panGestureLapControl: Bool = false
    func enablePanGesture(_ isLap: Bool) {
        panGestureRecognizer.isEnabled = true
        panGestureLapControl = isLap
        // ラップを表示しているTableViewのスクロールをできないようにする
        tableView.isScrollEnabled = false
    }

    // 2本指タップの制御
    var twoFingerLapControl: Bool = false
    func enableTwoFingerTap(_ isLap: Bool) {
        tapTwoFingerRecognizer.isEnabled = true
        twoFingerLapControl = isLap
    }

    // 3本指タップの制御
    var threeFingerLapControl: Bool = false
    func enableThreeFingerTap(_ isLap: Bool) {
        tapThreeFingerRecognizer.isEnabled = true
        threeFingerLapControl = isLap
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self

        tableView.allowsSelection = false

        // 上方向スワイプ検出
        swipeRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(MainViewController.handleSwipeGesture(_:))
            )
        swipeRecognizer.direction = .up
        self.view.addGestureRecognizer(swipeRecognizer)
        swipeRecognizer.isEnabled = false

        // パンジェスチャー検出
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.isEnabled = false

        // 2本指タップ検出
        tapTwoFingerRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleTwoFingerTapGesture(_:)))
        tapTwoFingerRecognizer.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(tapTwoFingerRecognizer)
        tapTwoFingerRecognizer.isEnabled = false

        // 3本指タップ検出
        tapThreeFingerRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleThreeFingerTapGesture(_:)))
        tapThreeFingerRecognizer.numberOfTouchesRequired = 3
        self.view.addGestureRecognizer(tapThreeFingerRecognizer)
        tapThreeFingerRecognizer.isEnabled = false
        
        let objects = [
            "container": timerContainerView,
            "splitContainer": splitTimerContainerView,
            "minute": minute,
            "colon": colon,
            "second": second,
            "dot": dott,
            "mSec": mSec,
            "splitMin": splitMinute,
            "splitSec": splitSecond,
            "splitMSec": splitMSec,
            "right": startButton,
            "left": resetButton,
            "copy": copyButton,
            "table": tableView
        ]

        view.addSubview(copyButton)
        timerContainerView.addSubview(minute)
        timerContainerView.addSubview(colon)
        timerContainerView.addSubview(second)
        timerContainerView.addSubview(dott)
        timerContainerView.addSubview(mSec)
        splitTimerContainerView.addSubview(splitMinute)
        splitTimerContainerView.addSubview(splitSecond)
        splitTimerContainerView.addSubview(splitMSec)
        view.addSubview(timerContainerView)
        view.addSubview(splitTimerContainerView)
        view.addSubview(startButton)
        view.addSubview(resetButton)
        view.addSubview(tableView)
        
        tableView.delegate = self
       
        objects.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[copy(==50)]-20-|", metrics: nil, views: objects))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[left]-30-[right(==left)]-50-|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[container]-(>=0)-|", metrics: nil, views: objects))
        splitTimerContainerView.trailingAnchor.constraint(equalTo: timerContainerView.trailingAnchor, constant: -5).isActive = true


        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[copy(==50)]-20-[container][splitContainer]-50-[right(==70)]", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[copy(==50)]-20-[container][splitContainer]-50-[left(==70)]", metrics: nil, views: objects))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[table(==300)]|", metrics: nil, views: objects))
        timerContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[minute]-10-[colon]-10-[second(==minute)]-10-[dot]-10-[mSec(==minute)]|", metrics: nil, views: objects))
        timerContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[minute]|", metrics: nil, views: objects))

        timerContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        splitTimerContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[splitMin]-10-[splitSec(==splitMin)]-10-[splitMSec(==splitMin)]|", metrics: nil, views: objects))
        splitTimerContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[splitMin]|", metrics: nil, views: objects))

        splitMinute.centerYAnchor.constraint(equalTo: splitSecond.centerYAnchor).isActive = true
        splitMinute.centerYAnchor.constraint(equalTo: splitMSec.centerYAnchor).isActive = true

        minute.centerYAnchor.constraint(equalTo: second.centerYAnchor).isActive = true
        minute.centerYAnchor.constraint(equalTo: mSec.centerYAnchor).isActive = true
        minute.centerYAnchor.constraint(equalTo: dott.centerYAnchor).isActive = true
        minute.centerYAnchor.constraint(equalTo: colon.centerYAnchor).isActive = true
        
        startButton.addAction(.init { [weak self] _ in
            switch self?.mode {
            case .stopped, .paused:
                self?.startTimer()
                self?.startButton.setTitle("Stop", for: .normal)
                self?.startButton.backgroundColor = .systemRed
                self?.resetButton.setTitle("Lap", for: .normal)
            case .running:
                self?.stopTimer()
                self?.startButton.setTitle("Start", for: .normal)
                self?.startButton.backgroundColor = .systemGreen
                self?.resetButton.setTitle("Reset", for: .normal)
            default:
                break
            }
        }, for: .touchUpInside)
        
        resetButton.addAction(.init { [weak self] _ in
            switch self?.mode {
            case .paused:
                self?.resetTimer()
                self?.resetButton.setTitle("Lap", for: .normal)
            case .running:
                self?.lap()
            default:
                break
            }
        }, for: .touchUpInside)

        copyButton.isEnabled = false
        copyButton.addAction(.init { [weak self] _ in
            self?.copyLap()
        }, for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.viewWillEnterForeground(
                                                _:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.viewDidEnterBackground(
                                                _:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(proximitySensorState), name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
        splitTimer.invalidate()

        NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }

    // MARK: Sensor control
    @objc func proximitySensorState() {
        if UIDevice.current.proximityState {
            switch mode {
            case .stopped, .paused:
                if(!proximityLapControl){
                    startTimer()
                }
            case .running:
                proximityLapControl ? lap() : stopTimer()
            }
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if shakeGestureEnabled {
            if motion == .motionShake {
                switch mode {
                case .stopped, .paused:
                    if(!shakeGestureLapControl){
                        startTimer()
                    }
                case .running:
                    shakeGestureLapControl ? lap() : stopTimer()
                }
            }
        }
    }

    @objc func handleTwoFingerTapGesture(_ sender: UITapGestureRecognizer){
        switch mode {
        case .stopped, .paused:
            if(!twoFingerLapControl){
                startTimer()
            }
        case .running:
            twoFingerLapControl ? lap() : stopTimer()
        }
    }

    @objc func handleThreeFingerTapGesture(_ sender: UITapGestureRecognizer) {
        switch mode {
        case .stopped, .paused:
            if(!threeFingerLapControl){
                startTimer()
            }
        case .running:
            threeFingerLapControl ? lap() : stopTimer()
        }
    }

    @objc func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            switch mode {
            case .stopped, .paused:
                if(!swipeGestureLapControl){
                    startTimer()
                }
            case .running:
                swipeGestureLapControl ? lap() : stopTimer()
            }
        default:
            break
        }
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            print("sender state ended")
            switch mode {
            case .stopped, .paused:
                if(!panGestureLapControl){
                    startTimer()
                }
            case .running:
                panGestureLapControl ? lap() : stopTimer()
            }
        }
    }

    // MARK: Control Foreground/Background
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            if mode == .running {
                let timeInterval = Date().timeIntervalSince(mSecForBackground!)
                var ms = Double(timeInterval)
                ms = round(ms * 100) / 100

                // 若干の誤差があるので0.05sだけ足す
                self.secondsElapsed += (ms + 0.05)
                // 全体のタイマーをスタート
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: true)

                if splitMode == .running {
                    self.secondsSplitElapsed += (ms + 0.05)
                    // スプリットタイマーをスタート
                    splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer(_:)), userInfo: nil, repeats: true)
                }
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
    
    // MARK: - App Function
    private func copyLap() {
        UIPasteboard.general.string = copyTargetText
        let alertController:UIAlertController =
                    UIAlertController(title:"Lap Copied!",
                                      message: nil,
                              preferredStyle: .alert)
        let defaultAction:UIAlertAction =
                    UIAlertAction(title: "OK",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                })
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - START
    private func startTimer() {
        mode = .running
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
        if splitMode == .paused && !laps.isEmpty {
            splitMode = .running
            splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(splitTimer, forMode: RunLoop.Mode.common)
        }
        
        // スタートしたら明るくする
        resetButton.backgroundColor = .lightGray
        resetButton.setTitleColor(.white, for: .normal)

        // 一時的にfalse
        copyButton.isEnabled = false

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // ストップウォッチ稼働時は別画面に遷移できないようにする
        self.tabBarController!.tabBar.items![1].isEnabled = false
        self.tabBarController!.tabBar.items![2].isEnabled = false
    }
    
    // MARK: - RESET
    private func resetTimer() {
        // 最後にストップしたところまでのラップを入れる
        lap()
        timer.invalidate()
        splitTimer.invalidate()
        secondsElapsed = 0.0
        secondsSplitElapsed = 0.0
        
        // Save Laps to Local Storage
        let object:RecordModel = RecordModel()
        let recordLap = List<Lap>()
        let totalTime:String = "\(self.minute.text!):\(self.second.text!).\(self.mSec.text!)"

        for i in lapsForOutput {
            let lap = Lap()
            lap.time = i
            recordLap.append(lap)
        }

        // 記録した時刻,ラップを入れる
        object.date = Date()
        object.laps = recordLap
        object.totalTime = totalTime
        try! realmInstance.write {
            realmInstance.add(object)
        }
        
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
        
        resetButton.backgroundColor = .systemGray
        resetButton.setTitleColor(.lightGray, for: .normal)

        copyButton.isEnabled = false
        
        // lap reset
        laps.removeAll(keepingCapacity: false)
        lapsForOutput.removeAll(keepingCapacity: false)
        tableView.reloadData()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // 別画面に遷移できるように変更
        self.tabBarController!.tabBar.items![1].isEnabled = true
        self.tabBarController!.tabBar.items![2].isEnabled = true
    }
    
    // MARK: - STOP
    private func stopTimer() {
        timer.invalidate()
        splitTimer.invalidate()
        mode = .paused
        splitMode = laps.isEmpty ? .stopped : .paused

        copyButton.isEnabled = true
        
        var lapText: String = ""
        var num: Int = 1
        for val in lapsForOutput {
            lapText += "Lap\(num):  \(val)\n"
            num += 1
        }
        lapText += "Lap\(num):  \(OutputLapText(removeSpace: true))"
        copyTargetText = lapText

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        self.tabBarController!.tabBar.items![1].isEnabled = true
        self.tabBarController!.tabBar.items![2].isEnabled = true
    }
    
    // MARK: - LAP
    private func lap() {
        switch splitMode {
        case .running:
            secondsSplitElapsed = 0.0
        case .stopped, .paused:
            splitMode = .running
            splitTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSplitTimer(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(splitTimer, forMode: RunLoop.Mode.common)
        }
        laps.insert(OutputLapText(removeSpace: false), at: 0)
        lapsForOutput.append(OutputLapText(removeSpace: true))
        tableView.reloadData()
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
}

// MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate {
    private func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
        cell.backgroundColor = self.view.backgroundColor
        cell.textLabel?.text = "Lap \(laps.count - indexPath.row)"
        cell.detailTextLabel?.text = "\(laps[indexPath.row])"
        cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        cell.detailTextLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
}
