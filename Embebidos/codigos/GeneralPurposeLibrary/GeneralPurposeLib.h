/*
 * GeneralPurposeLib.h
 *
 *  Created on: Apr 8, 2025
 *      Author: Tomás Vidal
 *
 *  This library contains definitions of addresses of registers
 *  I used the official Cortex M3 datasheet (cortex_m3-RM.pdf)
 */

#ifndef INC_GENERALPURPOSELIB_H_
#define INC_GENERALPURPOSELIB_H_

// --------------------- FUNCTIONS --------------------------------
/*
 * Enables the counter for the clock cycles.
 * With the bit 0 of the DWT_CTRL the counter it's enabled.
 * To check the content of the counter in debug>expressions: *(uint32_t*)0xE0001004
 * More info: cortex_m3-RM.pdf - page 884
 */
void habilitar_contador_ciclos();

// --------------------- REGISTERS --------------------------------

// (cortex_m3-RM.pdf - page 828)
#define DHCSR 0xE000EDF0
#define DCRSR 0xE000EDF4
#define DCRDR 0xE000EDF8
#define DEMCR 0xE000EDFC

// (cortex_m3-RM.pdf - page 878)
#define DWT_CTRL 0xE0001000
#define DWT_CYCCNT 0xE0001004
#define DWT_CPICNT 0xE0001008
#define DWT_EXCCNT 0xE000100C
#define DWT_SLEEPCNT 0xE0001010
#define DWT_LSUCNT 0xE0001014

// (cortex_m3-RM.pdf - page 879)
#define DWT_FOLDCNT 0xE0001018
#define DWT_PCSR 0xE000101C
#define DWT_LSR 0xE0001FB4


#endif /* INC_GENERALPURPOSELIB_H_ */
