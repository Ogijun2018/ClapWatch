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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordDateLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(laps.count)
        recordDateLabel.text = recordDate
    }
    
    // 追加 画面が表示される際などにtableViewのデータを再読み込みする
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // todoItemの数 = セルの数
        return laps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let object = laps[indexPath.row]
        cell.textLabel?.text = object.time
        return cell
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
