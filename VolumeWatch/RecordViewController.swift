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
//        self.label.text = String(self.ItemList.count)
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
        f.timeStyle = .full
        f.dateStyle = .full
        f.locale = Locale(identifier: "ja_JP")
        cell.accessoryType = .detailDisclosureButton
        cell.backgroundColor = self.view.backgroundColor
        cell.textLabel?.text = f.string(from: item.date!)
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 15)
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 15)
        
        return cell
    }
    
    var selectedRow: String?
    
    // Cell が選択された場合
    override func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        // [indexPath.row] から画像名を探し、UImage を設定
        selectedRow = "AAAAA"
        if selectedRow != nil {
            // SubViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "Segue",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "Segue") {
            let subVC: DetailViewController = (segue.destination as? DetailViewController)!
            // SubViewController のselectedImgに選択された画像を設定する
            subVC.selectedRow = selectedRow
        }
    }
}
