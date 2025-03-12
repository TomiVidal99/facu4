#ifndef STATE_MACHINE_
#define STATE_MACHINE_

// DEFINICIONES
#define NUM_SAMPLES 100
#define TEMP_THRESHOLD 50
#define TRIGGER_COUNTER_THRESHOLD 20

// TIPOS
typedef enum {DISPARO, PRE_DISPARO, REPOSO} sm_state;

// VARIABLES GLOBALES
float samples[NUM_SAMPLES] = {0};

// FUNCIONES
void state_machine(float);
void trigger_alarm(void);
void stop_alarm(void);

#endif STATE_MACHINE_