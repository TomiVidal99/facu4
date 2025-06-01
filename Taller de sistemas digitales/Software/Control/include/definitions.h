#include <stdint.h>

// - - - - - - - - - - -  FUNCIONES - - - - - - - - - -

/**
 * Los motores se controlan variando una pwm.
 * Se tienen que configurar los siguientes registros
 * con un valor de 0 a 255.
 * OCR0A = 128; // 50% duty cycle on motor 1
 * OCR2B = 200; // ~78% duty cycle on motor 2
 */
void init_adc();
void init_button_interrupt();

void adc_init();
uint8_t adc_read(uint8_t channel);