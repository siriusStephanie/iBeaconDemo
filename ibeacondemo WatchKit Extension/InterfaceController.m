//
//  InterfaceController.m
//  iBeaconDemo WatchKit Extension
//
//  Created by Siri Cao on 15/8/15.
//  Copyright © 2015年 tencent. All rights reserved.
//

#import "InterfaceController.h"
#import "ExtensionDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface RowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *rssiLabel;

@end

@interface InterfaceController()<CLLocationManagerDelegate>

@property (nonatomic, strong) WCSession *session;
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if ([WCSession isSupported]) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (IBAction)sendAction {
    [self.session sendMessage:@{@"name" : @"siri"} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
    [self.session transferUserInfo:@{@"name" : @"siri"}];
    
    [self.session updateApplicationContext:@{@"name" : @"siri"} error:nil];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.repeatInterval = NSCalendarUnitDay;
    [notification setAlertBody:@"Hello world"];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)startToScan {
    [self.session transferUserInfo:@{@"scan" : @"start"}];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[userInfo[@"Count"] integerValue]] withRowType:@"rowController"];
    RowController *row = [self.table rowControllerAtIndex:[userInfo[@"Count"] integerValue]];
    [row.nameLabel setText:[NSString stringWithFormat:@"Name: %@", userInfo[@"Name"]]];
    [row.rssiLabel setText:[NSString stringWithFormat:@"RSSI: %@", userInfo[@"RSSI"]]];
}

@end
















