//
//  RecordViewController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2021/05/11.
//

import Foundation
import UIKit
import RealmSwift

class RecordViewController: UIViewController {
    private var recordTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 60
        return tableView
    }()
    var ItemList: Results<RecordModel>!

    var emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No Records"
        label.textColor = .gray
        return label
    }()
    var recordDate: String?
    var laps: List<Lap>?
    var totalTime: String?

    override func viewDidAppear(_ animated: Bool) {
        recordTableView.reloadData()

        if(!self.ItemList.isEmpty){
            emptyLabel.isHidden = true
        }
    }

   @objc func deleteRecords(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Delete all records", comment: ""), message: NSLocalizedString("Are you sure to delete all records?", comment: ""), preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            self.recordTableView.reloadData()
            self.emptyLabel.isHidden = false
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let RealmInstance1 = try! Realm()
        self.ItemList = RealmInstance1.objects(RecordModel.self)
        self.navigationItem.title = NSLocalizedString("Records", comment: "")
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationController?.navigationBar.prefersLargeTitles = true

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteRecords(_:)))

        let objects = [
            "label": emptyLabel,
            "table": recordTableView
        ]

        view.addSubview(recordTableView)
        view.addSubview(emptyLabel)

        recordTableView.delegate = self
        recordTableView.dataSource = self

        objects.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", metrics: nil, views: objects))
        emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: RecordModel = self.ItemList[(indexPath as NSIndexPath).row]
        guard let date = item.date, let totalTime = item.totalTime else { return }
        let f = DateFormatter()
        f.dateFormat = "y/M/d HH:mm"
        let vc = DetailViewController(recordDate: f.string(from: date),
                                      laps: item.laps,
                                      totalTime: totalTime)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
}
