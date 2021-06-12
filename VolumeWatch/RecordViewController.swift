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
import RealmSwift

class RecordViewController: UITableViewController {
    @IBOutlet weak var recordTableView: UITableView!
    var ItemList: Results<RecordModel>!
    
    override func viewDidAppear(_ animated: Bool) {
        self.recordTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let RealmInstance1 = try! Realm()
        self.ItemList = RealmInstance1.objects(RecordModel.self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ItemList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TableViewCell")
        let item: RecordModel = self.ItemList[(indexPath as NSIndexPath).row]
        let f = DateFormatter()
        f.dateFormat = "y/M/d HH:mm:ss"
        cell.accessoryType = .detailDisclosureButton
        cell.backgroundColor = self.view.backgroundColor
        cell.textLabel?.text = f.string(from: item.date!)
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 15)
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 15)
        
        return cell
    }
    
    var recordDate: String?
    var laps: List<Lap>?
    
    // Cell が選択された場合
    override func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: RecordModel = self.ItemList[(indexPath as NSIndexPath).row]
        let f = DateFormatter()
        f.dateFormat = "y/M/d HH:mm"
        // 記録日とラップを渡す
        recordDate = f.string(from: item.date!)
        laps = item.laps
        if recordDate != nil && laps != nil {
            // SubViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "Segue",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "Segue") {
            let subVC: DetailViewController = (segue.destination as? DetailViewController)!
            // SubViewController のselectedImgに選択された画像を設定する
            subVC.recordDate = recordDate
            subVC.laps = laps
        }
    }
}
