/**
 * Author: Tomás Vidal
 *
 * This library is for controlling a servo
 * It works by sending a PWM signal to the signal pin
 * of the servo.
 * This signal it's of period 20ms and the duty cycle goes
 * from 2.75% to 10%, to move the servo from 0° to 180°
 *
 */

#ifndef __SERVO_
#define __SERVO_

#include <stdint.h>

/**
 * IMPORTANT:
 * These are the macros that the user should define.
 * Also the pins that can be set for the servo are
 * just the ones from the port B of the ATMega328P.
 */
// #define SERVO_PIN (9)

/**
 * These times are all thought to be for a 16MHz clock
 */
#define SERVO_PERIOD (3750) // 20ms
#define SERVO_PWM_MIN (104)  // 550us
#define SERVO_PWM_MAX (375) // 2ms

#define SERVO_MAX_ANGLE 180
#define SERVO_MIN_ANGLE 0

#define SERVO_BIT_LOW 0
#define SERVO_BIT_HIGH 1

/**
 * This is for initializing the servo. It just
 * enables the output pin
 */
void SERVO_init(void);

/**
 * This is a function that's meant to be called every
 * clock cycle and it's non blocking
 */
void SERVO_update(void);

/**
 * This sets the position of the servo
 * it's expected to recieve a degree,
 * ranging from 0° to 180°
 */
void SERVO_set_angle(uint8_t degrees);

/**
 * USAGE:
 *
 * #include "servo.h"
 *
 * #define SERVO_PIN 8
 *
 * void main() {
 *
 *   SERVO_init();
 *   SERVO_set_angle(90);
 *
 *   while (1)
 *   {
 *     SERVO_update();
 *   }
 *   return 0;
 * }
 */

#endif
