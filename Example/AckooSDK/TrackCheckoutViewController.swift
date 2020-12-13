//
//  TrackCheckoutViewController.swift
//  AckooSDK_Example
//
//  Created by Aly on 10/24/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import AckooSDK
import Eureka
import Fakery
import UIKit

class TrackCheckoutViewController: FormViewController {
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
            <<< TextRow("orderId") {
                $0.title = "Item Id"
                $0.placeholder = "Enter Order Id"
                $0.add(rule: RuleRequired())
            }
            <<< IntRow("amount") {
                $0.title = "Amount"
                $0.placeholder = "Enter Amount"
                $0.add(rule: RuleRequired())
            }
            <<< SegmentedRow<String>("currency") {
            $0.title = "Currency"
            $0.options = ["USD", "KWD"]
        }
            <<< ButtonRow {
                $0.title = "Track Checkout"
            }.onCellSelection { _, _ in
                let errors = self.form.validate()
                if errors.count > 0 {
                    print("form invalid")
                } else {
                    var values: [String: Any] = self.form.values() as [String: Any]
                    values["items"] = true
                    AckooSDKManager.shared.trackCheckout(values) { succeeded, error in
                        if succeeded {
                            self.showAlert(title: "success", message: "track checkout successful")
                        } else if let error = error {
                            self.showAlert(title: "error", message: error.message)
                        }
                    }
                }
            }
            <<< ButtonRow {
                $0.title = "Randomize"
            }.onCellSelection { _, _ in
                print(faker.number.randomDouble(min: 0, max: 10))
                print(faker.number.randomInt(min: 0, max: 10))
                self.form.setValues([
                    "orderId": faker.lorem.word(),
                    "amount": faker.number.randomInt(min: 0, max: 1000),
                    "currency": ["USD", "KWD"][faker.number.randomInt(min: 0, max: 2)],
                ])
                self.tableView.reloadData()
            }
    }
}
