/*
 * main.c
 * Auto FPV
 * Author: Tomás Vidal
 */

#ifndef F_CPU
#define F_CPU 16000000UL
#endif

#include <stdio.h> //  for sprintf
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>
#include <string.h>

#include "definitions.h"

#include "motors.h"

#include "UART.h"

#include "nrf24l01.h"
#include "nrf24l01-mnemonics.h"

#include "servo.h"

#define DEBUG

#define MAX_SPEED 200

volatile bool rf_interrupt = false;

#ifdef DEBUG
char *recv_message = "Receiver started...\n\r";
#endif

int main(void)
{
#ifdef DEBUG
  USART_init();
  USART_putstring(recv_message);
#endif

  init_motors_pwm();
  SERVO_init();
  SERVO_set_angle(90);

  // Settings for the nRF24
  uint8_t address[5] = {0x01, 0x01, 0x01, 0x01, 0x01};
  sei();
  nRF24L01 *rf = setup_rf();
  nRF24L01_listen(rf, 0, address);
  uint8_t addr[5];
  nRF24L01_read_register(rf, CONFIG, addr, 1);

  while (true)
  {
    if (rf_interrupt)
    {
      rf_interrupt = false;
      while (nRF24L01_data_received(rf))
      {
        nRF24L01Message msg;
        nRF24L01_read_received_data(rf, &msg);
        process_message((char *)msg.data);
      }

      nRF24L01_listen(rf, 0, address);
    }
  }

  return 0;
}

ISR(TIMER2_COMPA_vect)
{
  SERVO_update();
}

nRF24L01 *setup_rf(void)
{
  nRF24L01 *rf = nRF24L01_init();
  rf->ss.port = &PORTB;
  rf->ss.pin = PB2; // 10
  rf->ce.port = &PORTB;
  rf->ce.pin = PB1; // 9
  rf->sck.port = &PORTB;
  rf->sck.pin = PB5; //  13
  rf->mosi.port = &PORTB;
  rf->mosi.pin = PB3; // 11
  rf->miso.port = &PORTB;
  rf->miso.pin = PB4; // 12
  // interrupt on falling edge of INT0 (PD2)
  EICRA |= _BV(ISC01);
  EIMSK |= _BV(INT0);
  nRF24L01_begin(rf);
  return rf;
}

void process_message(char *message)
{
  uint16_t speed_percentage;
  uint16_t angle_percentage;
  sscanf(message, "%3u%3u", &speed_percentage, &angle_percentage);

#ifdef DEBUG
  sprintf(recv_message, "Message: %s\n\r\t", message);
  USART_putstring(recv_message);
#endif

  if (speed_percentage > 55)
  {
    OCR0A = MAX_SPEED;
    OCR0B = 0;
  }
  else if (speed_percentage < 45)
  {
    OCR0A = 0;
    OCR0B = MAX_SPEED;
  }
  else
  {
    OCR0A = 0;
    OCR0B = 0;
  }

  if (angle_percentage > 70)
  {
    SERVO_set_angle(180);
  }
  else if (angle_percentage < 30)
  {
    SERVO_set_angle(0);
  }
  else
  {
    SERVO_set_angle(90);
  }
}

// nRF24L01 interrupt
ISR(INT0_vect)
{
  rf_interrupt = true;
}