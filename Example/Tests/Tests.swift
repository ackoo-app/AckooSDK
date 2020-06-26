import XCTest
import Quick
import Nimble
import AckooSDK

class TableOfContentsSpec: QuickSpec {
    override func spec() {
    describe("these will fail") {
            context("these will pass") {

                       
                       it("will eventually pass") {
                           
                           var suc:Bool = false
                          let item:OrderItem = OrderItem.init(sku: "CM01-R", name: "Default Product", amount: 13.35)
                          let date:TimeInterval = Date().timeIntervalSince1970
                          let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
                          let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com", order: order)
                         

                        waitUntil (timeout: 5) { done in
                                AckooSDKManager.shared().reportActivity(type: .purchase, activity: activity) { (succeeded, response) in
                                    suc = succeeded
                                    expect(succeeded).to(beTrue())
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
