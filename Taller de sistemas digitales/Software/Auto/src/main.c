#define F_CPU 16000000UL
#define CLKB 262144UL
#define CLKA 256UL

// #include "noisech.h"
#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#define CLKB 262144UL
#define CLKA 256UL

uint16_t lfsr_shift(uint8_t width, uint16_t lfsr_reg);
// uint16_t set_noise_envelope(void);
void set_noise_freq(uint8_t div, uint8_t shift, uint8_t width); // div = 3 bits, wid 1 en 7, 0 en 15, shift = 4 bits
uint8_t lfsr_get(uint16_t lfsr_reg);
void noise_trigger(uint8_t length, uint8_t div, uint8_t shift, uint8_t width);

volatile uint8_t noise_length = 1;
volatile uint8_t noise_freq_counter;
volatile uint8_t noise_freq_counter_aux;
volatile uint16_t LFSRstatus = 0b00000000000000000;
volatile uint8_t noise_width = 0;

ISR(TIMER0_COMPA_vect)
{

    // Length control. This interrupt decreases length counter for each channel
    // and checks if it should be turned off.

    if (noise_length > 0)
    {
        noise_length--;
    }

    if (noise_length == 0)
    {
        // PORTB ^= (1 << PB1);
        PORTB |= (1 << PB1);
        DDRC &= ~(1 << PC0); // Turn off PC0
    }
}

volatile uint8_t bit0;
volatile uint8_t bit1;
volatile uint8_t xnor_result;
ISR(TIMER1_COMPA_vect)
{

    PORTB ^= (1 << PB0);

    noise_freq_counter_aux--;

    if (noise_freq_counter_aux == 0)
    {

        // LFSRstatus = lfsr_shift(noise_width, LFSRstatus); // 1 short, 0 long
        bit0 = LFSRstatus & 1;
        bit1 = (LFSRstatus >> 1) & 1;
        xnor_result = ~(bit0 ^ bit1) & 1;

        LFSRstatus = (LFSRstatus >> 1) | (xnor_result << 15);

        if (noise_width == 1)
            LFSRstatus = (LFSRstatus) | (xnor_result << 7);

        PORTC = (PORTC & ~(1 << PC0)) | (((LFSRstatus & 1) & 0x01) << PC0);
        noise_freq_counter_aux = noise_freq_counter;
    }
}

int main(void)
{

    // CONFIGURACION TIMER0 - DURATION

    TCCR0A = (1 << WGM01); // CTC

    OCR0A = 220; // COMPA value 256hz

    TCCR0B = (1 << CS02); // 256 prescaler

    TIMSK0 = (1 << OCIE0A); // Interrupt enable

    // CONFIGURACION TIMER1 - NOISE FREQ

    TCCR1B = (1 << WGM12) | (1 << CS10); // CTC, predscaler 0

    OCR1A = 60; // COMPA value 262144hz

    TIMSK1 = (1 << OCIE1A); // Interrupt enable

    sei();

    // CONFIGURACIÓN PUERTOS

    DDRB = 0xF;
    DDRC = 0x1;
    DDRD = 0xF;

    DDRB |= (1 << PB0);
    DDRB |= (1 << PB1);

    // INICIALIZACION LFSR

    while (1)
    {
        noise_trigger(61, 1, 7, 0); // length 6 bits, div 3 bits, shift 4 bits, mode 1 bit
        _delay_ms(10000);
    }
}
void set_noise_freq(uint8_t div, uint8_t shift, uint8_t width)
{

    int divisor;

    if (div > 0)
    {
        divisor = 8;
    }
    else
    {
        divisor = div << 4; //(div*16)
    }

    noise_freq_counter = CLKB / (CLKB / (divisor << shift));
    noise_freq_counter_aux = noise_freq_counter;

    noise_width = width;
}

uint16_t lfsr_shift(uint8_t width, uint16_t lfsr_reg)
{ // shifts LFSR register state.

    uint8_t bit0 = lfsr_reg & 1;
    uint8_t bit1 = (lfsr_reg >> 1) & 1;
    uint8_t xnor_result = ~(bit0 ^ bit1) & 1;

    lfsr_reg = (lfsr_reg >> 1) | (xnor_result << 15);

    if (width == 1)

        lfsr_reg = (lfsr_reg) | (xnor_result << 7);

    return lfsr_reg;
}

uint8_t lfsr_get(uint16_t lfsr_reg)
{ // Returns first bit of LFSR 16 bit register

    return (lfsr_reg & 1);
}

void noise_trigger(uint8_t length, uint8_t div, uint8_t shift, uint8_t width)
{

    set_noise_freq(div, shift, width);

    noise_length = length;

    DDRC |= (1 << PC0); // Turns on PC0
}