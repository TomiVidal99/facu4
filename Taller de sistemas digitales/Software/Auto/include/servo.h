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
 * These times are all thought to be for a 16MHz clock
 */

void SERVO_init(void);
void SERVO_set_angle(uint8_t degrees);
void SERVO_update();

#endif
