//
//  SettingViewController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2022/07/27.
//

import UIKit

class SettingViewController: UIViewController {

    var tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        tableView.delegate = self
        tableView.dataSource = self

        let objects = ["table": tableView]

        view.addSubview(tableView)
        objects.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", metrics: nil, views: objects))
        view.backgroundColor = .white

        self.navigationItem.title = NSLocalizedString("Setting", comment: "")
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    enum Section: Int {
        case StartStop
        case Lap
    }

    func activateSensor(_ selectedIndexPaths: [IndexPath]) {
        if let tab = self.tabBarController,
           let nav = tab.viewControllers?[0] as? UINavigationController,
           let vc = nav.viewControllers.first as? MainViewController {
            vc.resetSensor()
            for index in selectedIndexPaths {
                let isLap = index.section == 0 ? false : true
                switch index.row {
                case 0: vc.enableProximitySensor(isLap)
                case 1: vc.enableShakeGesture(isLap)
                case 2: vc.enableTwoFingerTap(isLap)
                case 3: vc.enableThreeFingerTap(isLap)
                case 4: vc.enableSwipeGesture(isLap)
                case 5: vc.enablePanGesture(isLap)
                default: break
                }
            }
        }
    }

    func resetSensor() {
        if let tab = self.tabBarController,
           let nav = tab.viewControllers?[0] as? UINavigationController,
           let vc = nav.viewControllers.first as? MainViewController {
            vc.resetSensor()
        }
    }

    let sectionTitle = ["Start/Stop", "Lap"]
    let icons = ["sensor.tag.radiowaves.forward",
                 "waveform.path",
                 "2.square",
                 "3.square",
                 "hand.draw.fill",
                 "hand.draw"]
    let labels = [NSLocalizedString("Proximity Sensor", comment: ""),
                  NSLocalizedString("Shake", comment: ""),
                  NSLocalizedString("Two-finger tap", comment: ""),
                  NSLocalizedString("Three-finger tap", comment: ""),
                  NSLocalizedString("Upward swipe", comment: ""),
                  NSLocalizedString("Flick", comment: "")]
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }

    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section){
        case .StartStop, .Lap:
            return labels.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 最初に、自分のSectionではない方の半透明になっていた選択肢を復活
        let anotherSection = indexPath.section == 0 ? 1 : 0
        for i in 0..<labels.count {
            let cell = tableView.cellForRow(at: [anotherSection, i])
            cell?.isUserInteractionEnabled = true
            cell?.alpha = 1
        }

        // どちらかのSectionで選択したオプションはもう一方では使えなくする
        let anotherSectionCell = tableView.cellForRow(at: [anotherSection, indexPath.row])
        anotherSectionCell?.accessoryType = .none
        anotherSectionCell?.isUserInteractionEnabled = false
        anotherSectionCell?.alpha = 0.3

        // 各Section内で最大1個しか選択できないようにする
        if let selectedRows = tableView.indexPathsForSelectedRows {
            let selectedInSection = selectedRows.filter { $0.section == indexPath.section }
            for deselectingIndexPath in selectedInSection {
                let cell = tableView.cellForRow(at: deselectingIndexPath)
                cell?.accessoryType = .none
                tableView.deselectRow(at: deselectingIndexPath, animated: false)
            }
        }

        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)

        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            activateSensor(selectedIndexPaths)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let anotherSection = indexPath.section == 0 ? 1 : 0
        var anotherSectionCell: UITableViewCell?
        anotherSectionCell = tableView.cellForRow(at: [anotherSection, indexPath.row])
        anotherSectionCell?.isUserInteractionEnabled = true
        anotherSectionCell?.alpha = 1

        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none

        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            activateSensor(selectedIndexPaths)
        } else {
            resetSensor()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let img = UIImage(systemName:icons[indexPath.row])
        cell.imageView?.image = img
        cell.textLabel?.text = labels[indexPath.row]
        return cell
    }
}
