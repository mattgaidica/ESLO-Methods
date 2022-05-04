#ifndef _ESLO_H_
#define _ESLO_H_

#include <unistd.h>
#include <math.h>
#include <SPI_NAND.h>

#include <ti/drivers/SPI.h>
#include <ti/drivers/GPIO.h>
#include <ti/drivers/NVS.h>
#include <ti_drivers_config.h>

#include <ti/sysbios/knl/Task.h>
#include <ti/sysbios/knl/Clock.h>

/* AXY */
#include <lsm6dsox_CCXXXX.h>
#include <lsm6dsox_reg.h>
/* NAND */
#include <SPI_NAND.h>
#include <ESLO.h>
#include <Serialize.h>
/* ADS129X */
#include <ADS129X.h>
#include <Definitions.h>

#define VERSION_LENGTH 		3
#define V_DROPOUT 			2400000 // 1.8V reg goes down to 2.2V, empirically tested
#define EEG_SAMPLING_DIV 	2 // effective Fs = (250 / this number)
#define EEG_FS				250 // Hz (ideal)
#define EEG_STARTUP_SAMPLES	(EEG_FS / EEG_SAMPLING_DIV) * 0.5 // seconds
#define SPEAKER_CONN_DELAY	500 // ms
#define FFT_HALF_LEN 		1024
#define FFT_LEN 			2 * FFT_HALF_LEN
#define FFT_SWA_DIV			2 // !! REMOVE TO FFT UPGRADE
#define SWA_LEN				256

#define	SWA_F_MIN			0.5
#define SWA_F_MAX			4
#define	THETA_F_MIN			6
#define THETA_F_MAX			12

#define PACKET_SZ_EEG 		SIMPLEPROFILE_CHAR4_LEN / 4
#define PACKET_SZ_XL 		SIMPLEPROFILE_CHAR5_LEN / 4
#define DATA_TIMEOUT_PERIOD	30000 // ms, time of recording + data transfer
#define AXY_HAS_MOVED_EEG	0x01 // isMoving bits to test
#define AXY_MOVE_MASK		0x1F // 0001 1111 (5 minutes)
#define AXY_MOVE_THRESH		100 // based on std()

#define ADS_GAIN 			12 // not used in init yet (hardcoded)
#define VREF				1.5

#define ESLO_FAIL 0x00
#define ESLO_PASS 0x01

// these are used in other libraries
SPI_Handle ESLO_SPI, ESLO_SPI_EEG;
static uint32_t ESLOSignature = 0xE123E123; // something unique
//static uint32_t GitCommit = 0x84B383;

typedef enum {
	ESLO_LOW, ESLO_HIGH
} ESLO_States;

typedef enum {
	ESLO_MODULE_OFF, ESLO_MODULE_ON
} ESLO_ModuleStatus;

// mode could also be rec. freq. for Axy using or-flags
typedef enum { // 2bits, 0-3 (4 options)
	Mode_Debug, Mode_Deployment
} ESLO_Mode;

// could always use a type like "EEG" as a type and then just
// extract the next n packets on the other side if I need more
// types... or hijack mode or checksum bits
typedef enum { // 8bits, 0-255 (256 options)
	Type_AbsoluteTime,
	Type_RelativeTime,
	Type_EEG1,
	Type_EEG2,
	Type_EEG3,
	Type_EEG4,
	Type_BatteryVoltage,
	Type_AxyXlx,
	Type_AxyXly,
	Type_AxyXlz,
	Type_EEGState,
	Type_SWATrial,
	Type_NotUsed2,
	Type_Therm,
	Type_Error,
	Type_Version
} ESLO_Type;

typedef enum {
	Set_Record,
	Set_RecPeriod,
	Set_RecDuration,
	Set_EEG1,
	Set_EEG2,
	Set_EEG3,
	Set_EEG4,
	Set_AxyMode,
	Set_SWA,
	Set_Time1,
	Set_Time2,
	Set_Time3,
	Set_Time4,
	Set_SWAThresh,
	Set_SWARatio,
	Set_ResetVersion,
	Set_AdvLong
} ESLO_Settings;

typedef struct {
	uint8_t type;
	uint32_t data;
} eslo_dt;

/*
 * uint32_t packet = 0xFF123456;
 * eslo_dt eslo;
 *
 * eslo.mode = Mode_Deployment;
 * eslo.type = Type_Temperature;
 * ESLO_Packet(eslo, &packet);
 */
SPI_Handle ESLO_SPI_init(uint8_t _index);
SPI_Handle ESLO_SPI_EEG_init(uint8_t _index);
float_t ESLO_calculateSD(float_t data[]);
void ESLO_compileVitals(uint32_t *vbatt, uint32_t *lowVolt, int32_t *therm,
		uint32_t *esloAddr, uint8_t *axyLog, uint8_t *value);
int32_t ESLO_convertTherm(uint32_t Vo);
uint32_t ESLO_convertBatt(uint32_t Vo);
void ESLO_Packet(eslo_dt eslo, uint32_t *packet);
ReturnType ESLO_Write(uAddrType *esloAddr, uint8_t *esloBuffer,
		uint32_t esloVersion, eslo_dt eslo);
void ESLO_GenerateVersion(uint32_t *esloVersion, uint_least8_t index);
void ESLO_decodeNVS(uint32_t *buffer, uint32_t *sig, uint32_t *ver,
		uint32_t *addr);
void ESLO_encodeNVS(uint32_t *buffer, uint32_t *sig, uint32_t *ver,
		uint32_t *addr);
#endif //end of file
