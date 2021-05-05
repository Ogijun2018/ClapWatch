//
//  RecordViewController.swift
//  VolumeWatch
//
//  Created by 荻野隼 on 2021/04/27.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let TODO = ["Sample1", "Sample2", "Sample3"]
    
    // セルの個数を指定するDelegateメソッド(必須)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TODO.count
    }
    
    // セルに値を設定するデータソースメソッド(必須)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = TODO[indexPath.row]
        return cell
    }
    
    //最初からあるコード
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //最初からあるコード
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
