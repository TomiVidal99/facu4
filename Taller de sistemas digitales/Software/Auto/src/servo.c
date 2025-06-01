#include <avr/io.h>
#include <avr/interrupt.h>
#include "servo.h"

volatile uint16_t __clock_counter_50us;
volatile uint16_t __stop_time_50us;

void SERVO_init(void)
{
    TCCR2A = (1 << WGM21);
    TCCR2B = (1 << CS21);
    OCR2A = 99;
    TIMSK2 = (1 << OCIE2A);
    sei();

    DDRD |= (1 << PD7);

    __clock_counter_50us = 0;
    __stop_time_50us = 11;
}

void SERVO_update()
{
    if (__clock_counter_50us <= 1)
    {
        PORTD |= (1 << PD7);
    }

    if (__clock_counter_50us >= __stop_time_50us)
    {
        PORTD &= ~(1 << PD7);
    }

    if (__clock_counter_50us >= 400)
    {
        __clock_counter_50us = 0;
    }

    __clock_counter_50us++;
}

void SERVO_set_angle(uint8_t degrees)
{
    __stop_time_50us = (11 * degrees + 550) / 50;
}