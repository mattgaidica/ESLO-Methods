#include <ESLO.h>
#include <SPI_NAND.h>
#include <string.h>
#include <ti/drivers/TRNG.h>
#include <ti/drivers/cryptoutils/cryptokey/CryptoKeyPlaintext.h>

SPI_Handle ESLO_SPI_init(uint8_t _index) {
	SPI_Handle SPI_handle;
	SPI_Params spiParams;
	SPI_Params_init(&spiParams);
	spiParams.bitRate = 1000000; // up to 10,000,000
	spiParams.frameFormat = SPI_POL1_PHA1; // mode 3
	SPI_handle = SPI_open(_index, &spiParams);
	return SPI_handle;
}

SPI_Handle ESLO_SPI_EEG_init(uint8_t _index) {
	SPI_Handle SPI_handle;
	SPI_Params spiParams;
	SPI_Params_init(&spiParams);
	spiParams.frameFormat = SPI_POL0_PHA1;
	spiParams.bitRate = 1000000; // possible max of ~15,000,000
	SPI_handle = SPI_open(_index, &spiParams); // CONFIG_SPI_EEG
	return SPI_handle;
}

float_t ESLO_calculateSD(float_t data[]) {
	float_t sum = 0.0, mean, SD = 0.0;
	int i;
	for (i = 0; i < 10; ++i) {
		sum += data[i];
	}
	mean = sum / 10;
	for (i = 0; i < 10; ++i) {
		SD += pow(data[i] - mean, 2);
	}
	return sqrt(SD / 10);
}

// !!add vital positions to ESLO.h as #define
void ESLO_compileVitals(uint32_t *vbatt, uint32_t *lowVolt, int32_t *therm,
		uint32_t *esloAddr, uint8_t *axyLog, uint8_t *value) {
	memcpy(value, vbatt, sizeof(uint32_t));
	memcpy(value + 4, lowVolt, sizeof(uint32_t));
	memcpy(value + 8, therm, sizeof(uint32_t));
	memcpy(value + 12, esloAddr, sizeof(uint32_t));
	memcpy(value + 16, axyLog, sizeof(uint8_t));
}

int32_t ESLO_convertTherm(uint32_t Vo) {
// lots of tricks to make these units work with integers
	uint32_t Rf = 100000; // ohms
	uint32_t Vi = 1800000; // uV
	int32_t Rt = (((Vo / 1000) * (Rf / 1000)) / ((Vi - Vo) / 1000)) * 1000;
	int32_t temp_uC = -196 * Rt + 45177309;
	return temp_uC;
}

uint32_t ESLO_convertBatt(uint32_t Vo) {
	return Vo * 2;
}

void ESLO_decodeNVS(uint32_t *buffer, uint32_t *sig, uint32_t *ver,
		uint32_t *addr) {
	memcpy(sig, buffer, sizeof(uint32_t));
	memcpy(ver, buffer + 1, sizeof(uint32_t));
	memcpy(addr, buffer + 2, sizeof(uint32_t));
}
void ESLO_encodeNVS(uint32_t *buffer, uint32_t *sig, uint32_t *ver,
		uint32_t *addr) {
	memcpy(buffer, sig, sizeof(uint32_t));
	memcpy(buffer + 1, ver, sizeof(uint32_t));
	memcpy(buffer + 2, addr, sizeof(uint32_t));
}

void ESLO_GenerateVersion(uint32_t *esloVersion, uint_least8_t index) {
	TRNG_Handle rndHandle;
	int_fast16_t rndRes;
	CryptoKey entropyKey;
	uint8_t entropyBuffer[VERSION_LENGTH]; // 24-bits
	TRNG_init();
	rndHandle = TRNG_open(index, NULL);
	if (!rndHandle) {
		// Handle error
		while (1)
			;
	}
	CryptoKeyPlaintext_initBlankKey(&entropyKey, entropyBuffer, VERSION_LENGTH);
	rndRes = TRNG_generateEntropy(rndHandle, &entropyKey);
	if (rndRes != TRNG_STATUS_SUCCESS) {
		// Handle error
		while (1)
			;
	}
	TRNG_close(rndHandle);

// set version
	memcpy(esloVersion, entropyBuffer, sizeof(entropyBuffer));
}

void ESLO_Packet(eslo_dt eslo, uint32_t *packet) {
	*packet = (eslo.data & 0x00FFFFFF) | // make data 24-bits
			((uint32_t) (eslo.type << 24) & 0xFF000000);
}

ReturnType ESLO_Write(uAddrType *esloAddr, uint8_t *esloBuffer,
		uint32_t esloVersion, eslo_dt eslo) {
	ReturnType ret = Flash_Success;
	uint32_t packet;

	ESLO_Packet(eslo, &packet);

	if (*esloAddr >= FLASH_SIZE)
		ret = Flash_MemoryOverflow;

	memcpy(esloBuffer + ADDRESS_2_COL(*esloAddr), &packet, 4);
	*esloAddr += 4;

	if (ADDRESS_2_COL(*esloAddr) == PAGE_DATA_SIZE) { // end of page, write it
		if (ADDRESS_2_PAGE(*esloAddr) == 0) { // first page in block
			ret = FlashBlockErase(*esloAddr); // wipe 64 pages
			if (ret != Flash_Success) {
				return ret; // return early
			}
		}

		(*esloAddr) &= 0xFFFFF000; // always write to 0th column index
		ret = FlashPageProgram(*esloAddr, esloBuffer, PAGE_DATA_SIZE); // write page
		(*esloAddr) += 0x00001000; // increment page

		// fresh block, note: requires an intentional version write at startup
		if (ADDRESS_2_PAGE(*esloAddr) == 0) {
			eslo.type = Type_Version;
			eslo.data = esloVersion;
			ESLO_Packet(eslo, &packet);
			memcpy(esloBuffer + ADDRESS_2_COL(*esloAddr), &packet, 4);
			*esloAddr += 4;
		}
	}

	return ret;
}
