//
//  UpgradeUtil.m
//  cysmart_ota_update
//
//  Created by RND on 2023/6/29.
//

#import "UpgradeUtil.h"

#define MAX_DATA_SIZE   133

#define CHECK_SUM   @"checkSum"
#define CRC_16      @"crc_16"
#define ROW_DATA    @"rowData"

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


#define FLASH_ARRAY_ID   @"flashArrayID"
#define FLASH_ROW_NUMBER  @"flashRowNumber"


@implementation UpgradeUtil

///=======================OTA==============================
/*!
 *  @method getIntegerFromHexString:
 *
 *  @discussion Method that returns the integer from hex string
 *
 */


-(unsigned int) getIntegerFromHexString:(NSString *)hexString
{
    unsigned int integerValue;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&integerValue];
    
    return integerValue;
}

-(uint8_t *)getPointer:(CBCharacteristic *)characteristic{
    uint8_t *dataPointer = (uint8_t *) [characteristic.value bytes];
    return dataPointer;
}

-(NSString *)getErrorCode:(uint8_t *) dataPointer{
    if (dataPointer != NULL) {
        NSString *errorCode = [NSString stringWithFormat:@"0x%2x",dataPointer[1]];
        errorCode = [errorCode stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        return errorCode;
    }
    return NULL;
}


//转换数据

-(NSDictionary*)changerFirstData:(NSArray *)array currentIndex:(NSInteger) index{
    /* Write the GET_FLASH_SIZE command */
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[rowDataDict objectForKey:ARRAY_ID] forKey:FLASH_ARRAY_ID];
    return dataDict;
}

-(NSString *) currentArrayId:(NSArray *)array currentIndex:(NSInteger) index{
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    return [rowDataDict objectForKey:ARRAY_ID];
}



/**
 * Method to convert hex to byteArray
 */

-(NSMutableData *)dataFromHexString:(NSString *)string
{
    NSMutableData *data = [NSMutableData new];
    NSCharacterSet *hexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF "] invertedSet];
    
    // Check whether the string is a valid hex string. Otherwise return empty data
    if ([string rangeOfCharacterFromSet:hexSet].location == NSNotFound) {
        
        string = [string lowercaseString];
        unsigned char whole_byte;
        char byte_chars[3] = {'\0','\0','\0'};
        int i = 0;
        int length = (int)string.length;
        
        while (i < length-1)
        {
            char c = [string characterAtIndex:i++];
            
            if (c < '0' || (c > '9' && c < 'a') || c > 'f')
                continue;
            byte_chars[0] = c;
            byte_chars[1] = [string characterAtIndex:i++];
            whole_byte = strtol(byte_chars, NULL, 16);
            [data appendBytes:&whole_byte length:1];
        }
    }
    return data;
}


-(NSDictionary *)changerDictionary:(NSArray *)array{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[array subarrayWithRange:NSMakeRange(0, MAX_DATA_SIZE)],ROW_DATA, nil];
    return dataDict;
}


-(NSArray *)removeData:(NSArray *) array{
    NSMutableArray *arrays = [array mutableCopy];
    [arrays removeObjectsInRange:NSMakeRange(0, MAX_DATA_SIZE)];
    NSArray *newarray = [arrays copy];
    return newarray;
}

//拆分成各种小部分
-(NSDictionary *)changeLastPacketDict:(NSArray *) array row:(NSInteger) number dict:(NSDictionary*) dict{
    NSDictionary *lastPacketDict = [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:ARRAY_ID],FLASH_ARRAY_ID,
    @(number),FLASH_ROW_NUMBER,
    array,ROW_DATA, nil];
    
    return lastPacketDict;
}

-(NSDictionary *)changeVerifyRow:(NSArray*) array currentIndex:(NSInteger) index currentRow:(NSInteger) row{
    /* Write the VERIFY_ROW command */
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[rowDataDict objectForKey:ARRAY_ID],FLASH_ARRAY_ID,
                              @(row),FLASH_ROW_NUMBER,
                              nil];
    return dataDict;
}

-(uint8_t) rowCheckSumUint8:(NSArray *)array currentIndex:(NSInteger) index{
    
    NSDictionary *rowDataDict = [array objectAtIndex:index];
    uint8_t rowCheckSum = [self getIntegerFromHexString:[rowDataDict objectForKey:CHECKSUM_OTA]];
    uint8_t arrayID = [self getIntegerFromHexString:[rowDataDict objectForKey:ARRAY_ID]];
    unsigned short rowNumber = [self getIntegerFromHexString:[rowDataDict objectForKey:ROW_NUMBER]];
    unsigned short dataLength = [self getIntegerFromHexString:[rowDataDict objectForKey:DATA_LENGTH]];
    
    uint8_t sum = rowCheckSum + arrayID + rowNumber + (rowNumber >> 8) + dataLength + (dataLength >> 8);
    
    return sum;
}


@end
