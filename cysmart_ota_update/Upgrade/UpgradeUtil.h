//
//  UpgradeUtil.h
//  cysmart_ota_update
//
//  Created by RND on 2023/6/29.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface UpgradeUtil : NSObject


-(unsigned int) getIntegerFromHexString:(NSString *)hexString;

-(uint8_t *)getPointer:(CBCharacteristic *)characteristic;

-(NSString *)getErrorCode:(uint8_t *) dataPointer;

-(NSDictionary*)changerFirstData:(NSArray *)array currentIndex:(NSInteger) index;

-(NSString *) currentArrayId:(NSArray *)array currentIndex:(NSInteger) index;

-(NSMutableData *)dataFromHexString:(NSString *)string;

-(NSDictionary *)changerDictionary:(NSArray *)array;

-(NSArray *)removeData:(NSArray *) array;

-(NSDictionary *)changeLastPacketDict:(NSArray *) array row:(NSInteger) number dict:(NSDictionary*) dict;

-(NSDictionary *)changeVerifyRow:(NSArray*) array currentIndex:(NSInteger) index currentRow:(NSInteger) row;

-(uint8_t) rowCheckSumUint8:(NSArray *)array currentIndex:(NSInteger) index;

@end

NS_ASSUME_NONNULL_END
