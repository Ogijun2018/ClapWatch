//
//  DetailViewController.swift
//  ClapWatch
//
//  Created by jun.ogino on 2021/06/09.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController {
    var laps: List<Lap>
    var copyTargetText: String = ""

    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    var recordDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 30)
        return label
    }()
    var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 25)
        return label
    }()
    let clockImg = UIImageView(image: .init(systemName: "clock"))
    var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "doc.on.clipboard", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()

    init(recordDate: String, laps: List<Lap>, totalTime: String) {
        self.laps = laps
        super.init(nibName: nil, bundle: nil)
        recordDateLabel.text = recordDate
        totalTimeLabel.text = totalTime
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let objects = [
            "table": tableView,
            "date": recordDateLabel,
            "time": totalTimeLabel,
            "clock": clockImg,
            "copy": copyButton
        ]

        view.addSubview(tableView)
        view.addSubview(recordDateLabel)
        view.addSubview(totalTimeLabel)
        view.addSubview(clockImg)
        view.addSubview(copyButton)

        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .white

        objects.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[date]-(>=0)-|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[clock(==20)]-5-[time]-(>=0)-[copy(==50)]-20-|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", metrics: nil, views: objects))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[date]-[time]-20-[table]|", metrics: nil, views: objects))
        clockImg.centerYAnchor.constraint(equalTo: totalTimeLabel.centerYAnchor).isActive = true
        copyButton.centerYAnchor.constraint(equalTo: totalTimeLabel.centerYAnchor).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        copyButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            self.copyLap()
        }, for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        var num:Int = 1
        for i in laps {
            copyTargetText += "Lap\(num) \(String(i.time!))\n"
            num += 1
        }
    }

    private func copyLap() {
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
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let object = laps[indexPath.row]
        cell.textLabel?.text = "Lap \(indexPath.row + 1)"
        cell.detailTextLabel?.text = object.time
        cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        cell.detailTextLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        return cell
    }
}
