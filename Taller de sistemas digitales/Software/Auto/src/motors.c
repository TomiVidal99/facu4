#include <avr/io.h>

#include "motors.h"

void init_motors_pwm()
{
  DDRD |= (1 << PD5) | (1 << PD6);

  TCCR0A |= (1 << COM0A1) | (1 << COM0B1) | (1 << WGM01) | (1 << WGM00);
  TCCR0B |= (1 << CS01); // Prescaler = 8 (16MHz / 8 = 2MHz timer clock)

  OCR0A = 0;
  OCR0B = 0;
}