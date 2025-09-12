#include <avr/io.h>

#include "motors.h"

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