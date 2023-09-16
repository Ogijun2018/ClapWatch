//
//  SplitTimerView.swift
//  ClapWatch
//
//  Created by Jun Ogino on 2023/09/16.
//

import Foundation
import UIKit

final class SplitTimerView: UIView {
    var minute: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    private let colon: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    var second: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    private let dott: UILabel = {
        let label = UILabel()
        label.text = "."
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    var mSec: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont(name: "Avenir Next Regular", size: 28)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    init() {
        super.init(frame: .zero)

        let objects = [
            "minute": minute,
            "colon": colon,
            "second": second,
            "dot": dott,
            "mSec": mSec
        ]

        objects.forEach {
            self.addSubview($1)
            $1.translatesAutoresizingMaskIntoConstraints = false
        }

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[minute]-5-[colon]-5-[second(==minute)]-5-[dot]-5-[mSec(==minute)]|", metrics: nil, views: objects))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[minute]|", metrics: nil, views: objects))
        minute.centerYAnchor.constraint(equalTo: second.centerYAnchor).isActive = true
        minute.centerYAnchor.constraint(equalTo: mSec.centerYAnchor).isActive = true
        minute.centerYAnchor.constraint(equalTo: dott.centerYAnchor).isActive = true
        minute.centerYAnchor.constraint(equalTo: colon.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
