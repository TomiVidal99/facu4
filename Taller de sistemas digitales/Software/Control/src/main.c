/*
 * main.c
 * Control remoto para el auto FPV
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
#include <util/delay.h>

#include "nrf24l01.h"

#include "definitions.h"
#include "UART.h"

#define DEBUG

nRF24L01 *setup_rf(void);

volatile bool rf_interrupt = false;
// El tamaño es 7 porque hay un caracter al final \0
char STATE[7] = "SSSAAA"; // example: +100180 -> velocidad 100 adelante, rotar 180 grados

#ifdef DEBUG
char *sender_message = "Sender started...\n\r";
#endif

int main(void)
{
#ifdef DEBUG
  USART_init();
  USART_putstring(sender_message);
  sprintf(sender_message, "Sending message\n\r");
#endif

  adc_init();

  uint8_t to_address[5] = {0x01, 0x01, 0x01, 0x01, 0x01};
  sei();
  nRF24L01 *rf = setup_rf();

  while (true)
  {
    if (rf_interrupt)
    {
      rf_interrupt = false;
      int success = nRF24L01_transmit_success(rf);
      if (success != 0)
        nRF24L01_flush_transmit_message(rf);
    }

    uint8_t speed = adc_read(0);
    uint8_t angle = adc_read(1);

#ifdef DEBUG
    sprintf(STATE, "%03d%03d", speed, angle);
    USART_putstring(sender_message);
#endif

#ifdef DEBUG
    sprintf(sender_message, "%s\r\n", STATE);
    USART_putstring(sender_message);
#endif
    nRF24L01Message msg;
    memcpy(msg.data, STATE, 6);
    msg.length = strlen((char *)msg.data) + 1;
    nRF24L01_transmit(rf, to_address, &msg);
  }

  return 0;
}

nRF24L01 *setup_rf(void)
{
  nRF24L01 *rf = nRF24L01_init();
  rf->ss.port = &PORTB;
  rf->ss.pin = PB2;
  rf->ce.port = &PORTB;
  rf->ce.pin = PB1;
  rf->sck.port = &PORTB;
  rf->sck.pin = PB5;
  rf->mosi.port = &PORTB;
  rf->mosi.pin = PB3;
  rf->miso.port = &PORTB;
  rf->miso.pin = PB4;
  // interrupt on falling edge of INT0 (PD2)
  EICRA |= _BV(ISC01);
  EIMSK |= _BV(INT0);
  nRF24L01_begin(rf);
  return rf;
}

// nRF24L01 interrupt
ISR(INT0_vect)
{
  rf_interrupt = true;
}

void adc_init()
{
  ADMUX |= (1 << REFS0);                                              // Use AVcc as voltage reference
  ADCSRA |= (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0); // Enable ADC, prescaler 128
}

uint8_t adc_read(uint8_t channel)
{
  ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);
  ADCSRA |= (1 << ADSC);
  while (ADCSRA & (1 << ADSC))
    ;
  return (uint8_t)((ADC * 100UL) / 1023);
}