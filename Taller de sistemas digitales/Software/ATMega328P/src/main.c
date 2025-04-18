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

// void init_adc()
// {
//   ADMUX |= (1 << REFS0);
//   ADCSRA |= (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
//   ADCSRA |= (1 << ADEN);
// }