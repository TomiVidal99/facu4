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
#include "servo.h"
// #include "uart.h"

#define CLOCKS_PER_MS (188)

int main(void)
{
  // init_motors_pwm();
  // MOTOR_RIGHT_SET_PWM(50);

  // i2c_init();
  // lcd_init();
  // lcd_set_cursor(0, 0);
  // lcd_write_string("Servo test:");

  SERVO_init();

  uint16_t ms_counter = 0;
  uint16_t sec_counter = 0;

  SERVO_set_angle(0);

  while (1)
  {
    SERVO_update();
    ms_counter++;
    if (ms_counter > CLOCKS_PER_MS) {
      sec_counter++;
      ms_counter=0;
    }
    switch (sec_counter)
    {
    case 1000:
      SERVO_set_angle(90);
      break;
    case 2000:
      SERVO_set_angle(120);
      break;
    case 3000:
      SERVO_set_angle(180);
      ms_counter=0;
      break;
    
    default:
      break;
    }
  }
  return 0;
}
