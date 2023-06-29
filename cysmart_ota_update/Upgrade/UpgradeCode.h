//
//  UpgradeCode.h
//  cysmart_ota_update
//
//  Created by RND on 2023/6/29.
//

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

#define VERIFY_CHECKSUM       0x31
#define GET_FLASH_SIZE        0x32
#define SEND_DATA             0x37
#define ENTER_BOOTLOADER      0x38
#define PROGRAM_ROW           0x39
#define VERIFY_ROW            0x3A
#define EXIT_BOOTLOADER       0x3B


#define COMMAND_START_BYTE    0x01
#define COMMAND_END_BYTE      0x17

#define COMMAND_START_BYTE    0x01
#define COMMAND_END_BYTE      0x17

#define FLASH_ARRAY_ID   @"flashArrayID"
#define FLASH_ROW_NUMBER  @"flashRowNumber"

#define COMMAND_PACKET_MIN_SIZE  7

#define CHECK_SUM   @"checkSum"
#define CRC_16      @"crc_16"
#define ROW_DATA    @"rowData"


#define SUCCESS               @"0x00"
#define ERROR_FILE            @"0x01"
#define ERROR_EOF             @"0x02"
#define ERROR_LENGTH          @"0x03"
#define ERROR_DATA            @"0x04"
#define ERROR_COMMAND         @"0x05"
#define ERROR_DEVICE          @"0x06"
#define ERROR_VERSION         @"0x07"
#define ERROR_CHECKSUM        @"0x08"
#define ERROR_ARRAY           @"0x09"
#define ERROR_ROW             @"0x0A"
#define ERROR_BOOTLOADER      @"0x0B"
#define ERROR_APPLICATION     @"0x0C"
#define ERROR_ACTIVE          @"0x0D"
#define ERROR_UNKNOWN         @"0x0F"
#define ERROR_ABORT           @"0xFF"
