## Comandos importantes
`sudo apt install gcc-arm-none-eabi` 
`sudo pacman -S arm-none-eabi-gcc arm-none-eabi-binutils`

### Dissasemble
`arm-none-eabi-objdump -d your_program.elf`
#### Intercalar assembly y C
`arm-none-eabi-objdump -d -S your_program.elf`

# Librería HAL
## Uso de periféricos 
PPP -> es el periférico
Siempre se sigue el siguiente esquema:
1. Definir handler `PPP_HandleTypeDef handler;`
2. Asignar dirección de memoria base de los registros del periférico `handler.Instance`
3. Asignar valores de inicialización `handler.Init`
4. Invocar función de inicialización `HAL_PPP_Init(&handler, ...)`
5. Usar el periférico con las funciones específicas según la aplicación
	`HAL_PPP_Action(&handler, ...)`
	`HAL_PPP_Action_IT(&handler, ...)`
	`HAL_PPP_Action_DMA(&handler, ...)` -> DMA hace que no se necesiten ciclos de reloj del procesador casi para transferir información a la memoria (por ejemplo un ADC externo)