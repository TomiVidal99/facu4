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

#define POWER_LED_PIN (PD3)

#define ADC_CHANNEL_SPEED (1U)
#define ADC_CHANNEL_ANGLE (0U)

#define CALIBRATIONS_OVERSAMPLING_SAMPLES_AMOUNT (40U)

nRF24L01 *setup_rf(void);

volatile bool rf_interrupt = false;
char STATE[7] = "SSSAAA\n"; // example: +10080 -> velocidad 100 %, rotar 80%

// volatile uint16_t max_value_calibration[2] = {0};
volatile uint16_t max_meas_speed = 1023;
volatile uint16_t max_meas_angle = 1023;

#ifdef DEBUG
char *sender_message = "Sender started...\n\r";
#endif

int main(void)
{
  int i = 0;
  int j = 0;

#ifdef DEBUG
  USART_init();
  USART_putstring(sender_message);
  sprintf(sender_message, "Sending message\n\r");
#endif

  adc_init();
  DDRD |= (1 << POWER_LED_PIN);
  PORTD |= (1 << POWER_LED_PIN);

  _delay_ms(10);

  uint8_t to_address[5] = {0x01, 0x01, 0x01, 0x01, 0x01};
  sei();
  nRF24L01 *rf = setup_rf();

  // Se verifica si el usuario quiere calibrar los potenciómetros
  for (i = 0; i < 5; i++)
  {
    if (adc_read_raw(ADC_CHANNEL_SPEED) > 900 && adc_read_raw(ADC_CHANNEL_SPEED) > 900)
    {

      // Modo de calibración
      // Se lee el máximo valor de los potenciómetros,
      // para luego enviar el valor correcto del porcentaje
#ifdef DEBUG
      sprintf(sender_message, "PREPARARSE PARA CALIBRACIÓN.\n\r");
      USART_putstring(sender_message);
#endif
      _delay_ms(2000);

#ifdef DEBUG
      sprintf(sender_message, "CALIBRACIÓN.\n\r (speed) \r\n");
      USART_putstring(sender_message);
#endif
      calibrate_potenciometer(ADC_CHANNEL_SPEED);

      _delay_ms(3000);

#ifdef DEBUG
      sprintf(sender_message, "CALIBRACIÓN.\n\r (angle) \r\n");
      USART_putstring(sender_message);
#endif
      calibrate_potenciometer(ADC_CHANNEL_ANGLE);

      _delay_ms(3000);

#ifdef DEBUG
      sprintf(sender_message, "calibration refs: \n\r speed: %d \n\r angle: %d \n\r", max_meas_speed, max_meas_angle);
      USART_putstring(sender_message);
#endif

      _delay_ms(6000);
      break;
    }

#ifdef DEBUG
    sprintf(sender_message, "*");
    USART_putstring(sender_message);
#endif

    // Delay de 500ms
    for (j = 0; j < 3; j++)
    {
      PORTD &= ~(1 << POWER_LED_PIN);
      _delay_ms(100);
      PORTD |= (1 << POWER_LED_PIN);
      _delay_ms(100);
    }
  }

  while (true)
  {
    if (rf_interrupt)
    {
      rf_interrupt = false;
      int success = nRF24L01_transmit_success(rf);
      if (success != 0)
        nRF24L01_flush_transmit_message(rf);
    }

    uint8_t angle = adc_read(ADC_CHANNEL_ANGLE);
    uint8_t speed = adc_read(ADC_CHANNEL_SPEED);
    speed = 100 - speed;

    // #ifdef DEBUG
    //     // sprintf(sender_message, "read speed: %d, raw: %d, ref: %d \r\n", speed, adc_read_raw(ADC_CHANNEL_SPEED), max_meas_speed);
    //     sprintf(sender_message, "speed: %d, ", speed);
    //     USART_putstring(sender_message);
    //     sprintf(sender_message, "angle: %d\n\r", angle);
    //     USART_putstring(sender_message);
    // #endif

    sprintf(STATE, "%03d%03d", speed, angle);

#ifdef DEBUG
    sprintf(sender_message, "%s\r\n", STATE);
    USART_putstring(sender_message);
#endif
    nRF24L01Message msg;
    memcpy(msg.data, STATE, 6);
    msg.length = strlen((char *)msg.data) + 1;
    nRF24L01_transmit(rf, to_address, &msg);

    _delay_ms(100);
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
  ADMUX |= (1 << REFS0);
  ADCSRA |= (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
}

uint8_t adc_read(uint8_t channel)
{
  ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);
  ADCSRA |= (1 << ADSC);
  while (ADCSRA & (1 << ADSC))
    ;
  uint16_t max_value = 0;
  if (channel == ADC_CHANNEL_ANGLE)
  {
    max_value = max_meas_angle;
  }
  else if (channel == ADC_CHANNEL_SPEED)
  {
    max_value = max_meas_speed;
  }
  else
  {
    // TODO: throw error
    return 0;
  }
  return (uint8_t)(((uint32_t)ADC * (uint32_t)100UL) / (uint32_t)max_value);
}

uint16_t adc_read_raw(uint8_t channel)
{
  ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);
  ADCSRA |= (1 << ADSC);
  while (ADCSRA & (1 << ADSC))
    ;
  return ADC;
}

void calibrate_potenciometer(uint8_t channel)
{
  uint16_t acc_adc_meas = 0;
  uint8_t i = 0;

  // se espera que el usuario esté listo para hacer la calibración
  while (adc_read_raw(channel) < 900)
  {
    PORTD &= ~(1 << POWER_LED_PIN);
    _delay_ms(100);
    PORTD |= (1 << POWER_LED_PIN);
    _delay_ms(100);
  }

#ifdef DEBUG
  sprintf(sender_message, "calibrando... \n\r (mantenga presionado) \r\n");
  USART_putstring(sender_message);
#endif
  _delay_ms(1000);
  acc_adc_meas = 0;
  for (i = 0; i < CALIBRATIONS_OVERSAMPLING_SAMPLES_AMOUNT; i++)
  {
    _delay_ms(100);
    acc_adc_meas += adc_read_raw(channel);
  }
  // max_value_calibration[channel] = acc_adc_meas / CALIBRATIONS_OVERSAMPLING_SAMPLES_AMOUNT;
  if (channel == ADC_CHANNEL_ANGLE)
  {
    max_meas_angle = acc_adc_meas / CALIBRATIONS_OVERSAMPLING_SAMPLES_AMOUNT;
  }
  else if (channel == ADC_CHANNEL_SPEED)
  {
    max_meas_speed = acc_adc_meas / CALIBRATIONS_OVERSAMPLING_SAMPLES_AMOUNT;
  }
#ifdef DEBUG
  sprintf(sender_message, "value: %d \r\n", acc_adc_meas / CALIBRATIONS_OVERSAMPLING_SAMPLES_AMOUNT);
  USART_putstring(sender_message);
#endif
}