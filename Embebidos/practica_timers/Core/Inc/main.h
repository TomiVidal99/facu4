/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.h
 * @brief          : Header for main.c file.
 *                   This file contains the common defines of the application.
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2025 STMicroelectronics.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 *
 ******************************************************************************
 */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32f1xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */
  typedef enum
  {
    START = 0x0,
    MENU = 0x1,
    EQUALIZER = 0x2,
    EQUALIZER_HIGH = 0x3,
    EQUALIZER_MID = 0x4,
    EQUALIZER_LOW = 0x5,
    FOLDER_SEARCH = 0x6,
    FILES_SEARCH = 0x7,

    DISPLAY_MENU_LENGTH,
  } DisplayMenu;

  typedef struct
  {
    DisplayMenu menu;
  } DisplayParams;

  typedef enum
  {
    FALSE = 0x0,
    TRUE = 0x1
  } Bool;

  typedef enum
  {
    ACCEPT = 0x0,
    CANCEL = 0x1
  } ButtonType;

  typedef struct
  {
    ButtonType type;
    GPIO_TypeDef *port;
    uint16_t pin;
  } ButtonParams;

  typedef struct {
  	Bool isPlaying;

  } AudioPlayerOptions;
/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

void HAL_TIM_MspPostInit(TIM_HandleTypeDef *htim);

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define ENCODER_A_Pin GPIO_PIN_14
#define ENCODER_A_GPIO_Port GPIOC
#define ENCODER_B_Pin GPIO_PIN_15
#define ENCODER_B_GPIO_Port GPIOC
#define BTN_BACK_Pin GPIO_PIN_2
#define BTN_BACK_GPIO_Port GPIOA
#define BTN_ENTER_Pin GPIO_PIN_3
#define BTN_ENTER_GPIO_Port GPIOA
#define SD_CS_Pin GPIO_PIN_1
#define SD_CS_GPIO_Port GPIOB

/* USER CODE BEGIN Private defines */

#define SD_SPI_HANDLE hspi2

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
