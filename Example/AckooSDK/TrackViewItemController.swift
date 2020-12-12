//
//  TrackViewItemController.swift
//  AckooSDK_Example
//
//  Created by Aly on 10/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import AckooSDK
import Eureka
import Fakery
import UIKit

class TrackViewItemController: FormViewController {
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                print("Alert dismissed")
            }))
            self.present(alert, animated: true)
        }
    }

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

        form +++ Section("track View Item Form")
            <<< TextRow("itemId") {
                $0.title = "Item Id"
                $0.placeholder = "Enter Item Id"
                $0.add(rule: RuleRequired())
            }
            <<< TextRow("name") {
                $0.title = "Name"
                $0.placeholder = "Enter Name"
                $0.add(rule: RuleRequired())
            }
            <<< ButtonRow {
                $0.title = "track"
            }.onCellSelection { _, _ in
                let errors = self.form.validate()
                if errors.count > 0 {
                    print("form invalid")
                } else {
                    let values: [String: Any] = self.form.values() as [String: Any]
                    AckooSDKManager.shared.trackViewItem(values) { succeeded, response in
                        if succeeded {
                            self.showAlert(title: "success", message: "track view item successful")
                        } else {
                            print(response)
                            self.showAlert(title: "error", message: "track view failed")
                        }
                    }
                }
            }
            <<< ButtonRow {
                $0.title = "Randomize"
            }.onCellSelection { _, _ in
                self.form.setValues([
                    "itemId": faker.lorem.word(),
                    "name": faker.commerce.productName(),
                ])
                self.tableView.reloadData()
            }
    }
}
