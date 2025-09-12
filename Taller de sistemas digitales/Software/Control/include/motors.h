/**
 * Author: Tomás Vidal
 * This is a library that controls two DC motors
 * It's supposed to be connected to a L293N controller board
 * PINS:
 * - PIN 3 -> PWM motor A
 * - PIN 6 -> PWM motor B
 * TODO: Need to create PWM for reverse
 */

 #ifndef __MOTORS_
 #define __MOTORS_

/**
 * This are the definitions for which motor is which
 */
#define MOTOR_LEFT 0
#define MOTOR_RIGHT 1

/**
 * These macros are for setting the PWM duty cycle
 * DUTY_CYCLE_PERCENT -> from 0 to 100
 */
#define MOTOR_RIGHT_SET_PWM(DUTY_CYCLE_PERCENT) (OCR2B = 255 * DUTY_CYCLE_PERCENT / 100)
#define MOTOR_LEFT_SET_PWM(DUTY_CYCLE_PERCENT) (OCR0A = 255 * DUTY_CYCLE_PERCENT / 100)

/**
 * Initializes two timers (timer 0 and timer 2 of the 
 * ATMega328P) to trigger two PWM with variable duty cycles
 *
 * OCR0A -> can vary from 0 to 255
 * OCR2B -> can vary from 0 to 255
 * 
 */
void init_motors_pwm();

/**
 * USAGE:
 * 
 * void main() {
 *  init_motors_pwm();
 *  MOTOR_RIGHT_SET_PWM(80);
 * 
 *  while(1){}
 *  return 0;
 * }
 */

 #endif