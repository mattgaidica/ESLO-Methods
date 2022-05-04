#ifndef LSM6DSOX_CCXXXX_H
#define LSM6DSOX_CCXXXX_H

#include <ESLO.h>
#include <lsm6dsox_CCXXXX.h>
#include <lsm6dsox_reg.h>

//typedef union {
//	int16_t i16bit[3];
//	uint8_t u8bit[6];
//} axis3bit16_t;
//
//typedef union {
//	int16_t i16bit;
//	uint8_t u8bit[2];
//} axis1bit16_t;
//
//typedef union {
//	int32_t i32bit[3];
//	uint8_t u8bit[12];
//} axis3bit32_t;

uint8_t AXY_Init(stmdev_ctx_t dev_ctx_xl);

int32_t write_reg(void *handle, uint8_t Reg, uint8_t *Bufp,
		uint16_t len);

int32_t read_reg(void *handle, uint8_t Reg, uint8_t *Bufp,
		uint16_t len);

#endif /* LSM6DSOX_CCXXXX_H */
