#include "GeneralPurposeLibrary.h"

void GPL_set_pin(uint8_t pin_num, uint8_t state)
{
    switch (state)
    {
    case HIGH:
        *((uint32_t *)DIR_DWT_CONTROL) |= (1 << pin_num);
        break;
    default:
        *((uint32_t *)DIR_DWT_CONTROL) &= ~(1 << pin_num);
        break;
    }
}

void GPL_set_pin_high(uint8_t pin_num)
{
    *((uint32_t *)DIR_DWT_CONTROL) |= (1 << pin_num);
}

void GPL_set_pin_low(uint8_t pin_num)
{
    *((uint32_t *)DIR_DWT_CONTROL) &= ~(1 << pin_num);
}

#ifdef HAL_HELPERS

// void uart_write(*char message)
// {
//     AL_UART_Transmit(&huart1, (const uint8_t *)message, strlen(pData), HAL_MAX_DELAY);
// }

#endif