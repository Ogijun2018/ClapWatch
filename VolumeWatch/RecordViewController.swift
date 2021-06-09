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

class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "recordCell")
        let item: RecordModel = self.ItemList[(indexPath as NSIndexPath).row]
        let f = DateFormatter()
        f.timeStyle = .full
        f.dateStyle = .full
        f.locale = Locale(identifier: "ja_JP")
        cell.backgroundColor = self.view.backgroundColor
        cell.textLabel?.text = f.string(from: item.date!)
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 15)
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 15)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            if let indexPath = recordTableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? DetailViewController else {
                    fatalError("Failed to prepare DetailViewController.")
                }
                
//                destination.result = String(ItemList[indexPath.row].time!)
            }
        }
    }
}
