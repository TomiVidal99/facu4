#include <stdio.h>
#include <stdint.h>

#include "definitions.h"

static volatile sm_state current_state = REPOSO;
static volatile uint8_t trigger_counter = 0;

typedef void (*my_func_pointer)(void);

my_func_pointer callback1, callback2;

void main(void)
{
    uint16_t i;
    for (i = 0; i < NUM_SAMPLES; ++i)
    {
        state_machine(samples[i]);
    }
}

void state_machine(float sample)
{
    switch (current_state)
    {
    case REPOSO:
        if (trigger_counter >= TRIGGER_COUNTER_THRESHOLD)
        {
            current_state = PRE_DISPARO;
            trigger_counter = 0;
            break;
        }
        if (sample > TEMP_THRESHOLD)
        {
            trigger_counter++;
        }
        else
        {
            trigger_counter = 0;
        }
        break;

    case DISPARO:
        trigger_alarm();

        break;
    case PRE_DISPARO:
        printf("Reposo");
        break;

    default:
        break;
    }
}

void trigger_alarm(void)
{
}

void stop_alarm(void)
{
}