// // noise channel functions set

// #include "noisech.h"
// #include <stdint.h>
// #include <avr/io.h>
// #include "noisech.h"

// extern volatile uint8_t noise_length;
// extern volatile uint8_t noise_freq_counter;
// extern volatile uint8_t noise_freq_counter_aux;
// extern volatile uint8_t noise_width;

// void set_noise_freq(uint8_t div, uint8_t shift, uint8_t width)
// {

//     int divisor;

//     if (div > 0) {
//         divisor = 8;
//     } else {
//         divisor = div << 4; //(div*16)
//     }

//     noise_freq_counter = CLKB / (CLKB / (divisor << shift));
//     noise_freq_counter_aux = noise_freq_counter;

//     noise_width = width;
// }

// uint16_t lfsr_shift(uint8_t width, uint16_t lfsr_reg)
// { // shifts LFSR register state.

//     uint8_t bit0 = lfsr_reg & 1;
//     uint8_t bit1 = (lfsr_reg >> 1) & 1;
//     uint8_t xnor_result = ~(bit0 ^ bit1) & 1;

//     lfsr_reg = (lfsr_reg >> 1) | (xnor_result << 15);

//     if (width == 1)

//         lfsr_reg = (lfsr_reg) | (xnor_result << 7);

//     return lfsr_reg;
// }

// uint8_t lfsr_get(uint16_t lfsr_reg)
// { // Returns first bit of LFSR 16 bit register

//     return (lfsr_reg & 1);
// }

// void noise_trigger(uint8_t length, uint8_t div, uint8_t shift, uint8_t width)
// {

//     set_noise_freq(div, shift, width);

//     noise_length = length;

//     DDRC |= (1 << PC0); // Turns on PC0
// }