#ifndef F_CPU
#define F_CPU 16000000UL
#endif

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "UART.h"
#include "nrf24l01.h"
#include "nrf24l01-mnemonics.h"

#define DEBUG
#ifdef DEBUG
char buf[50];
#endif

nRF24L01 *setup_rf(void);

int main(void)
{
  USART_init();
  USART_putstring("nRF24L01 Debug Test Started...\n\r");

  sei();
  nRF24L01 *rf = setup_rf();

  // Log SPI control register
  sprintf(buf, "SPCR: 0x%02X, SPSR: 0x%02X\n\r", SPCR, SPSR);
  USART_putstring(buf);

  // Test 1: Write and read CONFIG
  uint8_t test_config = 0x0F; // PWR_UP=1, EN_CRC=1, CRCO=1, PRIM_RX=1
  nRF24L01_write_register(rf, CONFIG, &test_config, 1);
  _delay_ms(5);
  uint8_t read_config;
  nRF24L01_read_register(rf, CONFIG, &read_config, 1);

  if (read_config == test_config)
  {
    USART_putstring("CONFIG Test: PASS\n\r");
  }
  else
  {
    sprintf(buf, "CONFIG Test: FAIL (Wrote 0x%02X, Read 0x%02X)\n\r", test_config, read_config);
    USART_putstring(buf);
  }

  // Test 2: Read STATUS
  uint8_t status;
  nRF24L01_read_register(rf, STATUS, &status, 1);
  if (status != 0x00 && status != 0xFF)
  {
    sprintf(buf, "STATUS Test: PASS (Read 0x%02X)\n\r", status);
    USART_putstring(buf);
  }
  else
  {
    sprintf(buf, "STATUS Test: FAIL (Read 0x%02X)\n\r", status);
    USART_putstring(buf);
  }

  // Test 3: Write and read RF_SETUP
  uint8_t test_rf_setup = 0x0E; // 1Mbps, 0dBm
  nRF24L01_write_register(rf, RF_SETUP, &test_rf_setup, 1);
  _delay_ms(5);
  uint8_t read_rf_setup;
  nRF24L01_read_register(rf, RF_SETUP, &read_rf_setup, 1);

  if (read_rf_setup == test_rf_setup)
  {
    USART_putstring("RF_SETUP Test: PASS\n\r");
  }
  else
  {
    sprintf(buf, "RF_SETUP Test: FAIL (Wrote 0x%02X, Read 0x%02X)\n\r", test_rf_setup, read_rf_setup);
    USART_putstring(buf);
  }

  // Final result
  if (read_config == test_config && status != 0x00 && status != 0xFF && read_rf_setup == test_rf_setup)
  {
    USART_putstring("nRF24L01 Connection: OK\n\r");
  }
  else
  {
    USART_putstring("nRF24L01 Connection: FAILED\n\r");
    USART_putstring("Check MOSI, CSN, SPI settings, or try another module.\n\r");
  }

  while (true)
  {
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
  EICRA |= _BV(ISC01);
  EIMSK |= _BV(INT0);
  _delay_ms(100); // Power-up delay
  // Set slower SPI clock
  SPCR |= (1 << SPR1) | (1 << SPR0); // F_CPU/64 (250kHz)
  SPSR &= ~(1 << SPI2X);
  _delay_ms(50);
  nRF24L01_begin(rf);
  // Log CE pin state
  sprintf(buf, "CE pin state: %d\n\r", (PORTB & (1 << PB1)) >> PB1);
  USART_putstring(buf);
  return rf;
}