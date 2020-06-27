# AckooSDK

[![CI Status](https://img.shields.io/travis/mihirpmehta/AckooSDK.svg?style=flat)](https://travis-ci.org/mihirpmehta/AckooSDK)
[![Version](https://img.shields.io/cocoapods/v/AckooSDK.svg?style=flat)](https://cocoapods.org/pods/AckooSDK)
[![License](https://img.shields.io/cocoapods/l/AckooSDK.svg?style=flat)](https://cocoapods.org/pods/AckooSDK)
[![Platform](https://img.shields.io/cocoapods/p/AckooSDK.svg?style=flat)](https://cocoapods.org/pods/AckooSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AckooSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AckooSDK'
```

## Usage

### AppDelegate

Implement continue userActivity in your Appdelegate class or 

```
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    print("Continue User Activity called: ")
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
        let url = userActivity.webpageURL!
        print(url.absoluteString)
    }
}

func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    print("Continue User Activity called: ")
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
        let url = userActivity.webpageURL!
        print(url.absoluteString)
    }
}

```
From here you will get information for which product the user has opened you application. 

### Tracking user events

When user performs any activity. You need to pass on this information to the AckooSDK. Currently SDK supports following events

```

/// Type of the event that AckooSDK supports. Which will be sent
/// When usere performs the particular action (like register, open app, login, purchase)
public enum AckooEventType {
    /// When user installs application
    case installApp
    
    /// When user opens app
    case openApp
    
    /// When user registers itself with the system
    case register
    
    /// when user logs-in in the app
    case login
    
    /// When user make the actual purchase of the item
    case purchase
}

```
For any of the event to report to the SDK , You need to create instance of UserActivity class. 

```
/// User activity that holds information regarding user's actions
public class UserActivity:BaseActivity {
    
   
    /// wether user is logged In at the time of performing this activity
    var isLoggedIn:Bool
    
    /// email address of the user
    var email:String?
    
    
    /// Order details
    var orderDetail:Order?
    
}

```
In case of Reporting actual purchase event to Ackoo you need to create 2 other object 

There are 2 other instance of the class which needs to be created along with UserActivity in case of user has actually purchase anything from the app.

```
/// Order details
/// Information regarding purchased order
public class Order:Codable {
    /// Order Id
    let id:String
    
    /// Total amount of all the order items
    var totalAmount:Double?
    
    /// currency string (USD, GBP, EUR)
    var currencySymbol:String?
    
    /// Order Item
    var items:[OrderItem]
    
    /// order created date and time in UTC
    var createdOn:TimeInterval
    
    /// order last modified date and time in UTC
    var modifiedOn:TimeInterval
    
    
    /// order validated date and time in UTC
    var validatedOn:TimeInterval?
    
}

/// Order item with details like sku, name amount
public class OrderItem:Codable {
    

    /// sku of the product
    let sku:String
    
    /// product name
    let name:String
    
    /// total amount
    let amount:Double
}

```
Once this instance are created with related information. You need to register this event toSDK
For reporting purchase you need to call **reportPurchase**

```
let date:TimeInterval = Date().timeIntervalSince1970
let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com")
let item:OrderItem = OrderItem.init(sku: "CM01-R", name: productName, amount: 13.35)
let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
AckooSDKManager.shared().reportPurchase(type: name, activity: activity, order: order) { (succeeded, response) in
   print(succeeded)
}

           
```           
For reporting normal events like login, openApp etc call **reportActivity**

```

 
 let date:TimeInterval = Date().timeIntervalSince1970

 let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com")
 
 let item:OrderItem = OrderItem.init(sku: "CM01-R", name: appDelegate.productName ?? "Default Product", amount: 13.35)
  let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
 AckooSDKManager.shared().reportPurchase(type: name, activity: activity, order: order) { (succeeded, response) in
     print(succeeded)
 }
 
 

```



## Author

Ackoo, mihirpmehta@gmail.com

## License

AckooSDK is available under the MIT license. See the LICENSE file for more info.
