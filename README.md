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

Implement **application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {** in your Appdelegate class or SceneDelegate class

```swift
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

### Tracking user events in Native Swift or Objective-C app

When user performs any activity. You need to pass on this information to the AckooSDK. Currently SDK supports following events

```swift

/// Type of the event that AckooSDK supports. Which will be sent
/// When usere performs the particular action (like register, open app, login, purchase)
public enum AckooEventType {
    /// When user installs application
    case installApp
    
    /// When user opens app
    case openApp
    
    /// when user logs-in in the app
    case login
    
    /// When user make the actual purchase of the item
    case purchase
}

```
You can check if the current user is valid AckooSDK user or not by calling below method 
```swift
AckooSDKManager.shared().isUserValidForSDK { (isValid) in
    if (isValid) {
        //report the activity or purchase
    }
}
```
For any of the event to report to the SDK , You need to create instance of UserActivity class. 

```swift
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

```swift
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
Once this instance are created with related information. You need to register this event to SDK
For reporting purchase you need to call **reportPurchase**

```swift
let date:TimeInterval = Date().timeIntervalSince1970
let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com")
let item:OrderItem = OrderItem.init(sku: "CM01-R", name: productName, amount: 13.35)
let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
AckooSDKManager.shared().reportPurchase(type: name, activity: activity, order: order) { (succeeded, response) in
   print(succeeded)
}

           
```           
For reporting normal events like login, openApp etc call **reportActivity**

```swift
 let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com")
 AckooSDKManager.shared().reportActivity(type: name, activity: activity) { (succeeded, response) in
     print(succeeded)
 }
```

### Tracking user events from React-Native apps

If your application is using react-native app. You can use specially designed **RNAckooSDKManager** class and it's method for ReactNative project integration

You will need to create Objective-C bridging file (.m) inside your iOS project and add following method to export

``` objc

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
//RCTResponseSenderBlock
@interface RCT_EXTERN_MODULE(RNAckooSDKManager, NSObject)
RCT_EXTERN_METHOD(reportActivity:(NSDictionary *)values RNCallBack: (RCTResponseSenderBlock)callback);
RCT_EXTERN_METHOD(reportPurchase:(NSDictionary *)values RNCallBack: (RCTResponseSenderBlock)callback);
RCT_EXTERN_METHOD(isTheUSerValidForAckooSDK: (RCTResponseSenderBlock)RNCallBack);
@end

```
You can than call these methods directly from the javascript js code




``` javascript
import {NativeModules} from 'react-native';

...
...

//Checking if the use is valid Ackoo user
NativeModules.RNAckooSDKManager.isTheUSerValidForAckooSDK(
  (error, ...value) => {
    console.log('error is ' + error);
    console.log('value is ' + value);
  },
);


//report user activity
const event = {type: 2, email: 'info@ackoo.app', IsLoggedIn: false};
console.log('Before Calling Native 12345');
NativeModules.RNAckooSDKManager.reportActivity(event, (error, ...values) => {
  console.log('reportActivity error is ' + JSON.stringify(error));
  console.log('reportActivity value is ' + JSON.stringify(values));
});


//Report actual purchase
const items = [{productName: 'Game-Console', sku: '45d04kl4', amount: 35.67}];
const order = {
  orderItems: items,
  orderId: '053509034',
  totalAmount: 35.67,
  symbol: 'USD',
  createdOn: 1595348752205,
  modifiedOn: 1595348752205,
  validateOn: 1595348752205,
};

NativeModules.RNAckooSDKManager.reportPurchase(order, (error, ...values) => {
  console.log('reportPurchase error is ' + JSON.stringify(error));
  console.log('reportPurchase value is ' + JSON.stringify(values));
});
```




## Importan Note
This SDK uses advertisingIdentifier for purpose if identifying user after fresh installation after navigating from the Ackoo app. When you submit the app please tick **"Attribute this App Installation to a Previously Served Advertisement"** Please refer this screen shot

![App_Submission_IDFA](https://user-images.githubusercontent.com/1177076/85919226-24758a00-b887-11ea-985c-fa2895c10e99.png)


## Author

Ackoo, khaled@ackoo.app


