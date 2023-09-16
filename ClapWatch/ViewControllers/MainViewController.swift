//
//  ViewController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2020/12/18.
//

import UIKit
import Combine
import RealmSwift

class MainViewController: UIViewController {
    
    enum stopWatchMode {
        case running
        case stopped
        case paused
    }

    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    // Haptic
    let startHaptic = UIImpactFeedbackGenerator(style: .heavy)
    let resetHaptic = UINotificationFeedbackGenerator()

    var laps: [String] = []
    var viewModel = WatchViewModel()
    var cancellables: Set<AnyCancellable> = []

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

    var swipeRecognizer = UISwipeGestureRecognizer()
    var panGestureRecognizer = UIPanGestureRecognizer()
    var tapTwoFingerRecognizer = UITapGestureRecognizer()
    var tapThreeFingerRecognizer = UITapGestureRecognizer()
    var shakeGestureEnabled: Bool = false

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
//        swipeRecognizer = UISwipeGestureRecognizer(
//            target: self,
//            action: #selector(MainViewController.handleSwipeGesture(_:))
//            )
//        swipeRecognizer.direction = .up
//        self.view.addGestureRecognizer(swipeRecognizer)
//        swipeRecognizer.isEnabled = false
//
//        // パンジェスチャー検出
//        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.handlePanGesture(_:)))
//        self.view.addGestureRecognizer(panGestureRecognizer)
//        panGestureRecognizer.isEnabled = false
//
//        // 2本指タップ検出
//        tapTwoFingerRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleTwoFingerTapGesture(_:)))
//        tapTwoFingerRecognizer.numberOfTouchesRequired = 2
//        self.view.addGestureRecognizer(tapTwoFingerRecognizer)
//        tapTwoFingerRecognizer.isEnabled = false
//
//        // 3本指タップ検出
//        tapThreeFingerRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleThreeFingerTapGesture(_:)))
//        tapThreeFingerRecognizer.numberOfTouchesRequired = 3
//        self.view.addGestureRecognizer(tapThreeFingerRecognizer)
//        tapThreeFingerRecognizer.isEnabled = false
        
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

        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
       
