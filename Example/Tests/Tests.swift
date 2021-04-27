import AckooSDK
import Nimble
import Quick
import XCTest

class TableOfContentsSpec: QuickSpec {
    override func setUp() {
        super.setUp()
    }

    override func spec() {
        describe("these will fail") {
            context("these will pass") {
                UserDefaults.standard.removeObject(forKey: "AckooSDKSessionToken")
                UserDefaults.standard.synchronize()
                it("Will call purchas event") {
                    let item: OrderItem = OrderItem(sku: "CM01-R", name: "Default Product", amount: 13.35)
                    let date: TimeInterval = Date().timeIntervalSince1970
                    let order: Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn: date, modifiedOn: date, validatedOn: date)
                    let activity: UserActivity = UserActivity(isLoggedIn: true, email: "user@gmail.com")
                    waitUntil(timeout: 10) { done in
                        AckooSDKManager.shared().reportPurchase(type: .purchase, activity: activity, order: order) { succeeded, _ in
                            expect(succeeded).to(beTrue())
                            done()
                        }
                    }
                }

                it("Will call purchas event after user default") {
                    let item: OrderItem = OrderItem(sku: "CM01-R", name: "Default Product", amount: 13.35)
                    let date: TimeInterval = Date().timeIntervalSince1970
                    let order: Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn: date, modifiedOn: date, validatedOn: date)
                    let activity: UserActivity = UserActivity(isLoggedIn: true, email: "user@gmail.com")
                    waitUntil(timeout: 30) { done in
                        AckooSDKManager.shared().reportPurchase(type: .purchase, activity: activity, order: order) { succeeded, _ in
                            expect(succeeded).to(beTrue())
                            done()
                        }
                    }
                }

                it("will call open event") {
                    UserDefaults.standard.removeObject(forKey: "AckooSDKSessionToken")
                    UserDefaults.standard.synchronize()
                    let activity: UserActivity = UserActivity(isLoggedIn: true, email: "user@gmail.com")
                    waitUntil(timeout: 30) { done in
                        AckooSDKManager.shared().reportActivity(type: .openApp, activity: activity) { succeeded, _ in
                            expect(succeeded).to(beTrue())
                            done()
                        }
                    }
                }

                it("will call open event after use default") {
                    UserDefaults.standard.removeObject(forKey: "AckooSDKSessionToken")
                    UserDefaults.standard.synchronize()
                    let activity: UserActivity = UserActivity(isLoggedIn: true, email: "user@gmail.com")
                    waitUntil(timeout: 30) { done in
                        AckooSDKManager.shared().reportActivity(type: .openApp, activity: activity) { succeeded, _ in
                            expect(succeeded).to(beTrue())
                            done()
                        }
                    }
                }

                it("will eventually fail") {
                    let activity: UserActivity = UserActivity(isLoggedIn: true, email: "user@gmail.com")
                    waitUntil(timeout: 30) { done in
                        AckooSDKManager.shared().reportActivity(type: .installApp, activity: activity) { succeeded, _ in
                            expect(succeeded).to(beFalse())
                            done()
                        }
                    }
                }
            }
        }
    }
}

// class Tests: QuickSpec {
//
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//
//
//
//
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure() {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
// }
