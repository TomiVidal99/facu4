/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.c
 * @brief          : Main program body
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
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "cmsis_os.h"
#include "fatfs.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "fonts.h"
#include "ssd1306.h"
#include "user_diskio_spi.h"

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define TEXT_X_OFFSET 10

// definiciones para el encoder
#define ENCODER_DEBOUCE_DELAY 400
#define ENCODER_A_POS (0)
#define ENCODER_B_POS (1)
#define ENCODER_A_PREV_STATE (0b00000100)
#define ENCODER_B_PREV_STATE (0b00001000)
#define ENCODER_A_STATE (0b00000001)
#define ENCODER_B_STATE (0b00000010)
#define GET_ENCODER_DIRECTION(_state) ((_state & ENCODER_B_STATE) != (_state & ENCODER_A_STATE))

// cosas para debugear
// se puede elegir que es lo que se prubea para aislar los errores
#define ACTIVATE_DEBUG_PIN() (HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_10))
#define DEBUG_SD
// #define DEBUG_SCREEN
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
I2C_HandleTypeDef hi2c1;

SPI_HandleTypeDef hspi2;

TIM_HandleTypeDef htim2;

/* Definitions for defaultTask */
osThreadId_t defaultTaskHandle;
const osThreadAttr_t defaultTask_attributes = { .name = "defaultTask",
		.stack_size = 640 * 4, .priority = (osPriority_t) osPriorityNormal, };
/* Definitions for menuTask */
osThreadId_t menuTaskHandle;
const osThreadAttr_t menuTask_attributes = { .name = "menuTask", .stack_size =
		256 * 4, .priority = (osPriority_t) osPriorityLow, };
/* Definitions for acceptButtonTas */
osThreadId_t acceptButtonTasHandle;
const osThreadAttr_t acceptButtonTas_attributes = { .name = "acceptButtonTas",
		.stack_size = 128 * 4, .priority = (osPriority_t) osPriorityLow, };
/* Definitions for cancelButtonTas */
osThreadId_t cancelButtonTasHandle;
const osThreadAttr_t cancelButtonTas_attributes = { .name = "cancelButtonTas",
		.stack_size = 128 * 4, .priority = (osPriority_t) osPriorityLow, };
/* Definitions for encoderTask */
osThreadId_t encoderTaskHandle;
const osThreadAttr_t encoderTask_attributes = { .name = "encoderTask",
		.stack_size = 128 * 4, .priority = (osPriority_t) osPriorityLow, };
/* USER CODE BEGIN PV */

static DisplayParams displayParams = { .menu = START };

const ButtonParams acceptButtonParams = { .type = ACCEPT, .port = GPIOA, .pin =
GPIO_PIN_3 };
const ButtonParams cancelButtonParams = { .type = CANCEL, .port = GPIOA, .pin =
GPIO_PIN_2 };

uint32_t prev_point_angle = 0;
uint32_t point_angle = 0;
uint32_t lastInteractionTick = 0;

