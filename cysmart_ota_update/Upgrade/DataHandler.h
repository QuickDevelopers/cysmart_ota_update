//
//  DataHandler.h
//  cysmart_ota_update
//
//  Created by RND on 2023/6/29.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UpgradeCode.h"


void (^ _Nullable cbCharacteristicDiscoverHandler)(BOOL success, NSError * _Nullable error);

void (^ _Nullable cbCharacteristicUpdationHandler)(BOOL success,id _Nullable command,NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface DataHandler : NSObject

@property (nonatomic,strong) NSMutableArray *commandArray;

@property (strong,nonatomic) NSString * checkSumType;

/*!
 *  @property siliconIDString
 *
 *  @discussion siliconID from the device response
 *
 */
@property (strong,nonatomic) NSString *siliconIDString;

/*!
 *  @property siliconRevString
 *
 *  @discussion silicon rev from the device response
 *
 */
@property (strong,nonatomic) NSString *siliconRevString;

/*!
 *  @property startRowNumber
 *
 *  @discussion Device flash start row number
 *
 */
@property (nonatomic) int startRowNumber;

/*!
 *  @property endRowNumber
 *
 *  @discussion Device flash end row number
 *
 */
@property (nonatomic) int endRowNumber;

/*!
 *  @property checkSum
 *
 *  @discussion checkSum received from the device for writing a single row
 *
 */
@property (assign) uint8_t checkSum;

/*!
 *  @property isApplicationValid
 *
 *  @discussion flag used to check whether the application writing is success
 *
 */
@property (nonatomic) BOOL isApplicationValid;

// 返回的方法处理

-(NSString *)errorCode:(CBCharacteristic *) character;

-(void) getBootLoaderDataFromCharacteristic:(CBCharacteristic *) characteristic;

-(void) getFlashDataFromCharacteristic:(CBCharacteristic *)characteristic;

-(void) getRowCheckSumFromCharacteristic:(CBCharacteristic *)characteristic;

-(void) checkApplicationCheckSumFromCharacteristic:(CBCharacteristic *) characteristic;

-(NSData *) createCommandPacketWithCommand:(uint8_t)commandCode dataLength:(unsigned short)dataLength data:(NSDictionary *)packetDataDictionary;

-(void)updateValueForCharacteristic:(CBCharacteristic *)charater otaPeripheral:(CBPeripheral *)peripheral withCompletionHandler:(void (^) (BOOL success,id command,NSError *error)) handler;

-(void) writeOtaValueToCharacteristicWithData:(NSData *)data otaCharater:(CBCharacteristic *) charater otaPeripheral:(CBPeripheral *) peripheral bootLoaderCommandCode:(unsigned short)commandCode;

-(void) discoverCharacteristicsWithCompletionHandler:(void (^) (BOOL success, NSError *error)) handler;

-(void)commandArrayRemoved;



@end

NS_ASSUME_NONNULL_END
