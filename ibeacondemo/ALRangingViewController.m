/*
     File: ALRangingViewController.m
 Abstract: View controller that illustrates how to start and stop ranging for a beacon region.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "ALRangingViewController.h"
#import "ALDefaults.h"
#import "AppDelegate.h"

@implementation ALRangingViewController
{
    NSMutableDictionary *_beacons;
    CLLocationManager *_locationManager;
    NSMutableArray *_rangedRegions;
    CBCentralManager *_centralManager;
    WCSession *_session;
    
    CBPeripheralManager *_peripheralManager;
    
    CBPeripheral *_peripheral;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if(self)
	{
        _beacons = [[NSMutableDictionary alloc] init];
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        
        if ([WCSession isSupported]) {
            _session = [WCSession defaultSession];
            _session.delegate = self;
            [_session activateSession];
        }
        
        // This location manager will be used to demonstrate how to range beacons.
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            //Use in iOS8 or later
            [_locationManager requestAlwaysAuthorization];
        }
        
        if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
            //Use in iOS9 or later
            [_locationManager setAllowsBackgroundLocationUpdates:YES];
        }
	}
	
	return self;
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    NSLog(@"message : %@",message[@"name"]);
    
    //    NSMutableDictionary *peripheralData = nil;
    //
    //    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"] identifier:@"com.apple.AirLocate"];
    //    peripheralData = [region peripheralDataWithMeasuredPower:@(-59)];
    //    [peripheralData setObject:@"Siri" forKey:CBAdvertisementDataLocalNameKey];
    ////    [peripheralData setObject:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0" forKey:CBAdvertisementDataServiceUUIDsKey];
    //
    //    // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
    //    //广播位置信息
    //    if(peripheralData)
    //    {
    //        [_peripheralManager startAdvertising:peripheralData];
    //    }
    
    [self scan];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    NSLog(@"userInfo : %@",userInfo[@"name"]);
    [self scan];
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    NSLog(@"applicationContext : %@",applicationContext[@"name"]);
    [self scan];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"%@",error);
}

- (void)scan {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)};
        NSArray *services = @[[CBUUID UUIDWithString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"]];
        
//        [_centralManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionSolicitedServiceUUIDsKey : @[[CBUUID UUIDWithString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"]]}];
//        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        [_centralManager scanForPeripheralsWithServices:services options:nil];
//        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        [self scan];
    });
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
//    if (advertisementData[@"kCBAdvDataLocalName"]) {
        NSLog(@"UUID = %@\nName = %@\nRSSI = %@",peripheral.identifier, peripheral.name, RSSI);
    
    _peripheral = peripheral;
    //尝试去连接对方
    [_centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @(YES),
                                                            CBConnectPeripheralOptionNotifyOnNotificationKey : @(YES)}];
    
//        NSDictionary *beaconDic = @{@"Name" : advertisementData[@"kCBAdvDataLocalName"]};
//        [((AppDelegate *)[UIApplication sharedApplication].delegate).session sendMessage:beaconDic replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
//            
//        } errorHandler:^(NSError * _Nonnull error) {
//            NSLog(@"%@",error);
//        }];
//    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //    [_centralManager scanForPeripheralsWithServices:services options:@{CBCentralManagerScanOptionSolicitedServiceUUIDsKey : @[[CBUUID UUIDWithString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"]]}];
    [self scan];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connected!");
    _peripheral.delegate = self;
    
    //查找所有服务
    [_peripheral discoverServices:nil];
}

//发现了服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
//        NSLog(@"service: %@",service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//发现了服务的特性值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//        NSLog(@"Discovered characteristic %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
        
        NSData *data = [NSData dataWithBytes:[@"sisisisisisi" UTF8String] length:@"sisisisisisi".length];
        
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    [_peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic error = %@",error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateValueForCharacteristic error = %@",error);
    
    NSData *data = characteristic.value;
    
    NSLog(@"Data = %@", data);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnected!");

}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {

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

    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Start ranging when the view appears.
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager startRangingBeaconsInRegion:region];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Stop ranging when the view goes away.
    [_rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager stopRangingBeaconsInRegion:region];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Ranging";
    
    // Populate the regions we will range once.
    _rangedRegions = [NSMutableArray array];
    [[ALDefaults sharedDefaults].supportedProximityUUIDs enumerateObjectsUsingBlock:^(id uuidObj, NSUInteger uuidIdx, BOOL *uuidStop) {
        NSUUID *uuid = (NSUUID *)uuidObj;
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        [_rangedRegions addObject:region];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _beacons.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionValues = [_beacons allValues];
    return [[sectionValues objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    NSArray *sectionKeys = [_beacons allKeys];
    
    // The table view will display beacons by proximity.
    NSNumber *sectionKey = [sectionKeys objectAtIndex:section];
    switch([sectionKey integerValue])
    {
        case CLProximityImmediate:
            title = @"Immediate";
            break;
            
        case CLProximityNear:
            title = @"Near";
            break;
            
        case CLProximityFar:
            title = @"Far";
            break;
            
        default:
            title = @"Unknown";
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    // Display the UUID, major, minor and accuracy for each beacon.
    NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:indexPath.section];
    CLBeacon *beacon = [[_beacons objectForKey:sectionKey] objectAtIndex:indexPath.row];
    cell.textLabel.text = [beacon.proximityUUID UUIDString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@, Acc: %.2fm", beacon.major, beacon.minor, beacon.accuracy];

    NSDictionary *beaconDic = @{@"Acc" : @(beacon.accuracy)};
    [((AppDelegate *)[UIApplication sharedApplication].delegate).session sendMessage:beaconDic replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
    } errorHandler:^(NSError * _Nonnull error) {
        
    }];
    return cell;
}

@end