        objects.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[copy(==50)]-20-|", metrics: nil, views: objects))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[left]-30-[right(==left)]-50-|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[container]-(>=0)-|", metrics: nil, views: objects))
        splitTimerContainerView.trailingAnchor.constraint(equalTo: timerContainerView.trailingAnchor, constant: -5).isActive = true


        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[copy(==50)]-20-[container][splitContainer]-30-[right(==70)]-30-[table]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[copy(==50)]-20-[container][splitContainer]-30-[left(==70)]-30-[table]", metrics: nil, views: objects))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", metrics: nil, views: objects))
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
            guard let self else { return }
            self.viewModel.startButtonDidTap()
        }, for: .touchUpInside)
        
        resetButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.viewModel.resetButtonDidTap()
        }, for: .touchUpInside)

        copyButton.isEnabled = false
        copyButton.addAction(.init { [weak self] _ in
            self?.copyLap()
        }, for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.viewWillEnterForeground(
                                                _:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.viewDidEnterBackground(
                                                _:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        viewModel.$mainWatchTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self else { return }
                self.minute.text = time.stringMinute
                self.second.text = time.stringSecond
                self.mSec.text = time.stringMilliSecond
        }.store(in: &cancellables)

        viewModel.$splitWatchTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self else { return }
                self.splitMinute.text = time.stringMinute
                self.splitSecond.text = time.stringSecond
                self.splitMSec.text = time.stringMilliSecond
        }.store(in: &cancellables)

        viewModel.$mode
            .sink(receiveValue: { [weak self] mode in
                guard let self else { return }
                switch mode {
                case .paused:
                    self.startHaptic.impactOccurred()
                    self.copyButton.isEnabled = true
                    self.tabBarController!.tabBar.items![1].isEnabled = true
                    self.tabBarController!.tabBar.items![2].isEnabled = true

                    self.startButton.setTitle("Start", for: .normal)
                    self.startButton.backgroundColor = .systemGreen
                    self.resetButton.setTitle("Reset", for: .normal)
                case .running:
                    self.startHaptic.impactOccurred()
                    // スタートしたら明るくする
                    self.resetButton.backgroundColor = .lightGray
                    self.resetButton.setTitleColor(.white, for: .normal)
                    // 一時的にfalse
                    self.copyButton.isEnabled = false
                    // ストップウォッチ稼働時は別画面に遷移できないようにする
                    self.tabBarController!.tabBar.items![1].isEnabled = false
                    self.tabBarController!.tabBar.items![2].isEnabled = false

                    self.startButton.setTitle("Stop", for: .normal)
                    self.startButton.backgroundColor = .systemRed
                    self.resetButton.setTitle("Lap", for: .normal)
                case .stopped:
                    self.resetHaptic.notificationOccurred(.success)
                    self.resetButton.backgroundColor = .systemGray
                    self.resetButton.setTitleColor(.lightGray, for: .normal)
                    self.copyButton.isEnabled = false

                    // 別画面に遷移できるように変更
                    self.tabBarController!.tabBar.items![1].isEnabled = true
                    self.tabBarController!.tabBar.items![2].isEnabled = true

                    self.resetButton.setTitle("Lap", for: .normal)
                    self.tableView.reloadData()
                }
            }).store(in: &cancellables)

        viewModel.$laps.sink { [weak self] laps in
            guard let self else { return }
            self.laps = laps
            self.tableView.reloadData()
        }.store(in: &cancellables)

        viewModel.$copyTargetText.sink { text in
            UIPasteboard.general.string = text
        }.store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(proximitySensorState), name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewModel.willDisappear()
//        NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }

    // MARK: Sensor control
//    @objc func proximitySensorState() {
//        if UIDevice.current.proximityState {
//            switch mode {
//            case .stopped, .paused:
//                if(!proximityLapControl){
//                    startTimer()
//                }
//            case .running:
//                proximityLapControl ? lap() : stopTimer()
//            }
//        }
//    }
//
//    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if shakeGestureEnabled {
//            if motion == .motionShake {
//                switch mode {
//                case .stopped, .paused:
//                    if(!shakeGestureLapControl){
//                        startTimer()
//                    }
//                case .running:
//                    shakeGestureLapControl ? lap() : stopTimer()
//                }
//            }
//        }
//    }
//
//    @objc func handleTwoFingerTapGesture(_ sender: UITapGestureRecognizer){
//        switch mode {
//        case .stopped, .paused:
//            if(!twoFingerLapControl){
//                startTimer()
//            }
//        case .running:
//            twoFingerLapControl ? lap() : stopTimer()
//        }
//    }
//
//    @objc func handleThreeFingerTapGesture(_ sender: UITapGestureRecognizer) {
//        switch mode {
//        case .stopped, .paused:
//            if(!threeFingerLapControl){
//                startTimer()
//            }
//        case .running:
//            threeFingerLapControl ? lap() : stopTimer()
//        }
//    }
//
//    @objc func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
//        switch sender.direction {
//        case .up:
//            switch mode {
//            case .stopped, .paused:
//                if(!swipeGestureLapControl){
//                    startTimer()
//                }
//            case .running:
//                swipeGestureLapControl ? lap() : stopTimer()
//            }
//        default:
//            break
//        }
//    }
//
//    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
//        if sender.state == .ended {
//            print("sender state ended")
//            switch mode {
//            case .stopped, .paused:
//                if(!panGestureLapControl){
//                    startTimer()
//                }
//            case .running:
//                panGestureLapControl ? lap() : stopTimer()
//            }
//        }
//    }

    // MARK: Control Foreground/Background
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        guard self.isViewLoaded && self.view.window != nil else { return }
        viewModel.willEnterForeground()
    }

    @objc func viewDidEnterBackground(_ notification: Notification?) {
        viewModel.didEnterBackground(isViewLoaded: self.isViewLoaded, window: self.view.window)
    }
    
    // MARK: - App Function
    private func copyLap() {
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
}

// MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
