#include <ESLO.h>
#include <lsm6dsox_reg.h>
#include <lsm6dsox_CCXXXX.h>

uint8_t AXY_Init(stmdev_ctx_t dev_ctx_xl) {
	uint8_t whoami = 0x00;
	lsm6dsox_device_id_get(&dev_ctx_xl, &whoami); // 0x6C
	if (whoami != LSM6DSOX_ID) {
		return ESLO_FAIL;
	}
	lsm6dsox_gy_power_mode_set(&dev_ctx_xl, LSM6DSOX_GY_NORMAL);
	lsm6dsox_gy_data_rate_set(&dev_ctx_xl, LSM6DSOX_GY_ODR_OFF);
	lsm6dsox_xl_power_mode_set(&dev_ctx_xl,
			LSM6DSOX_ULTRA_LOW_POWER_MD);
	lsm6dsox_xl_data_rate_set(&dev_ctx_xl, LSM6DSOX_XL_ODR_OFF);
	return ESLO_PASS;
}

int32_t write_reg(void *handle, uint8_t Reg, uint8_t *Bufp, uint16_t len) {
	SPI_Transaction transaction;

	GPIO_write(_AXY_CS, GPIO_CFG_OUT_LOW);
	transaction.count = 0x01;
	transaction.rxBuf = NULL;
	transaction.txBuf = (void*) &Reg;
	SPI_transfer(handle, &transaction);

	transaction.count = len;
	transaction.rxBuf = NULL;
	transaction.txBuf = (void*) Bufp;
	SPI_transfer(handle, &transaction);

	GPIO_write(_AXY_CS, GPIO_CFG_OUT_HIGH);
	return 0x00;
}

int32_t read_reg(void *handle, uint8_t Reg, uint8_t *Bufp, uint16_t len) {
	SPI_Transaction transaction;

	Reg = 0x80 | Reg; // set read bit
	GPIO_write(_AXY_CS, GPIO_CFG_OUT_LOW);
	transaction.count = 0x01;
	transaction.rxBuf = NULL;
	transaction.txBuf = (void*) &Reg;
	SPI_transfer(handle, &transaction);

	transaction.count = len;
	transaction.rxBuf = Bufp;
	transaction.txBuf = NULL;
	SPI_transfer(handle, &transaction);

	GPIO_write(_AXY_CS, GPIO_CFG_OUT_HIGH);
	return 0x00;
}
