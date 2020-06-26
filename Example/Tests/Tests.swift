import XCTest
import Quick
import Nimble
import AckooSDK

class TableOfContentsSpec: QuickSpec {
    override func setUp() {
        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.synchronize()
    }
    override func spec() {
    describe("these will fail") {
            context("these will pass") {

                       
                       it("Will call purchas event") {
                          let item:OrderItem = OrderItem.init(sku: "CM01-R", name: "Default Product", amount: 13.35)
                          let date:TimeInterval = Date().timeIntervalSince1970
                          let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
                          let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com", order: order)
                         

                        waitUntil (timeout: 10) { done in
                                AckooSDKManager.shared().reportActivity(type: .purchase, activity: activity) { (succeeded, response) in
                                    expect(succeeded).to(beTrue())
                                    done()
                                                          
                                }
                              
                               
                           }
                       }
                
                    it("will call open event") {
                       let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com", order: nil)
                     waitUntil (timeout: 10) { done in
                             AckooSDKManager.shared().reportActivity(type: .openApp, activity: activity) { (succeeded, response) in
                                 expect(succeeded).to(beTrue())
                                 done()
                                                       
                             }
                           
                            
                        }
                    }
                
                it("will eventually fail") {
                   let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com", order: nil)
                 waitUntil (timeout: 10) { done in
                         AckooSDKManager.shared().reportActivity(type: .installApp, activity: activity) { (succeeded, response) in
                             expect(succeeded).to(beFalse())
                             done()
                                                   
                         }
                       
                        
                    }
                }
                
                   }
                   
        
        
        }
    }
}


//class Tests: QuickSpec {
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
//}
