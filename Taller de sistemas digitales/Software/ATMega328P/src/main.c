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
#include "servo.h"

int main(void)
{
  i2c_init();
  lcd_init();
  lcd_set_cursor(0, 0);
  lcd_write_string("Servo test:");

  while (1)
  {
  }
  return 0;
}
