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
    EQUALIZER_MENU = 0x2,
    EQUALIZER_HIGH = 0x3,
    EQUALIZER_MID = 0x4,
    EQUALIZER_LOW = 0x5,
    FOLDER_SEARCH = 0x6,
    FILES_SEARCH = 0x7,
    FILES = 0x8,
    DIRECTORIES = 0x9,
    ERROR_STATE = 0x10,
    EQUALIZER = 0x11,

    DISPLAY_MENU_LENGTH,
  } DisplayMenu;

  typedef struct
  {
    DisplayMenu menu;
    char errorMessage[64];
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

#define MAX_FILES 10
#define FILE_NAME_LENGTH 16
#define FILEPATHS_LENGTH 16
  typedef struct
  {
    char filenames[MAX_FILES][FILE_NAME_LENGTH];
    uint16_t fileCount;
    uint16_t selectedIndex;
  } FileBrowser;

  typedef struct
  {
    Bool isPlaying;
    Bool shouldLoadBuffer;
    Bool isReadingMusicFile;
    char filename[FILE_NAME_LENGTH];
    int bufIndex;
    char currentPath[FILEPATHS_LENGTH];
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
#define DEBUG_ERROR_HANDLER_Pin GPIO_PIN_13
#define DEBUG_ERROR_HANDLER_GPIO_Port GPIOC
#define ENCODER_A_Pin GPIO_PIN_14
#define ENCODER_A_GPIO_Port GPIOC
#define ENCODER_B_Pin GPIO_PIN_15
#define ENCODER_B_GPIO_Port GPIOC
#define AUDIO_PWM_OUTPUT_Pin GPIO_PIN_0
#define AUDIO_PWM_OUTPUT_GPIO_Port GPIOA
#define BTN_BACK_Pin GPIO_PIN_2
#define BTN_BACK_GPIO_Port GPIOA
#define BTN_ENTER_Pin GPIO_PIN_3
#define BTN_ENTER_GPIO_Port GPIOA
#define SD_CS_Pin GPIO_PIN_1
#define SD_CS_GPIO_Port GPIOB
#define DEBUG_ERROR_HANDLERB10_Pin GPIO_PIN_10
#define DEBUG_ERROR_HANDLERB10_GPIO_Port GPIOB
#define DEBUG_SCHEDULER_TICK_Pin GPIO_PIN_8
#define DEBUG_SCHEDULER_TICK_GPIO_Port GPIOA
#define DEBUG_TASK_DEFAULT_Pin GPIO_PIN_9
#define DEBUG_TASK_DEFAULT_GPIO_Port GPIOA
#define DEBUG_TASK_ENCODER_Pin GPIO_PIN_10
#define DEBUG_TASK_ENCODER_GPIO_Port GPIOA
#define DEBUG_TASK_PLAYER_Pin GPIO_PIN_11
#define DEBUG_TASK_PLAYER_GPIO_Port GPIOA
#define DEBUG_TASK_MENU_Pin GPIO_PIN_12
#define DEBUG_TASK_MENU_GPIO_Port GPIOA
#define DEBUG_TASK_BUTTONS_Pin GPIO_PIN_15
#define DEBUG_TASK_BUTTONS_GPIO_Port GPIOA

/* USER CODE BEGIN Private defines */

#define SD_SPI_HANDLE hspi2

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