// Para no usar 'math.h' uso una tabla de valores
const float sin_table[361] = { 0.00000f, 0.03490f, 0.06976f, 0.10453f, 0.13917f,
		0.17365f, 0.20791f, 0.24192f, 0.27564f, 0.30902f, 0.34202f, 0.37461f,
		0.40674f, 0.43837f, 0.46947f, 0.50000f, 0.52992f, 0.55919f, 0.58779f,
		0.61566f, 0.64279f, 0.66913f, 0.69466f, 0.71934f, 0.74314f, 0.76604f,
		0.78801f, 0.80902f, 0.82904f, 0.84805f, 0.86603f, 0.88295f, 0.89879f,
		0.91355f, 0.92718f, 0.93969f, 0.95106f, 0.96126f, 0.97030f, 0.97815f,
		0.98481f, 0.99027f, 0.99452f, 0.99756f, 0.99939f, 1.00000f, 0.99939f,
		0.99756f, 0.99452f, 0.99027f, 0.98481f, 0.97815f, 0.97030f, 0.96126f,
		0.95106f, 0.93969f, 0.92718f, 0.91355f, 0.89879f, 0.88295f, 0.86603f,
		0.84805f, 0.82904f, 0.80902f, 0.78801f, 0.76604f, 0.74314f, 0.71934f,
		0.69466f, 0.66913f, 0.64279f, 0.61566f, 0.58779f, 0.55919f, 0.52992f,
		0.50000f, 0.46947f, 0.43837f, 0.40674f, 0.37461f, 0.34202f, 0.30902f,
		0.27564f, 0.24192f, 0.20791f, 0.17365f, 0.13917f, 0.10453f, 0.06976f,
		0.03490f, 0.00000f, -0.03490f, -0.06976f, -0.10453f, -0.13917f,
		-0.17365f, -0.20791f, -0.24192f, -0.27564f, -0.30902f, -0.34202f,
		-0.37461f, -0.40674f, -0.43837f, -0.46947f, -0.50000f, -0.52992f,
		-0.55919f, -0.58779f, -0.61566f, -0.64279f, -0.66913f, -0.69466f,
		-0.71934f, -0.74314f, -0.76604f, -0.78801f, -0.80902f, -0.82904f,
		-0.84805f, -0.86603f, -0.88295f, -0.89879f, -0.91355f, -0.92718f,
		-0.93969f, -0.95106f, -0.96126f, -0.97030f, -0.97815f, -0.98481f,
		-0.99027f, -0.99452f, -0.99756f, -0.99939f, -1.00000f, -0.99939f,
		-0.99756f, -0.99452f, -0.99027f, -0.98481f, -0.97815f, -0.97030f,
		-0.96126f, -0.95106f, -0.93969f, -0.92718f, -0.91355f, -0.89879f,
		-0.88295f, -0.86603f, -0.84805f, -0.82904f, -0.80902f, -0.78801f,
		-0.76604f, -0.74314f, -0.71934f, -0.69466f, -0.66913f, -0.64279f,
		-0.61566f, -0.58779f, -0.55919f, -0.52992f, -0.50000f, -0.46947f,
		-0.43837f, -0.40674f, -0.37461f, -0.34202f, -0.30902f, -0.27564f,
		-0.24192f, -0.20791f, -0.17365f, -0.13917f, -0.10453f, -0.06976f,
		-0.03490f, -0.00000f, 0.03490f, 0.06976f, 0.10453f, 0.13917f, 0.17365f,
		0.20791f, 0.24192f, 0.27564f, 0.30902f, 0.34202f, 0.37461f, 0.40674f,
		0.43837f, 0.46947f, 0.50000f, 0.52992f, 0.55919f, 0.58779f, 0.61566f,
		0.64279f, 0.66913f, 0.69466f, 0.71934f, 0.74314f, 0.76604f, 0.78801f,
		0.80902f, 0.82904f, 0.84805f, 0.86603f, 0.88295f, 0.89879f, 0.91355f,
		0.92718f, 0.93969f, 0.95106f, 0.96126f, 0.97030f, 0.97815f, 0.98481f,
		0.99027f, 0.99452f, 0.99756f, 0.99939f, 1.00000f, 0.99939f, 0.99756f,
		0.99452f, 0.99027f, 0.98481f, 0.97815f, 0.97030f, 0.96126f, 0.95106f,
		0.93969f, 0.92718f, 0.91355f, 0.89879f, 0.88295f, 0.86603f, 0.84805f,
		0.82904f, 0.80902f, 0.78801f, 0.76604f, 0.74314f, 0.71934f, 0.69466f,
		0.66913f, 0.64279f, 0.61566f, 0.58779f, 0.55919f, 0.52992f, 0.50000f,
		0.46947f, 0.43837f, 0.40674f, 0.37461f, 0.34202f, 0.30902f, 0.27564f,
		0.24192f, 0.20791f, 0.17365f, 0.13917f, 0.10453f, 0.06976f, 0.03490f,
		0.00000f, -0.03490f, -0.06976f, -0.10453f, -0.13917f, -0.17365f,
		-0.20791f, -0.24192f, -0.27564f, -0.30902f, -0.34202f, -0.37461f,
		-0.40674f, -0.43837f, -0.46947f, -0.50000f, -0.52992f, -0.55919f,
		-0.58779f, -0.61566f, -0.64279f, -0.66913f, -0.69466f, -0.71934f,
		-0.74314f, -0.76604f, -0.78801f, -0.80902f, -0.82904f, -0.84805f,
		-0.86603f, -0.88295f, -0.89879f, -0.91355f, -0.92718f, -0.93969f,
		-0.95106f, -0.96126f, -0.97030f, -0.97815f, -0.98481f, -0.99027f,
		-0.99452f, -0.99756f, -0.99939f, -1.00000f, -0.99939f, -0.99756f,
		-0.99452f, -0.99027f, -0.98481f, -0.97815f, -0.97030f, -0.96126f,
		-0.95106f, -0.93969f, -0.92718f, -0.91355f, -0.89879f, -0.88295f,
		-0.86603f, -0.84805f, -0.82904f, -0.80902f, -0.78801f, -0.76604f,
		-0.74314f, -0.71934f, -0.69466f, -0.66913f, -0.64279f, -0.61566f,
		-0.58779f, -0.55919f, -0.52992f, -0.50000f, -0.46947f, -0.43837f,
		-0.40674f, -0.37461f, -0.34202f, -0.30902f, -0.27564f, -0.24192f,
		-0.20791f, -0.17365f, -0.13917f, -0.10453f, -0.06976f, -0.00000f };

