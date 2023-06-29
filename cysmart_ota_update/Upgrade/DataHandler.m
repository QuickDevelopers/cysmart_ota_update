//
//  DataHandler.m
//  cysmart_ota_update
//
//  Created by RND on 2023/6/29.
//

#import "DataHandler.h"

#define COMMAND_PACKET_HEADER    4


@implementation DataHandler


-(instancetype) init{
    
    self = [super init];
    if(self){
        _commandArray = [[NSMutableArray alloc] init];
    }
    return self;
}


-(NSString *)errorCode:(CBCharacteristic *) character{
    uint8_t *dataPointer = (uint8_t *) [character.value bytes];
    if (dataPointer != NULL) {
        NSString *errorCode = [NSString stringWithFormat:@"0x%2x",dataPointer[1]];
        errorCode = [errorCode stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        return errorCode;
    }
    return NULL;
}


/*!
 *  @method writeValueToCharacteristicWithData: bootLoaderCommandCode:
 *
 *  @discussion Method to write data to the device
 *
 */
-(void) writeOtaValueToCharacteristicWithData:(NSData *)data otaCharater:(CBCharacteristic *) charater otaPeripheral:(CBPeripheral *) peripheral bootLoaderCommandCode:(unsigned short)commandCode
{
    if (data != nil && charater != nil)
    {
        if (commandCode)
        {
            [_commandArray addObject:@(commandCode)];
        }
        //NSLog(@"send data is: %@ | characteristic: %@",data,charater.value);
        [peripheral writeValue:data forCharacteristic:charater type:CBCharacteristicWriteWithResponse];
        if([data isEqual:@(EXIT_BOOTLOADER)]){
            NSLog(@"结束了吗");
        }
    }
}


-(void)commandArrayRemoved{
    if(_commandArray.count>0){
        [_commandArray removeObjectAtIndex:0];
    }
}


/*!
 *  @method getBootLoaderDataFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the siliconID and silicon rev string
 *
 */
-(void) getBootLoaderDataFromCharacteristic:(CBCharacteristic *) characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    
    // Move to the position of data field
    
    dataPointer += COMMAND_PACKET_HEADER;
    
    // Get silicon Id
    
    NSMutableString *siliconIDString = [NSMutableString stringWithCapacity:8];
    
    for (int i = 3; i>=0; i--)
    {
        [siliconIDString appendFormat:@"%02x",(unsigned int)dataPointer[i]];
    }
    
    _siliconIDString = siliconIDString;
    
    // Get silicon Rev
    NSMutableString *siliconRevString = [NSMutableString stringWithCapacity:2];
    [siliconRevString appendFormat:@"%02x",(unsigned int)dataPointer[4]];
    _siliconRevString = siliconRevString;
}


/*!
 *  @method getBootloaderDataFromCharacteristic_v1:
 *
 *  @discussion Method to parse characteristic value to get siliconID, siliconRev and bootloader SDK version
 *
 */
/*-(void) getBootloaderDataFromCharacteristic_v1:(CBCharacteristic *) characteristic
{
  NSLog(@"Cypress: getBootloaderDataFromCharacteristic_v1: %@", characteristic.UUID);
    uint8_t * dataPointer = (uint8_t *)[characteristic.value bytes];
    
    dataPointer += COMMAND_PACKET_HEADER;
    const int siliconIdLength = 4;
    _siliconIDString = [Utilities HEXStringLittleFromByteArray:dataPointer ofSize:siliconIdLength];
    
    dataPointer += siliconIdLength;
    const int siliconRevLength = 1;
    _siliconRevString = [Utilities HEXStringLittleFromByteArray:dataPointer ofSize:siliconRevLength];
    
    dataPointer += siliconRevLength;
    const int bootloaderVersionLength = 3;
    _bootloaderVersionString = [Utilities HEXStringLittleFromByteArray:dataPointer ofSize:bootloaderVersionLength];
}*/


/*!
 *  @method getFlashDataFromCharacteristic:ƒ√
 *
 *  @discussion Method to parse the characteristic value to get the flash start and end row number
 *
 */
-(void) getFlashDataFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"RilBleTool : getFlashDataFromCharacteristic: %@", characteristic.UUID);
    
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
        
    dataPointer += 4;
    
    //dataPointer = @"\v";
    
    uint16_t firstRowNumber = CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);
        
    dataPointer += 2;
        
    uint16_t lastRowNumber = CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);
    
    _startRowNumber = firstRowNumber;
    _endRowNumber = lastRowNumber;
}

/*!
 *  @method getRowCheckSumFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the row checksum
 *
 */
-(void) getRowCheckSumFromCharacteristic:(CBCharacteristic *)characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    _checkSum = dataPointer[4];
    NSLog(@"_checkSum is : %d",_checkSum);
}

/*!
 *  @method checkApplicationCheckSumFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the application checksum
 *
 */
-(void) checkApplicationCheckSumFromCharacteristic:(CBCharacteristic *) characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    
    int applicationChecksum = dataPointer[4];
    
    if (applicationChecksum > 0)
    {
        _isApplicationValid = YES;
    }
    else{
        _isApplicationValid = NO;
    }
}



