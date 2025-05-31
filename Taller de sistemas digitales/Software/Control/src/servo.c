#include <avr/io.h>
#include <assert.h>

#include "servo.h"

uint16_t __servo_counter = 0;
uint16_t __servo_duty_cycle = SERVO_PWM_MAX;
uint8_t __pulse_state = SERVO_BIT_LOW;

void SERVO_init(void)
{
    DDRB |= (1 << PB0);
}

void SERVO_update(void)
{
    if (__pulse_state == SERVO_BIT_LOW && __servo_counter >= SERVO_PERIOD)
    {
        PORTB |= (1 << PB0);
        __servo_counter = 0;
        __pulse_state = 1;
    }
    else if (__pulse_state == SERVO_BIT_HIGH && __servo_counter >= __servo_duty_cycle)
    {
        PORTB &= ~(1 << PB0);
        __pulse_state = 0;
    }
    __servo_counter++;
}

void SERVO_set_angle(uint8_t degrees)
{
    // assert(degrees <= SERVO_MAX_ANGLE);

    __servo_duty_cycle = SERVO_PWM_MAX *  (float)(degrees / SERVO_MAX_ANGLE);
}