const float cos_table[361] = { 1.00000f, 0.99939f, 0.99756f, 0.99452f, 0.99027f,
		0.98481f, 0.97815f, 0.97030f, 0.96126f, 0.95106f, 0.93969f, 0.92718f,
		0.91355f, 0.89879f, 0.88295f, 0.86603f, 0.84805f, 0.82904f, 0.80902f,
		0.78801f, 0.76604f, 0.74314f, 0.71934f, 0.69466f, 0.66913f, 0.64279f,
		0.61566f, 0.58779f, 0.55919f, 0.52992f, 0.50000f, 0.46947f, 0.43837f,
		0.40674f, 0.37461f, 0.34202f, 0.30902f, 0.27564f, 0.24192f, 0.20791f,
		0.17365f, 0.13917f, 0.10453f, 0.06976f, 0.03490f, 0.00000f, -0.03490f,
		-0.06976f, -0.10453f, -0.13917f, -0.17365f, -0.20791f, -0.24192f,
		-0.27564f, -0.30902f, -0.34202f, -0.37461f, -0.40674f, -0.43837f,
		-0.46947f, -0.50000f, -0.52992f, -0.55919f, -0.58779f, -0.61566f,
		-0.64279f, -0.66913f, -0.69466f, -0.71934f, -0.74314f, -0.76604f,
		-0.78801f, -0.80902f, -0.82904f, -0.84805f, -0.86603f, -0.88295f,
		-0.89879f, -0.91355f, -0.92718f, -0.93969f, -0.95106f, -0.96126f,
		-0.97030f, -0.97815f, -0.98481f, -0.99027f, -0.99452f, -0.99756f,
		-0.99939f, -1.00000f, -0.99939f, -0.99756f, -0.99452f, -0.99027f,
		-0.98481f, -0.97815f, -0.97030f, -0.96126f, -0.95106f, -0.93969f,
		-0.92718f, -0.91355f, -0.89879f, -0.88295f, -0.86603f, -0.84805f,
		-0.82904f, -0.80902f, -0.78801f, -0.76604f, -0.74314f, -0.71934f,
		-0.69466f, -0.66913f, -0.64279f, -0.61566f, -0.58779f, -0.55919f,
		-0.52992f, -0.50000f, -0.46947f, -0.43837f, -0.40674f, -0.37461f,
		-0.34202f, -0.30902f, -0.27564f, -0.24192f, -0.20791f, -0.17365f,
		-0.13917f, -0.10453f, -0.06976f, -0.03490f, -0.00000f, 0.03490f,
		0.06976f, 0.10453f, 0.13917f, 0.17365f, 0.20791f, 0.24192f, 0.27564f,
		0.30902f, 0.34202f, 0.37461f, 0.40674f, 0.43837f, 0.46947f, 0.50000f,
		0.52992f, 0.55919f, 0.58779f, 0.61566f, 0.64279f, 0.66913f, 0.69466f,
		0.71934f, 0.74314f, 0.76604f, 0.78801f, 0.80902f, 0.82904f, 0.84805f,
		0.86603f, 0.88295f, 0.89879f, 0.91355f, 0.92718f, 0.93969f, 0.95106f,
		0.96126f, 0.97030f, 0.97815f, 0.98481f, 0.99027f, 0.99452f, 0.99756f,
		0.99939f, 1.00000f, 0.99939f, 0.99756f, 0.99452f, 0.99027f, 0.98481f,
		0.97815f, 0.97030f, 0.96126f, 0.95106f, 0.93969f, 0.92718f, 0.91355f,
		0.89879f, 0.88295f, 0.86603f, 0.84805f, 0.82904f, 0.80902f, 0.78801f,
		0.76604f, 0.74314f, 0.71934f, 0.69466f, 0.66913f, 0.64279f, 0.61566f,
		0.58779f, 0.55919f, 0.52992f, 0.50000f, 0.46947f, 0.43837f, 0.40674f,
		0.37461f, 0.34202f, 0.30902f, 0.27564f, 0.24192f, 0.20791f, 0.17365f,
		0.13917f, 0.10453f, 0.06976f, 0.03490f, 0.00000f, -0.03490f, -0.06976f,
		-0.10453f, -0.13917f, -0.17365f, -0.20791f, -0.24192f, -0.27564f,
		-0.30902f, -0.34202f, -0.37461f, -0.40674f, -0.43837f, -0.46947f,
		-0.50000f, -0.52992f, -0.55919f, -0.58779f, -0.61566f, -0.64279f,
		-0.66913f, -0.69466f, -0.71934f, -0.74314f, -0.76604f, -0.78801f,
		-0.80902f, -0.82904f, -0.84805f, -0.86603f, -0.88295f, -0.89879f,
		-0.91355f, -0.92718f, -0.93969f, -0.95106f, -0.96126f, -0.97030f,
		-0.97815f, -0.98481f, -0.99027f, -0.99452f, -0.99756f, -0.99939f,
		-1.00000f, -0.99939f, -0.99756f, -0.99452f, -0.99027f, -0.98481f,
		-0.97815f, -0.97030f, -0.96126f, -0.95106f, -0.93969f, -0.92718f,
		-0.91355f, -0.89879f, -0.88295f, -0.86603f, -0.84805f, -0.82904f,
		-0.80902f, -0.78801f, -0.76604f, -0.74314f, -0.71934f, -0.69466f,
		-0.66913f, -0.64279f, -0.61566f, -0.58779f, -0.55919f, -0.52992f,
		-0.50000f, -0.46947f, -0.43837f, -0.40674f, -0.37461f, -0.34202f,
		-0.30902f, -0.27564f, -0.24192f, -0.20791f, -0.17365f, -0.13917f,
		-0.10453f, -0.06976f, -0.03490f, -0.00000f, 0.03490f, 0.06976f,
		0.10453f, 0.13917f, 0.17365f, 0.20791f, 0.24192f, 0.27564f, 0.30902f,
		0.34202f, 0.37461f, 0.40674f, 0.43837f, 0.46947f, 0.50000f, 0.52992f,
		0.55919f, 0.58779f, 0.61566f, 0.64279f, 0.66913f, 0.69466f, 0.71934f,
		0.74314f, 0.76604f, 0.78801f, 0.80902f, 0.82904f, 0.84805f, 0.86603f,
		0.88295f, 0.89879f, 0.91355f, 0.92718f, 0.93969f, 0.95106f, 0.96126f,
		0.97030f, 0.97815f, 0.98481f, 0.99027f, 0.99452f, 0.99756f, 0.99939f,
		1.00000f };

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_I2C1_Init(void);
static void MX_SPI2_Init(void);
static void MX_TIM2_Init(void);
void StartDefaultTask(void *argument);
void menu(void *argument);
void handleButtonPress(void *argument);
void handleEncoder(void *argument);

