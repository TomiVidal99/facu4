#ifndef _GPL_

#include <stdint.h>
#include "MemoryAddr.h"

#define HIGH 1
#define LOW 0

/*
    Sets the pin 'pin_num' to 'state', state can be
    either HIGH or LOW (defined macros).
    If state it's not valid will default to zero
 */
void GPL_set_pin(uint8_t pin_num, uint8_t state);

/*
    Sets the pin 'pin_num' to HIGH state or 1
*/
void GPL_set_pin_high(uint8_t pin_num);

/*
    Sets the pin 'pin_num' to low state or 0
*/
void GPL_set_pin_low(uint8_t pin_num);


/*
    Here are defined some helper functions that use HAL
    just to make life easier
    it requires that you bring HAL to the project and also
    enable HAL_HELPERS
*/
#ifdef HAL_HELPERS

#include <string.h>

#define GPL_UART_WRITE(MESSAGE) (AL_UART_Transmit(&huart1, (const uint8_t *)MESSAGE, strlen(MESSAGE), HAL_MAX_DELAY);)
// void uart_write(*char message);

#endif

#endif