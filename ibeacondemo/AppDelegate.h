//
//  AppDelegate.h
//  iBeaconDemo
//
//  Created by Siri Cao on 15/8/15.
//  Copyright © 2015年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, WCSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) WCSession *session;

@end

