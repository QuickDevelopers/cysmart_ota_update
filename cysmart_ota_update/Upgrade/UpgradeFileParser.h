//
//  UpgradeFileParser.h
//  cysmart_ota_update
//
//  Created by RND on 2023/6/29.
//

#import <Foundation/Foundation.h>
#import "UpgradeUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface UpgradeFileParser : NSObject


#define SILICON_ID          @"SiliconID"
#define SILICON_REV         @"SiliconRev"
#define CHECKSUM_TYPE       @"CheckSumType"
#define ROW_ID              @"RowID"
#define ROW_COUNT           @"RowCount"
#define ARRAY_ID            @"ArrayID"
#define ROW_NUMBER          @"RowNumber"
#define DATA_LENGTH         @"DataLength"
#define DATA_ARRAY          @"DataArray"
#define CHECKSUM_OTA        @"CheckSum"

/* File parsing alerts */
#define FILE_FORMAT_ERROR           @"FileFormatError"
#define PARSING_ERROR               @"ParsingError"
#define FILE_EMPTY_ERROR            @"FileEmpty"


#define LOCALIZEDSTRING(string) NSLocalizedString(string, nil)


/*!
 *  @method parseFirmwareFileWithName: andPath: onFinish:
 *
 *  @discussion Method for parsing the OTA firmware file
 *
 */
- (void) parseFirmwareFileWithName:(NSString *)fileName andPath:(NSString *)filePath onFinish:(void(^)(NSMutableDictionary * header, NSArray * rowData, NSArray * rowIdArray, NSError * error))finish;

@property(strong,nonatomic) UpgradeUtil *upUtil;



@end

NS_ASSUME_NONNULL_END
