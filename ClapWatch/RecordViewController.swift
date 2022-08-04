//
//  RecordViewController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2021/05/11.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import RealmSwift

class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var recordTableView: UITableView!
    var ItemList: Results<RecordModel>!
    
    override func viewDidAppear(_ animated: Bool) {
        self.recordTableView.reloadData()
        self.recordTableView.rowHeight = 60
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ItemList.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                    do{
                        let realm = try Realm()
                        try realm.write {
                            realm.delete(self.ItemList[indexPath.row])
                        }
                        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                    }catch{
                    }
                    completionHandler(true)
                }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "TableViewCell")
        let item: RecordModel = self.ItemList[(indexPath as NSIndexPath).row]
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "clock")
        let fullString = NSMutableAttributedString(attachment: imageAttachment)
        fullString.append(NSAttributedString(string: " \(item.totalTime!)"))
        let f = DateFormatter()
        f.dateFormat = "y/M/d HH:mm:ss"
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = self.view.backgroundColor
        cell.textLabel?.text = f.string(from: item.date!)
        cell.detailTextLabel?.attributedText = fullString
        cell.textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        cell.detailTextLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        
        return cell
    }
    
    var recordDate: String?
    var laps: List<Lap>?
    var totalTime: String?
    
    // Cell が選択された場合
    func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: RecordModel = self.ItemList[(indexPath as NSIndexPath).row]
        let f = DateFormatter()
        f.dateFormat = "y/M/d HH:mm"
        // 記録日とラップを渡す
        recordDate = f.string(from: item.date!)
        laps = item.laps
        totalTime = item.totalTime!
        if recordDate != nil && laps != nil && totalTime != nil {
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
            subVC.totalTime = totalTime
            subVC.laps = laps
        }
    }
}
