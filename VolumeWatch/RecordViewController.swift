//
//  RecordViewController.swift
//  VolumeWatch
//
//  Created by 荻野隼 on 2021/05/11.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class RecordViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    var savedString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = savedString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