/* USER CODE BEGIN PFP */
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
 * @brief  The application entry point.
 * @retval int
 */
int main(void) {

	/* USER CODE BEGIN 1 */

	/* USER CODE END 1 */

	/* MCU Configuration--------------------------------------------------------*/

	/* Reset of all peripherals, Initializes the Flash interface and the Systick. */
	HAL_Init();

	/* USER CODE BEGIN Init */

	/* USER CODE END Init */

	/* Configure the system clock */
	SystemClock_Config();

	/* USER CODE BEGIN SysInit */

	/* USER CODE END SysInit */

	/* Initialize all configured peripherals */
	MX_GPIO_Init();
	MX_I2C1_Init();
	MX_FATFS_Init();
	MX_SPI2_Init();
	MX_TIM2_Init();
	/* USER CODE BEGIN 2 */

	// si falla la conexion i2c se hace una hard fault
	if (SSD1306_Init() == 0) {
#ifdef DEBUG_SCREEN
		ACTIVATE_DEBUG_PIN();
#endif
		Error_Handler();
	}

	// Comenzar timer para la PWM
	HAL_TIM_PWM_Start(&htim2, TIM_CHANNEL_1);

	/* USER CODE END 2 */

	/* Init scheduler */
	osKernelInitialize();

	/* USER CODE BEGIN RTOS_MUTEX */
	/* add mutexes, ... */
	/* USER CODE END RTOS_MUTEX */

	/* USER CODE BEGIN RTOS_SEMAPHORES */
	/* add semaphores, ... */
	/* USER CODE END RTOS_SEMAPHORES */

	/* USER CODE BEGIN RTOS_TIMERS */
	/* start timers, add new ones, ... */
	/* USER CODE END RTOS_TIMERS */

	/* USER CODE BEGIN RTOS_QUEUES */
	/* add queues, ... */
	/* USER CODE END RTOS_QUEUES */

	/* Create the thread(s) */
	/* creation of defaultTask */
	defaultTaskHandle = osThreadNew(StartDefaultTask, NULL,
			&defaultTask_attributes);

	/* creation of menuTask */
	menuTaskHandle = osThreadNew(menu, (void*) (&displayParams),
			&menuTask_attributes);

	/* creation of acceptButtonTas */
	acceptButtonTasHandle = osThreadNew(handleButtonPress,
			(void*) (&acceptButtonParams), &acceptButtonTas_attributes);

	/* creation of cancelButtonTas */
	cancelButtonTasHandle = osThreadNew(handleButtonPress,
			(void*) (&cancelButtonParams), &cancelButtonTas_attributes);

	/* creation of encoderTask */
	encoderTaskHandle = osThreadNew(handleEncoder, NULL,
			&encoderTask_attributes);

	/* USER CODE BEGIN RTOS_THREADS */
	/* add threads, ... */
	/* USER CODE END RTOS_THREADS */

	/* USER CODE BEGIN RTOS_EVENTS */
	/* add events, ... */
	/* USER CODE END RTOS_EVENTS */

	/* Start scheduler */
	osKernelStart();

	/* We should never get here as control is now taken by the scheduler */

	/* Infinite loop */
	/* USER CODE BEGIN WHILE */
	while (1) {
		/* USER CODE END WHILE */

		/* USER CODE BEGIN 3 */
	}
	/* USER CODE END 3 */
}

