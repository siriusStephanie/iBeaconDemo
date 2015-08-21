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


@interface InterfaceController()<CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *distanceLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *nameLabel;
@property (nonatomic, strong) WCSession *session;

@end


@implementation InterfaceController {
    NSMutableDictionary *_beacons;
    CLLocationManager *_locationManager;
    NSMutableArray *_rangedRegions;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if ([WCSession isSupported]) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        //Use in iOS8 or later
        [_locationManager requestAlwaysAuthorization];
    }
    
//    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
//        //Use in iOS9 or later
//        [_locationManager setAllowsBackgroundLocationUpdates:YES];
//    }
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // CoreLocation will call this delegate method at 1 Hz with updated range information.
    // Beacons will be categorized and displayed by proximity.
    [_beacons removeAllObjects];
    NSArray *unknownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityUnknown]];
    if([unknownBeacons count])
        [_beacons setObject:unknownBeacons forKey:[NSNumber numberWithInt:CLProximityUnknown]];
    
    NSArray *immediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityImmediate]];
    if([immediateBeacons count])
        [_beacons setObject:immediateBeacons forKey:[NSNumber numberWithInt:CLProximityImmediate]];
    
    NSArray *nearBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityNear]];
    if([nearBeacons count])
        [_beacons setObject:nearBeacons forKey:[NSNumber numberWithInt:CLProximityNear]];
    
    NSArray *farBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityFar]];
    if([farBeacons count])
        [_beacons setObject:farBeacons forKey:[NSNumber numberWithInt:CLProximityFar]];
    
    if (beacons) {
        NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:0];
        CLBeacon *beacon = [[_beacons objectForKey:sectionKey] objectAtIndex:0];
        
        [self.distanceLabel setText:[NSString stringWithFormat:@"Distance: %.2fm",beacon.accuracy]];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
//    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        CLBeaconRegion *region = obj;
//        [_locationManager startRangingBeaconsInRegion:region];
//    }];
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

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    float dis = [message[@"Acc"] floatValue];
    NSString *name = message[@"Name"];
    if (dis > 0) {
        [self.distanceLabel setText:[NSString stringWithFormat:@"Distance: %.2fm", dis]];
    }
    
    if (name) {
        [self.nameLabel setText:[NSString stringWithFormat:@"Name: %@", name]];
    }
}

@end
