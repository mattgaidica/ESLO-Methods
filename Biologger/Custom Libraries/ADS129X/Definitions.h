//  Definitions.h
// SPI_MODE1: CPOL = 0, CPHA = 1; Output rising, data falling

#ifndef _Definitions_h
#define _Definitions_h

#define _ADS_WHOAMI 0x90

#define _ADS_WAKEUP 0x02 // Wake-up from standby mode
#define _ADS_STANDBY 0x04 // Enter Standby mode
#define _ADS_RESET 0x06 // Reset the device
#define _ADS_START 0x08 // Start and restart (synchronize) conversions
#define _ADS_STOP 0x0A // Stop conversion
#define _ADS_RDATAC 0x10 // Enable Read Data Continuous mode (default mode at power-up)
#define _ADS_SDATAC 0x11 // Stop Read Data Continuous mode
#define _ADS_RDATA 0x12 // Read data by command; supports multiple read back

#define _ADS_RREG 0x20 // (also = 00100000) is the first opcode that the address must be added to for RREG communication
#define _ADS_WREG 0x40 // 01000000 in binary (Datasheet, pg. 35)

//Register Addresses
#define _ADSreg_ID 0x00
#define _ADSreg_CONFIG1 0x01
#define _ADSreg_CONFIG2 0x02
#define _ADSreg_CONFIG3 0x03
#define _ADSreg_LOFF 0x04
#define _ADSreg_CH1SET 0x05
#define _ADSreg_CH2SET 0x06
#define _ADSreg_CH3SET 0x07
#define _ADSreg_CH4SET 0x08
#define _ADSreg_CH5SET 0x09
#define _ADSreg_CH6SET 0x0A
#define _ADSreg_CH7SET 0x0B
#define _ADSreg_CH8SET 0x0C
#define _ADSreg_BIAS_SENSP 0x0D
#define _ADSreg_BIAS_SENSN 0x0E
#define _ADSreg_LOFF_SENSP 0x0F
#define _ADSreg_LOFF_SENSN 0x10
#define _ADSreg_LOFF_FLIP 0x11
#define _ADSreg_LOFF_STATP 0x12
#define _ADSreg_LOFF_STATN 0x13
#define _ADSreg_GPIO 0x14
#define _ADSreg_MISC1 0x15
#define _ADSreg_MISC2 0x16
#define _ADSreg_CONFIG4 0x17

#endif
