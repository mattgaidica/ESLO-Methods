#ifndef ____ADS129X__
#define ____ADS129X__

#include <ESLO.h>
#include "Definitions.h"

//Helpers
void ADS_sleepTicks(uint8_t n);
void ADS_sendCommand(uint8_t _cmd);
int32_t sign32(int32_t val);

//System Commands
uint8_t ADS_init();
void ADS_enableChannels(bool Ch1, bool Ch2, bool Ch3, bool Ch4);
void ADS_close();
void ADS_wakeup();
void ADS_standby();
void ADS_reset();
void ADS_start();
void ADS_stop();

//Data Read Commands
void ADS_rdatac(); // start
void ADS_sdatac(); // stop
void ADS_rdata();

//Register Read/Write Commands
uint8_t ADS_getDeviceID();
uint8_t ADS_rreg(uint8_t _address);
void ADS_wreg(uint8_t _address, uint8_t _value);

void ADS_updateData(int32_t *status, int32_t *ch1, int32_t *ch2, int32_t *ch3, int32_t *ch4);

#endif
