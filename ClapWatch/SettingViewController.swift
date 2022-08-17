//
//  SettingViewController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2022/07/27.
//

import UIKit
import IntentsUI

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addSiriButton(to: self.view)
        tableView.allowsMultipleSelection = true
        self.navigationItem.title = "Setting"
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
        if let controller = tabBarController?.viewControllers?[0] as? MainViewController {
            controller.resetSensor()
            for index in selectedIndexPaths {
                let isLap = index.section == 0 ? false : true
                switch index.row {
                case 0: controller.enableProximitySensor(isLap)
                case 1: controller.enableShakeGesture(isLap)
                case 2: controller.enableTwoFingerTap(isLap)
                case 3: controller.enableThreeFingerTap(isLap)
                case 4: controller.enableSwipeGesture(isLap)
                case 5: controller.enablePanGesture(isLap)
                default: break
                }
            }
        }
    }

    func resetSensor() {
        if let controller = tabBarController?.viewControllers?[0] as? MainViewController {
            controller.resetSensor()
        }
    }

    // MARK: TableView
    let sectionTitle = ["Start/Stop", "Lap"]
    let icons = ["sensor.tag.radiowaves.forward", "waveform.path", "2.square", "3.square", "hand.draw.fill", "hand.draw.fill"]
    let labels = ["近接センサー", "シェイク", "2本指タップ", "3本指タップ", "上方向スワイプ", "パン"]

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
            print("reset all sensor")
            resetSensor()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "settingTableCell", for: indexPath)
        let img = UIImage(systemName:icons[indexPath.row])
        cell.imageView?.image = img
        cell.textLabel?.text = labels[indexPath.row]
        return cell
    }

    func addSiriButton(to view: UIView) {
        if #available(iOS 12.0, *) {
            let button = INUIAddVoiceShortcutButton(style: .whiteOutline)
            button.shortcut = INShortcut(intent: intent)
            button.delegate = self
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120.0).isActive = true
            view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        }
    }
}

extension SettingViewController {
    @available(iOS 12.0, *)
    public var intent: BackTapIntent {
        let backTapIntent = BackTapIntent()
        backTapIntent.suggestedInvocationPhrase = "スイッチ"
        return backTapIntent
    }
}

extension SettingViewController: INUIAddVoiceShortcutButtonDelegate {
    @available(iOS 12.0, *)
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }

    @available(iOS 12.0, *)
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }


}

extension SettingViewController: INUIAddVoiceShortcutViewControllerDelegate {
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }


}

extension SettingViewController: INUIEditVoiceShortcutViewControllerDelegate {
    @available(iOS 12.0, *)
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    @available(iOS 12.0, *)
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }

    @available(iOS 12.0, *)
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