/**
 * @brief System Clock Configuration
 * @retval None
 */
void SystemClock_Config(void) {
	RCC_OscInitTypeDef RCC_OscInitStruct = { 0 };
	RCC_ClkInitTypeDef RCC_ClkInitStruct = { 0 };

	/** Initializes the RCC Oscillators according to the specified parameters
	 * in the RCC_OscInitTypeDef structure.
	 */
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
	RCC_OscInitStruct.HSEState = RCC_HSE_ON;
	RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
	RCC_OscInitStruct.HSIState = RCC_HSI_ON;
	RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
	RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL2;
	if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
		Error_Handler();
	}

	/** Initializes the CPU, AHB and APB buses clocks
	 */
	RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK
			| RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
	RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV2;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

	if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK) {
		Error_Handler();
	}
}

/**
 * @brief I2C1 Initialization Function
 * @param None
 * @retval None
 */
static void MX_I2C1_Init(void) {

	/* USER CODE BEGIN I2C1_Init 0 */

	/* USER CODE END I2C1_Init 0 */

	/* USER CODE BEGIN I2C1_Init 1 */

	/* USER CODE END I2C1_Init 1 */
	hi2c1.Instance = I2C1;
	hi2c1.Init.ClockSpeed = 400000;
	hi2c1.Init.DutyCycle = I2C_DUTYCYCLE_2;
	hi2c1.Init.OwnAddress1 = 0;
	hi2c1.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
	hi2c1.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
	hi2c1.Init.OwnAddress2 = 0;
	hi2c1.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
	hi2c1.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
	if (HAL_I2C_Init(&hi2c1) != HAL_OK) {
		Error_Handler();
	}
	/* USER CODE BEGIN I2C1_Init 2 */

	/* USER CODE END I2C1_Init 2 */

}

/**
 * @brief SPI2 Initialization Function
 * @param None
 * @retval None
 */
static void MX_SPI2_Init(void) {

	/* USER CODE BEGIN SPI2_Init 0 */

	/* USER CODE END SPI2_Init 0 */

	/* USER CODE BEGIN SPI2_Init 1 */

	/* USER CODE END SPI2_Init 1 */
	/* SPI2 parameter configuration*/
	hspi2.Instance = SPI2;
	hspi2.Init.Mode = SPI_MODE_MASTER;
	hspi2.Init.Direction = SPI_DIRECTION_2LINES;
	hspi2.Init.DataSize = SPI_DATASIZE_8BIT;
	hspi2.Init.CLKPolarity = SPI_POLARITY_LOW;
	hspi2.Init.CLKPhase = SPI_PHASE_1EDGE;
	hspi2.Init.NSS = SPI_NSS_SOFT;
	hspi2.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_2;
	hspi2.Init.FirstBit = SPI_FIRSTBIT_MSB;
	hspi2.Init.TIMode = SPI_TIMODE_DISABLE;
	hspi2.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
	hspi2.Init.CRCPolynomial = 10;
	if (HAL_SPI_Init(&hspi2) != HAL_OK) {
		Error_Handler();
	}
	/* USER CODE BEGIN SPI2_Init 2 */

	/* USER CODE END SPI2_Init 2 */

}

/**
 * @brief TIM2 Initialization Function
 * @param None
 * @retval None
 */