-(void) setCheckSumType:(NSString *) type
{
    _checkSumType = type;
}


/*!
 *  @method createCommandPacketWithCommand: dataLength: data:
 *
 *  @discussion Method to create the command packet from the host
 *
 */
-(NSData *) createCommandPacketWithCommand:(uint8_t)commandCode dataLength:(unsigned short)dataLength data:(NSDictionary *)packetDataDictionary
{
    NSData *data = [[NSData alloc] init];
    
    uint8_t startByte = COMMAND_START_BYTE;
    uint8_t endbyte = COMMAND_END_BYTE;
    int bitPosition = 0;
    
    unsigned char *commandPacket =  (unsigned char *)malloc((COMMAND_PACKET_MIN_SIZE + dataLength)* sizeof(unsigned char));
    
    commandPacket[bitPosition++] = startByte;
    commandPacket[bitPosition++] = commandCode;
    commandPacket[bitPosition++] = dataLength;
    commandPacket[bitPosition++] = dataLength >> 8;
    
    // Handle command code for GET_FLASH_SIZE command
    if (commandCode == GET_FLASH_SIZE)
    {
        uint8_t flashArrayID = [[packetDataDictionary objectForKey:FLASH_ARRAY_ID] integerValue];
        commandPacket[bitPosition++] = flashArrayID;
    }
    
    //Handle command code for PROGRAM_ROW command
    
    if (commandCode == PROGRAM_ROW || commandCode == VERIFY_ROW)
    {
        uint8_t flashArrayID = [[packetDataDictionary objectForKey:FLASH_ARRAY_ID] integerValue];
        unsigned short flashRowNumber = [[packetDataDictionary objectForKey:FLASH_ROW_NUMBER] integerValue];
        commandPacket[bitPosition++] = flashArrayID;
        commandPacket[bitPosition++] = flashRowNumber;
        commandPacket[bitPosition++] = flashRowNumber >> 8;
        
    }
    
    // Add the data to send to the command packet
    if (commandCode == SEND_DATA || commandCode == PROGRAM_ROW)
    {
        NSArray *dataArray = [packetDataDictionary objectForKey:ROW_DATA];
        
        for (int i =0; i<dataArray.count; i++)
        {
            NSString *value = dataArray[i];
            
            unsigned int outVal;
            NSScanner* scanner = [NSScanner scannerWithString:value];
            [scanner scanHexInt:&outVal];
            
            unsigned short valueToWrite = (unsigned short)outVal;
            commandPacket[bitPosition++] = valueToWrite;
        }
    }
    
    unsigned short checkSum  = [self calculateChacksumWithCommandPacket:commandPacket withSize:(bitPosition) type:_checkSumType];
    
    commandPacket[bitPosition++] = checkSum;
    commandPacket[bitPosition++] = checkSum >> 8;
    commandPacket[bitPosition++] = endbyte;
    
    data = [NSData dataWithBytes:commandPacket length:(bitPosition)];
    
    free(commandPacket);
    
    return data;
}

/*!
 *  @method calculateChacksumWithCommandPacket: withSize: type:
 *
 *  @discussion Method to calculate the checksum
 *
 */
-(unsigned short) calculateChacksumWithCommandPacket:(unsigned char [])array withSize:(int)packetSize type:(NSString *)type
{
    if ([type isEqualToString:CHECK_SUM])
    {
        // Sum checksum
        unsigned short sum = 0;
        
        for (int i = 0; i<packetSize; i++)
        {
            sum = sum + array[i];
        }
        NSLog(@"sum is %d",sum);
        return ~sum+1;
    }
    else
    {
        // CRC 16
        unsigned short sum = 0xffff;
        
        unsigned short tmp;
        int i;
        
        if (packetSize == 0)
            return (~sum);
        do
        {
            for (i = 0, tmp = 0x00ff & *array++; i < 8; i++, tmp >>= 1)
            {
                if ((sum & 0x0001) ^ (tmp & 0x0001))
                    sum = (sum >> 1) ^ 0x8408;
                else
                    sum >>= 1;
            }
        }
        while (--packetSize);
        
        sum = ~sum;
        tmp = sum;
        sum = (sum << 8) | (tmp >> 8 & 0xFF);
        NSLog(@"sum is %d",sum);
        return sum;
    }
}


/*!
 *  @method updateValueForCharacteristicWithCompletionHandler:
 *
 *  @discussion Method to set notifications or indications for the value of a specified characteristic
 *
 */
-(void)updateValueForCharacteristic:(CBCharacteristic *)charater otaPeripheral:(CBPeripheral *)peripheral withCompletionHandler:(void (^) (BOOL success,id command,NSError *error)) handler
{
    cbCharacteristicUpdationHandler = handler;
    if (charater != nil)
    {
        [peripheral setNotifyValue:YES forCharacteristic:charater];
    }
}


/*!
 *  @method discoverCharacteristicsWithCompletionHandler:
 *
 *  @discussion Method to discover the specified characteristics of a service.
 *
 */
-(void) discoverCharacteristicsWithCompletionHandler:(void (^) (BOOL success, NSError *error)) handler
{
    cbCharacteristicDiscoverHandler = handler;
    cbCharacteristicDiscoverHandler(YES,nil);
}



@end
