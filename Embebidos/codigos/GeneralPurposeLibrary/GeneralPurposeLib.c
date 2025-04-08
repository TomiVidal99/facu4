/*
 * GeneralPurposeLib.c
 *
 *  Created on: Apr 8, 2025
 *      Author: Tomás Vidal
 */

#include <stdint.h>
#include "GeneralPurposeLib.h"

void habilitar_contador_ciclos() {
	  *(volatile uint32_t*)DEMCR |= (1 << 24);
	  *(volatile uint32_t*)DWT_CTRL |= (1 << 0);
	  *(volatile uint32_t*)DWT_CYCCNT = 0;
}
