//
//  DetailViewController.swift
//  VolumeWatch
//
//  Created by 荻野隼 on 2021/06/09.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recordDate: String!
    var laps: List<Lap>!
    var copyTargetText: String! = ""
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordDateLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        recordDateLabel.text = recordDate
    }
    
    // 追加 画面が表示される際などにtableViewのデータを再読み込みする
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        var num:Int = 1
        for i in laps {
            copyTargetText += "Lap\(num) \(String(i.time!))\n"
            num += 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // todoItemの数 = セルの数
        return laps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let object = laps[indexPath.row]
        cell.textLabel?.text = "Lap \(indexPath.row + 1)"
        cell.detailTextLabel?.text = object.time
        return cell
    }
    
    // MARK: - copyLap()
    @IBAction func copyLap() {
        UIPasteboard.general.string = copyTargetText
        let alertController:UIAlertController =
                    UIAlertController(title:"Lap Copied!",
                                      message: nil,
                              preferredStyle: .alert)
        let defaultAction:UIAlertAction =
                    UIAlertAction(title: "OK",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                })
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
