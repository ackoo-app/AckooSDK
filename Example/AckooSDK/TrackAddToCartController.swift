//
//  TrackItemViewController.swift
//  AckooSDK_Example
//
//  Created by Aly on 10/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import AckooSDK
import Eureka
import Fakery
import UIKit

class TrackAddToCartViewController: FormViewController {
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
        IntRow.defaultCellUpdate = { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }

        form +++ Section("track add to cart Form")
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
            <<< DecimalRow("price") {
                $0.title = "Price"
                $0.placeholder = "Enter Price"
                $0.add(rule: RuleRequired())
            }
            <<< IntRow("quantity") {
                $0.title = "Quantity"
                $0.placeholder = "Enter Quantity"
                $0.add(rule: RuleRequired())
            }

            <<< SegmentedRow<String>("currency") {
            $0.title = "Currency"
            $0.options = ["USD", "KWD"]
        }
            <<< ButtonRow {
                $0.title = "Identify"
            }.onCellSelection { _, _ in
                let errors = self.form.validate()
                if errors.count > 0 {
                    print("form invalid")
                } else {
                    let values: [String: Any] = self.form.values() as [String: Any]
                    AckooSDKManager.shared.trackAddToCart(values) { succeeded, response in
                        if succeeded {
                            self.showAlert(title: "success", message: "track add item to cart successful")
                        } else {
                            print(response)
                            self.showAlert(title: "error", message: "track add item to cart failed")
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
                    "quantity": faker.number.randomInt(min: 0, max: 10),
                    "price": faker.number.randomDouble(min: 0, max: 1000),
                    "currency": ["USD", "KWD"][faker.number.randomInt(min: 0, max: 2)],

                ])
                self.tableView.reloadData()
            }
    }
}
