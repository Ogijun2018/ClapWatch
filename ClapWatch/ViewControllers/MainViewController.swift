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

    var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        return button
    }()
    
    var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        return button
    }()

    var timerView = TimerView()
    var splitTimerView = SplitTimerView()
    var tableView = UITableView()

    var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "doc.on.clipboard", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        button.isEnabled = false
        return button
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
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.viewController = self

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
            "timer": timerView,
            "spTimer": splitTimerView,
            "right": rightButton,
            "left": leftButton,
            "copy": copyButton,
            "table": tableView
        ]

        view.addSubview(copyButton)
        view.addSubview(timerView)
        view.addSubview(splitTimerView)
        view.addSubview(rightButton)
        view.addSubview(leftButton)
        view.addSubview(tableView)

        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
       
        objects.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[copy(==50)]-20-|", metrics: nil, views: objects))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[left]-30-[right(==left)]-50-|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[timer]-(>=0)-|", metrics: nil, views: objects))
        timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        splitTimerView.trailingAnchor.constraint(equalTo: timerView.trailingAnchor, constant: -5).isActive = true

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[copy(==50)]-20-[timer][spTimer]-30-[right(==70)]-30-[table]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[copy(==50)]-20-[timer][spTimer]-30-[left(==70)]-30-[table]", metrics: nil, views: objects))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", metrics: nil, views: objects))
        
        rightButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.viewModel.rightButtonDidTap()
        }, for: .touchUpInside)
        
        leftButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.viewModel.leftButtonDidTap()
        }, for: .touchUpInside)

        copyButton.addAction(.init { [weak self] _ in
            self?.copyLap()
        }, for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        viewModel.$mainWatchTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self else { return }
                self.timerView.minute.text = time.stringMinute
                self.timerView.second.text = time.stringSecond
                self.timerView.mSec.text = time.stringMilliSecond
        }.store(in: &cancellables)

        viewModel.$splitWatchTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self else { return }
                self.splitTimerView.minute.text = time.stringMinute
                self.splitTimerView.second.text = time.stringSecond
                self.splitTimerView.mSec.text = time.stringMilliSecond
        }.store(in: &cancellables)

        viewModel.$tabBarButtonEnabled
            .sink { [weak self] tabBarButtonEnabled in
                guard let self else { return }
                self.tabBarController!.tabBar.items![1].isEnabled = tabBarButtonEnabled
                self.tabBarController!.tabBar.items![2].isEnabled = tabBarButtonEnabled
            }.store(in: &cancellables)

        viewModel.$leftButtonBehavior.sink { [weak self] behavior in
            guard let self else { return }
            switch behavior {
            case .disabledLap:
                self.leftButton.setTitle("Lap", for: .normal)
                self.leftButton.backgroundColor = .systemGray
                self.leftButton.setTitleColor(.lightGray, for: .normal)
            case .lap:
                self.leftButton.setTitle("Lap", for: .normal)
                self.leftButton.backgroundColor = .lightGray
                self.leftButton.setTitleColor(.white, for: .normal)
            case .reset:
                self.leftButton.setTitle("Reset", for: .normal)
                self.leftButton.setTitleColor(.white, for: .normal)
            }
        }.store(in: &cancellables)

        viewModel.$rightButtonBehavior.sink { [weak self] behavior in
            guard let self else { return }
            switch behavior {
            case .start:
                self.rightButton.setTitle("Start", for: .normal)
                self.rightButton.backgroundColor = .systemGreen
            case .stop:
                self.rightButton.setTitle("Stop", for: .normal)
                self.rightButton.backgroundColor = .systemRed
            }
        }.store(in: &cancellables)

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
    @objc private func viewWillEnterForeground() {
        guard self.isViewLoaded && self.view.window != nil else { return }
        viewModel.willEnterForeground()
    }

    @objc private func viewDidEnterBackground() {
        viewModel.didEnterBackground(isViewLoaded: self.isViewLoaded, window: self.view.window)
    }

    private func copyLap() {
        let alert = UIAlertController(title:"Lap Copied!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