static void MX_TIM2_Init(void) {

	/* USER CODE BEGIN TIM2_Init 0 */

	/* USER CODE END TIM2_Init 0 */

	TIM_ClockConfigTypeDef sClockSourceConfig = { 0 };
	TIM_MasterConfigTypeDef sMasterConfig = { 0 };
	TIM_OC_InitTypeDef sConfigOC = { 0 };

	/* USER CODE BEGIN TIM2_Init 1 */

	/* USER CODE END TIM2_Init 1 */
	htim2.Instance = TIM2;
	htim2.Init.Prescaler = 1 - 1;
	htim2.Init.CounterMode = TIM_COUNTERMODE_UP;
	htim2.Init.Period = 1000 - 1;
	htim2.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
	htim2.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
	if (HAL_TIM_Base_Init(&htim2) != HAL_OK) {
		Error_Handler();
	}
	sClockSourceConfig.ClockSource = TIM_CLOCKSOURCE_INTERNAL;
	if (HAL_TIM_ConfigClockSource(&htim2, &sClockSourceConfig) != HAL_OK) {
		Error_Handler();
	}
	if (HAL_TIM_PWM_Init(&htim2) != HAL_OK) {
		Error_Handler();
	}
	sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
	sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
	if (HAL_TIMEx_MasterConfigSynchronization(&htim2, &sMasterConfig)
			!= HAL_OK) {
		Error_Handler();
	}
	sConfigOC.OCMode = TIM_OCMODE_PWM1;
	sConfigOC.Pulse = 500;
	sConfigOC.OCPolarity = TIM_OCPOLARITY_HIGH;
	sConfigOC.OCFastMode = TIM_OCFAST_DISABLE;
	if (HAL_TIM_PWM_ConfigChannel(&htim2, &sConfigOC, TIM_CHANNEL_1)
			!= HAL_OK) {
		Error_Handler();
	}
	/* USER CODE BEGIN TIM2_Init 2 */

	/* USER CODE END TIM2_Init 2 */
	HAL_TIM_MspPostInit(&htim2);

}

/**
 * @brief GPIO Initialization Function
 * @param None
 * @retval None
 */
static void MX_GPIO_Init(void) {
	GPIO_InitTypeDef GPIO_InitStruct = { 0 };
	/* USER CODE BEGIN MX_GPIO_Init_1 */

	/* USER CODE END MX_GPIO_Init_1 */

	/* GPIO Ports Clock Enable */
	__HAL_RCC_GPIOC_CLK_ENABLE();
	__HAL_RCC_GPIOD_CLK_ENABLE();
	__HAL_RCC_GPIOA_CLK_ENABLE();
	__HAL_RCC_GPIOB_CLK_ENABLE();

	/*Configure GPIO pin Output Level */
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);

	/*Configure GPIO pin Output Level */
	HAL_GPIO_WritePin(GPIOB, SD_CS_Pin | GPIO_PIN_10, GPIO_PIN_RESET);

	/*Configure GPIO pin : PC13 */
	GPIO_InitStruct.Pin = GPIO_PIN_13;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

	/*Configure GPIO pins : ENCODER_A_Pin ENCODER_B_Pin */
	GPIO_InitStruct.Pin = ENCODER_A_Pin | ENCODER_B_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

	/*Configure GPIO pins : BTN_BACK_Pin BTN_ENTER_Pin */
	GPIO_InitStruct.Pin = BTN_BACK_Pin | BTN_ENTER_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

	/*Configure GPIO pins : SD_CS_Pin PB10 */
	GPIO_InitStruct.Pin = SD_CS_Pin | GPIO_PIN_10;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

	/* USER CODE BEGIN MX_GPIO_Init_2 */

	/* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

// Esta es una aproximacion de la sqrt de 'math.h' para evitar su importación
// hay otras aproximaciones también
float fast_sqrt(float number) {
	if (number == 0.0f)
		return 0.0f;
	float x2 = number * 0.5f;
	float y = number;
	long i = *(long*) &y;
	i = 0x5f3759df - (i >> 1);
	y = *(float*) &i;
	y = y * (1.5f - (x2 * y * y));
	return number * y;
}

/* USER CODE END 4 */

/* USER CODE BEGIN Header_StartDefaultTask */
/**
 * @brief  Function implementing the defaultTask thread.
 * @param  argument: Not used
 * @retval None
 */
uint8_t temp = 1;
/* USER CODE END Header_StartDefaultTask */
void StartDefaultTask(void *argument) {
	/* USER CODE BEGIN 5 */

	FATFS FatFs;
	FIL fil;
	FRESULT fres;
	UINT bytesRead;
	BYTE mp3Buf[1024]; // Buffer size (can be larger like 1024 or 2048 for faster reads)

	// Montar el disco inmediatamente
	fres = f_mount(&FatFs, "", FA_READ);
	if (fres != FR_OK) {
#ifdef DEBUG_SD
		ACTIVATE_DEBUG_PIN();
#endif
		Error_Handler();
	}

	// Se lee el archivo de prueba
	fres = f_open(&fil, "test.mp3", FA_READ);
	if (fres != FR_OK) {
#ifdef DEBUG_SD
		ACTIVATE_DEBUG_PIN();
#endif
		Error_Handler();  // File not found, path invalid, etc.
	}

	/* Infinite loop */
	for (;;) {
		if (displayParams.menu != START
				&& HAL_GetTick() - lastInteractionTick > 6000) {
			displayParams.menu = START;
			lastInteractionTick = HAL_GetTick();
		}

		if ()
		// Ahora se lee la información del archivo de prueba
		fres = f_read(&fil, mp3Buf, sizeof(mp3Buf), &bytesRead);
		if (fres != FR_OK) {
#ifdef DEBUG_SD
			ACTIVATE_DEBUG_PIN();
#endif
			Error_Handler();
		}

		// Error si el archivo no se encontró básicamente
		if (bytesRead == 0) {
			f_lseek(&fil, 0);
			continue;
		}

		// Hacer el audio con PWM
		for (int i = 0; i < 1024 && i < bytesRead; i++) {
			TIM2->CCMR1 = ((mp3Buf[i] + 32768) * 1000) / 65536; // escalar de 0-999
			osDelay(1); // debería ir un delay acá?
		}

		// Se desmonta
		f_close(&fil);

		osDelay(1000);
	}
	/* USER CODE END 5 */
}

