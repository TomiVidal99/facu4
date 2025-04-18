/*
 * main.c
 */

#ifndef F_CPU
#define F_CPU 16000000UL
#endif

#include <stdio.h>

#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>
#include <avr/io.h>

#include "definitions.h"

#include "i2c.h"
#include "LCD.h"
#include "motors.h"
// #include "uart.h"

#define LOW 0
#define HIGH 1
#define SERVO_PERIOD (18500) // 20ms
#define SERVO_PWM_MIN (480) // 550us
#define SERVO_PWM_MAX (2100) // 2ms

int main(void)
{
  // init_motors_pwm();
  // MOTOR_RIGHT_SET_PWM(50);

  i2c_init();
  lcd_init();
  lcd_set_cursor(0, 0);
  lcd_write_string("Servo test:");

  DDRB |= (1 << PB0);

  uint16_t counter = 0;
  uint16_t switch_counter = 0;
  uint8_t pulse_state = LOW;

  uint16_t servo_duty_cycle = SERVO_PWM_MAX;

  while (1)
  {
    if (pulse_state == LOW && counter >= SERVO_PERIOD)
    {
      PORTB |= (1 << PB0);
      counter = 0;
      pulse_state = 1;
    }
    else if (pulse_state == HIGH && counter >= servo_duty_cycle)
    {
      PORTB &= ~(1 << PB0);
      pulse_state = 0;
      switch_counter++;
    }
    counter++;

    switch (switch_counter)
    {
    case 100:
      servo_duty_cycle = SERVO_PWM_MIN;
      break;
    case 200:
    {
      servo_duty_cycle = SERVO_PWM_MAX;
      switch_counter = 0;
    }
    break;
    default:
      break;
    }
  }
  return 0;
}

// void init_adc()
// {
//   ADMUX |= (1 << REFS0);
//   ADCSRA |= (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
//   ADCSRA |= (1 << ADEN);
// }