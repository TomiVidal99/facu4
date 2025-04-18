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

#include <i2c.h>
#include <LCD.h>
// #include "uart.h"

#define MOTOR_RIGHT_PWM(PWM_DUTY_CYCLE) (OCR2B = 255 * PWM_DUTY_CYCLE / 100)
#define MOTOR_LEFT_PWM(PWM_DUTY_CYCLE) (OCR0A = 255 * PWM_DUTY_CYCLE / 100)
#define MOTOR_LEFT 0
#define MOTOR_RIGHT 1

int main(void)
{
  init_motors_pwm();

  i2c_init();
  lcd_init();
  lcd_set_cursor(0, 0);
  lcd_write_string("GIRANDO MOTOR:");
  // lcd_set_cursor(1, 0);
  // lcd_write_string("motores");

  _delay_ms(1000);
  lcd_clear();

  uint8_t motor = MOTOR_RIGHT;

  while (1)
  {

    lcd_set_cursor(1, 0);

    if (motor == MOTOR_LEFT)
    {
      lcd_write_string("Izquierdo  ");
      MOTOR_LEFT_PWM(10);
      MOTOR_RIGHT_PWM(0);
      motor = MOTOR_RIGHT;
    }
    else
    {
      lcd_write_string("Derecho    ");
      MOTOR_LEFT_PWM(0);
      MOTOR_RIGHT_PWM(10);
      motor = MOTOR_LEFT;
    }

    // sprintf(LCD_msg, "PWM CDT: %d%%", counter);
    // lcd_set_cursor(0, 0);
    // lcd_write_string((const char*)LCD_msg);

    // OCR0A = 255 * counter / 100;

    // if (counter > 99) {
    //   counter = 0;
    // } else {
    //   counter++;
    // }

    _delay_ms(5000);
  }
  return 0;
}

void init_motors_pwm()
{
  // --- TIMER 0 --- (controls PD6 = OC0A)

  // Set PD6 (OC0A) as output
  DDRD |= (1 << PD6);

  // Fast PWM mode: WGM02:0 = 3 (0b011)
  // COM0A1:0 = 2 (non-inverting mode: clear OC0A on compare match, set at BOTTOM)
  TCCR0A = (1 << COM0A1) | (1 << WGM01) | (1 << WGM00);
  TCCR0B = (1 << CS01) | (1 << CS00); // prescaler = 64

  OCR0A = 0; // initial duty cycle = 0% (motor stopped)

  // --- TIMER 2 --- (controls PD3 = OC2B)

  // Set PD3 (OC2B) as output
  DDRD |= (1 << PD3);

  // Fast PWM mode: WGM22:0 = 3 (0b011)
  // COM2B1:0 = 2 (non-inverting mode)
  TCCR2A = (1 << COM2B1) | (1 << WGM21) | (1 << WGM20);
  TCCR2B = (1 << CS22); // prescaler = 64

  OCR2B = 0; // initial duty cycle = 0% (motor stopped)
}

// void init_adc()
// {
//   ADMUX |= (1 << REFS0);
//   ADCSRA |= (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
//   ADCSRA |= (1 << ADEN);
// }