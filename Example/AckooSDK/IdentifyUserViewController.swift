//
//  IdentifyUserViewController.swift
//  AckooSDK_Example
//
//  Created by Aly on 10/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import AckooSDK
import Eureka
import Fakery
import UIKit

class IdentifyUserViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let faker = Faker()

        TextRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        EmailRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }

        form +++ Section("Identify User Form")
            <<< TextRow("userId") {
                $0.title = "User Id"
                $0.placeholder = "Enter User Id"
                $0.add(rule: RuleRequired())
            }
            <<< TextRow("name") {
                $0.title = "Name"
                $0.placeholder = "Enter Name"
                $0.add(rule: RuleRequired())
            }
            <<< EmailRow("email") {
                $0.title = "Email"
                $0.placeholder = "Enter Email"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleEmail())
            }
            <<< ButtonRow {
                $0.title = "Identify"
            }.onCellSelection { _, _ in
                let errors = self.form.validate()
                if errors.count > 0 {
                    print("form invalid")
                } else {
                    let values: [String: Any] = self.form.values() as [String: Any]
                    AckooSDKManager.shared.identify(id: values["userId"] as! String, profile: values) { succeeded, response in
                        print(succeeded, response)
                    }
                }
            }
            <<< ButtonRow {
                $0.title = "Randomize"
            }.onCellSelection { _, _ in
                print([
                    "userId": faker.lorem.word(),
                    "name": faker.name.name(),
                    "email": faker.internet.email(),
                ])
                self.form.setValues([
                    "userId": faker.lorem.word(),
                    "name": faker.name.name(),
                    "email": faker.internet.email(),
                ])
                self.tableView.reloadData()
            }
    }
}
