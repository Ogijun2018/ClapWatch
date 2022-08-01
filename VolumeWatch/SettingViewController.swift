//
//  SettingViewController.swift
//  VolumeWatch
//
//  Created by jun.ogino on 2022/07/27.
//

import UIKit
import IntentsUI

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addSiriButton(to: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func addSiriButton(to view: UIView) {
        if #available(iOS 12.0, *) {
            let button = INUIAddVoiceShortcutButton(style: .whiteOutline)
            button.shortcut = INShortcut(intent: intent)
            button.delegate = self
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            // Button Viewの縦方向の中心は、親ビューの下端から30ptの位置
            button.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -200.0).isActive = true
            view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        }
    }
    @IBOutlet weak var proxymitySwitch: UISwitch!
    @IBOutlet weak var shakeSwitch: UISwitch!
    @IBOutlet weak var twoFingerTapSwitch: UISwitch!
    @IBOutlet weak var threeFingerTapSwitch: UISwitch!

    @IBAction func proxymitySwitch(_ sender: UISwitch) {
        if let controller = tabBarController?.viewControllers?[0] as? MainViewController {
            controller.resetSensor()
            if sender.isOn {
                controller.enableProximitySensor()
                shakeSwitch.setOn(false, animated: true)
                threeFingerTapSwitch.setOn(false, animated: true)
                twoFingerTapSwitch.setOn(false, animated: true)
            }
        }
    }
    @IBAction func shakeSwitch(_ sender: UISwitch) {
        if let controller = tabBarController?.viewControllers?[0] as? MainViewController {
            controller.resetSensor()
            if sender.isOn {
                controller.enableShakeGesture()
                proxymitySwitch.setOn(false, animated: true)
                threeFingerTapSwitch.setOn(false, animated: true)
                twoFingerTapSwitch.setOn(false, animated: true)
            }
        }
    }
    @IBAction func twoFingerTapSwitch(_ sender: UISwitch) {
        if let controller = tabBarController?.viewControllers?[0] as? MainViewController {
            controller.resetSensor()
            if sender.isOn {
                controller.enableTwoFingerTap()
                proxymitySwitch.setOn(false, animated: true)
                threeFingerTapSwitch.setOn(false, animated: true)
                shakeSwitch.setOn(false, animated: true)
            }
        }
    }
    @IBAction func threeFingerTapSwitch(_ sender: UISwitch) {
        if let controller = tabBarController?.viewControllers?[0] as? MainViewController {
            controller.resetSensor()
            if sender.isOn {
                controller.enableThreeFingerTap()
                proxymitySwitch.setOn(false, animated: true)
                twoFingerTapSwitch.setOn(false, animated: true)
                shakeSwitch.setOn(false, animated: true)
            }
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