/* USER CODE BEGIN Header_menu */
/**
 * @brief Function implementing the menuTask thread.
 * @param argument: Not used
 * @retval None
 */
/* USER CODE END Header_menu */
void menu(void *argument) {
	/* USER CODE BEGIN menu */
	/* Infinite loop */

	DisplayMenu menu = START;
	DisplayMenu prevMenu = START;

	const uint16_t halfWidth = SCREEN_WIDTH / 2;
	const uint16_t halfHeight = SCREEN_HEIGHT / 2;

	uint32_t temp_angle;
	for (;;) {

		menu = ((DisplayParams*) argument)->menu;

		if (prevMenu != menu) {
			prevMenu = menu;
			SSD1306_Clear();
		}

		switch (menu) {
		case START:

			SSD1306_DrawFilledCircle(halfWidth, halfHeight,
			SCREEN_HEIGHT / 3 + 7, SSD1306_COLOR_BLACK);

			temp_angle =
					prev_point_angle + 60 > 360 ?
							(prev_point_angle + 60) - 360 :
							prev_point_angle + 60;
			SSD1306_DrawFilledCircle(
					halfWidth + SCREEN_HEIGHT / 3 * cos_table[temp_angle],
					halfHeight + SCREEN_HEIGHT / 3 * sin_table[temp_angle], 6,
					SSD1306_COLOR_WHITE);

			temp_angle =
					prev_point_angle + 30 > 360 ?
							(prev_point_angle + 30) - 360 :
							prev_point_angle + 30;
			SSD1306_DrawFilledCircle(
					halfWidth + SCREEN_HEIGHT / 3 * cos_table[temp_angle],
					64 / 2 + 64 / 3 * sin_table[temp_angle], 4,
					SSD1306_COLOR_WHITE);
			SSD1306_DrawFilledCircle(
					halfWidth + SCREEN_HEIGHT / 3 * cos_table[point_angle],
					64 / 2 + 64 / 3 * sin_table[point_angle], 2,
					SSD1306_COLOR_WHITE);

			if (point_angle >= 360) {
				prev_point_angle = point_angle;
				point_angle = 0;
			} else {
				prev_point_angle = point_angle;
				point_angle += 8;
			}

			break;
		case MENU:
			SSD1306_GotoXY(TEXT_X_OFFSET, SCREEN_HEIGHT / 2);
			SSD1306_Puts("< Menu >", &Font_7x10, 1);
			break;
		case EQUALIZER:
			SSD1306_GotoXY(TEXT_X_OFFSET, SCREEN_HEIGHT / 2);
			SSD1306_Puts("< Equal >", &Font_7x10, 1);
			break;
		case EQUALIZER_HIGH:
			SSD1306_GotoXY(TEXT_X_OFFSET, SCREEN_HEIGHT / 2);
			SSD1306_Puts("< Altos >", &Font_7x10, 1);
			break;
		case EQUALIZER_MID:
			SSD1306_GotoXY(TEXT_X_OFFSET, SCREEN_HEIGHT / 2);
			SSD1306_Puts("< Medios >", &Font_7x10, 1);
			break;
		case EQUALIZER_LOW:
			SSD1306_GotoXY(TEXT_X_OFFSET, SCREEN_HEIGHT / 2);
			SSD1306_Puts("< Bajos >", &Font_7x10, 1);
			break;
		case FOLDER_SEARCH:
			SSD1306_GotoXY(TEXT_X_OFFSET, SCREEN_HEIGHT / 2);
			SSD1306_Puts("< Carpetas >", &Font_7x10, 1);
			break;
		case FILES_SEARCH:
			SSD1306_GotoXY(TEXT_X_OFFSET, SCREEN_HEIGHT / 2);
			SSD1306_Puts("< Archivos >", &Font_7x10, 1);
			break;

		default:
			break;
		}

		SSD1306_UpdateScreen();
		osDelay(50);
		// TODO: agregar toggle pin de debug
		// HAL_GPIO_TogglePin(GPIO, GPIO_Pin)
	}
	/* USER CODE END menu */
}

/* USER CODE BEGIN Header_handleButtonPress */
/**
 * @brief Function implementing the buttonTask thread.
 * @param argument: Not used
 * @retval None
 */
/* USER CODE END Header_handleButtonPress */
void handleButtonPress(void *argument) {
	/* USER CODE BEGIN handleButtonPress */
	/* Infinite loop */
	Bool isButtonPressed = FALSE;

	// Recupero los parámetros del botón
	ButtonParams btnParams = *((ButtonParams*) argument);

	for (;;) {

		if (btnParams.type == CANCEL) {
			HAL_GPIO_TogglePin(btnParams.port, btnParams.pin);
		}

		// Esta lógica evita tener muchos disparos de botón
		if (HAL_GPIO_ReadPin(btnParams.port, btnParams.pin) == GPIO_PIN_RESET
				&& isButtonPressed == FALSE) {
			isButtonPressed = TRUE;

			// lógica del boton aceptar
			if (btnParams.type == ACCEPT) {
				lastInteractionTick = HAL_GetTick();

				switch (displayParams.menu) {
				case START:
					displayParams.menu = MENU;
					break;
				default:
					break;
				}
			} else {
				lastInteractionTick = HAL_GetTick();

				switch (displayParams.menu) {
				case MENU:
				case EQUALIZER:
				case EQUALIZER_HIGH:
				case EQUALIZER_MID:
				case EQUALIZER_LOW:
				case FILES_SEARCH:
				case FOLDER_SEARCH:
					displayParams.menu = START;
					break;
				default:
					break;
				}
			}

			osDelay(50);
		} else if (HAL_GPIO_ReadPin(btnParams.port, btnParams.pin)
				== GPIO_PIN_SET && isButtonPressed == TRUE) {
			isButtonPressed = FALSE;
			osDelay(50);
		}
		osDelay(1);
	}
	/* USER CODE END handleButtonPress */
}

/* USER CODE BEGIN Header_handleEncoder */
/**
 * @brief Function implementing the encoderTask thread.
 * @param argument: Not used
 * @retval None
 */
/* USER CODE END Header_handleEncoder */
void handleEncoder(void *argument) {
	/* USER CODE BEGIN handleEncoder */

	static const int8_t encoderTable[4][4] = { { 0, +1, -1, 0 },
			{ -1, 0, 0, +1 }, { +1, 0, 0, -1 }, { 0, -1, +1, 0 } };

	uint8_t prev = 0;
	uint8_t curr;

	for (;;) {

		curr = ((HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_6) == GPIO_PIN_RESET) << 1)
				| (HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_7) == GPIO_PIN_RESET);

		if (curr != prev) {
			int8_t direction = encoderTable[prev][curr];
			prev = curr;

			if (direction
					!= 0&& HAL_GetTick() - lastInteractionTick > ENCODER_DEBOUCE_DELAY) {
				lastInteractionTick = HAL_GetTick();

				if (displayParams.menu == 0x1 && direction == -1) {
					displayParams.menu = DISPLAY_MENU_LENGTH - 1;
				} else if (displayParams.menu == FILES_SEARCH
						&& direction == 1) {
					displayParams.menu = 0x1;
				} else {
					displayParams.menu += direction;
				}
			}
		}
	}
	osDelay(1);
	/* USER CODE END handleEncoder */
}

/**
 * @brief  Period elapsed callback in non blocking mode
 * @note   This function is called  when TIM4 interrupt took place, inside
 * HAL_TIM_IRQHandler(). It makes a direct call to HAL_IncTick() to increment
 * a global variable "uwTick" used as application time base.
 * @param  htim : TIM handle
 * @retval None
 */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
	/* USER CODE BEGIN Callback 0 */

	/* USER CODE END Callback 0 */
	if (htim->Instance == TIM4) {
		HAL_IncTick();
	}
	/* USER CODE BEGIN Callback 1 */

	/* USER CODE END Callback 1 */
}

/**
 * @brief  This function is executed in case of error occurrence.
 * @retval None
 */
void Error_Handler(void) {
	/* USER CODE BEGIN Error_Handler_Debug */
	/* User can add his own implementation to report the HAL error return state */
	__disable_irq();
	while (1) {
		HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
		for (uint32_t i = 0; i < 5000; i++) {
			for (uint32_t j = 0; j < 100; j++) {
			}
		}
	}
	/* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
	/* User can add his own implementation to report the file name and line number,
	   ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
