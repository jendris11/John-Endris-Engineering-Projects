#include "stm32f4xx.h" // Device header
#include <stdio.h>		 // C standard library
#include "LCD.h"
#include <string.h>

//=============================================================================
// GLOBAL VARIABLES & CONSTANTS
//=============================================================================
#define TIMER4_CH1 6 // PortB Pin 6
#define LED_ORANGE 13
#define LED_GREEN 12
#define LED_RED 14
#define LED_BLUE 15

int motion_pinB=1;
unsigned int rain_flag=0;
unsigned int motion_flag=0;

// 600 = 90 degrees right
// 1600 = middle (0 degrees)
// 2800 = 90 degrees left
unsigned int DUTY_CYCLE = 1600;

void ADC_init(void);
void ADC_enable(void);
void ADC_disable(void);
void ADC_start(int channel);
void ADC_wait_for_conversion(void);
uint16_t ADC_getval(void);

// Array to store ADC values
uint16_t ADC_VALUES[2] = {0,0};
double ADC_DATA[2] = {0.0, 0.0}; 
double TEMP = 0.0;

//=============================================================================
// MAIN FUNCTION
//=============================================================================
int main(void)
{	
	// Enable clocks for GPIOD (output pin) and TIM4 (timer being used for PWM)
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIODEN;
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;
	RCC->APB1ENR |= RCC_APB1ENR_TIM4EN;
	
	//initialize LED
	GPIOD->MODER|=((1<<2*LED_ORANGE)|(1<<2*LED_GREEN)|(1<<2*LED_RED));
	
	//Light Sensor Output PD11
	GPIOD->MODER&=~(1u<<22);
	GPIOD->MODER|=(1u<<23);
	
	//LCD init
	LCD_port_init();
	LCD_init();

	
	//ADC init
	ADC_init();
	ADC_enable();
	
	
	// Set Port D Pin 15 to alternate function in the MODER by setting MODER15[1:0] to 10 
	GPIOD->MODER |=  GPIO_MODER_MODER15_1;
	GPIOD->MODER &=~ GPIO_MODER_MODER15_0;
	
	// Set Port D Pin 15 to alternate function in the AFRH register by setting the AFRH15[3:0] bits to 0010 (corresponding to AF2)
	GPIOD->AFR[1] &=~ GPIO_AFRH_AFSEL15_3;
	GPIOD->AFR[1] &=~ GPIO_AFRH_AFSEL15_2;
	GPIOD->AFR[1] |=  GPIO_AFRH_AFSEL15_1;
	GPIOD->AFR[1] &=~ GPIO_AFRH_AFSEL15_0;
	
	// Set the timer 4 channel 4 to output mode by writing CC4S[1:0] to 00 
	TIM4->CCMR2 &=~ TIM_CCMR2_CC4S_1;
	TIM4->CCMR2 &=~ TIM_CCMR2_CC4S_0;
	
	// Since the CC1 channel is configured as output, set channel 4 to active high polarity by setting the CC4P bit to 0
	TIM4->CCER &=~ TIM_CCER_CC4P;
	
	// Select PWM1 mode for timer 4 channel 4 by writing 110 to OC4M[2:0] bits in the CCMR2
	TIM4->CCMR2 |=  TIM_CCMR2_OC4M_2;
	TIM4->CCMR2 |=  TIM_CCMR2_OC4M_1;
	TIM4->CCMR2 &=~ TIM_CCMR2_OC4M_0;
	
	// Assign valuest to PSC and ARR such that PWM outputs a 50 Hz signal
	TIM4->PSC = 15;
	TIM4->ARR = 20000;
	
	// DUTY CYCLE starts at 0
	TIM4->CCR4 = DUTY_CYCLE;
	
	// Set the preload bit in the CCMR2 register
	TIM4->CCMR2 |= TIM_CCMR2_OC4PE;
	
	// Set the ARPE bit in the CCMR2 register
	TIM4->CR1 |= TIM_CR1_ARPE;
	
	// Select the counting mode to PWM edge-aligned mode
	TIM4->CR1 &=~ TIM_CR1_CMS_1;
	TIM4->CR1 &=~ TIM_CR1_CMS_0;
	
	// Set the direction
	TIM4->CR1 &=~ TIM_CR1_DIR;
	
	// Enable capture compare
	TIM4->CCER |= TIM_CCER_CC4E;
	
	// Enable the timer 4 clock
	TIM4->CR1 |= TIM_CR1_CEN;
	
	// Output type
	GPIOD->OTYPER &=~ GPIO_OTYPER_OT14;
	GPIOD->OTYPER &=~ GPIO_OTYPER_OT13;	
	
	int TRIGGER = 1;
	
	int wipe_count=0;

	while(1) {
		wipe_count=wipe_count+1;
		if (wipe_count==5){ //1 wipe_count is about 2 seconds
	int sweeps = 0;
			while(sweeps != 3) {
				delay(250);
				TIM4->CCR4 = 2600;
				delay(250);
				TIM4->CCR4 = 600;
				sweeps++;
			}
			
			wipe_count=0;
		}

		


		
		TRIGGER = 0;
		TIM4->CCR4 = 1600;
		
		//Motion Sensor
		

			if (((GPIOB->IDR)&(1<<1))!=0){
				GPIOD -> ODR |=(1<<LED_RED);
				motion_flag=1;
	}
	else{
						GPIOD -> ODR &=~(1u<<LED_RED);
			motion_flag=0;
		}
	
		//Rain Sensor
					if (((GPIOB->IDR)&(1<<0))!=0){
			GPIOD -> ODR &=~(1u<<LED_GREEN);
						rain_flag=0;
	}
	else{
				
					GPIOD -> ODR |=(1<<LED_GREEN);
			rain_flag=1;
		}
		//Display all data
	
	char message[25];
				place_lcd_cursor(1);
	
	sprintf(message, "Motion:%d Rain:%d",motion_flag,rain_flag);
	displayMsg(message);
		
		
		////ADC's
				ADC_start(1);
		ADC_wait_for_conversion();
		ADC_VALUES[0] = ADC_getval();
		ADC_DATA[0] = ADC_VALUES[0] * (3.0/1023.0);
		TEMP = ((ADC_DATA[0] - 0.500)/(0.010));
		
		ADC_start(2);
		ADC_wait_for_conversion();
		ADC_VALUES[1] = ADC_getval();
		ADC_DATA[1] = ADC_VALUES[1] * (3.0/1023.0);
			
			//Photoresistor ADC:PA2 |Output LED PD13
		if (ADC_DATA[1]<1.0){
			GPIOD->ODR|=(1u<<LED_ORANGE);
		}
		else{
			GPIOD->ODR&=~(1u<<LED_ORANGE);
		}
			
		//Temperature Sensor //PA1
	place_lcd_cursor(2);	
	sprintf(message, "Temp:%f",TEMP);
	displayMsg(message);
		
		//Delay
		delay(100);
	}
	

	
}


void ADC_init() {

	// Initialize the clock for GPIO port A, which both ADC channels are connected to, in the AHB1 register
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
	// Initialize the clock for ADC1 in the APB2 register
	RCC->APB2ENR |= RCC_APB2ENR_ADC1EN;
	
	// Set the prescaler for the
	// Set and cleared by software to select the frequency of the clock to the ADC. The clock is common for all the ADCs. 01: PCLK2 divided by 4
	ADC->CCR &=~ ADC_CCR_ADCPRE_1;
	ADC->CCR |=  ADC_CCR_ADCPRE_0;
	
	// Set resolution to 10 bit in CR1 register (default is 12 bit). Set RES[1:0] to 01. VIDEO USES 12 bit (00)
	ADC1->CR1 &=~ ADC_CR1_RES_1;
	ADC1->CR1 |=  ADC_CR1_RES_0;
	
	// Since two ADC channels are being used, scan mode needs to be enabled by setting the SCAN bit to 1 in ADC->CR1
	ADC1->CR1 |= ADC_CR1_SCAN;
	
	// Right data alignment (0 by default)
	ADC1->CR2 &=~ ADC_CR2_ALIGN;
	
	// We want the EOC (end of conversion) bit to be set at the end of each conversion, so set ADC->CR2 EOC bit to 1
	ADC1->CR2 |= ADC_CR2_EOCS;
	
	// Set continuous mode ADC in the CR2 register. Set the CONT bit to 1.
	ADC1->CR2 |= ADC_CR2_CONT;
	
	// Set Sampling time to 84 cycles in SMPR2 register (default is 000 3 cycles). Set SMP1[2:0] and SMP2[2:0] to 100.
	// We are using channel 1 and channel 2
	ADC1->SMPR2 |=  ADC_SMPR2_SMP1_2;
	ADC1->SMPR2 &=~ ADC_SMPR2_SMP1_1;
	ADC1->SMPR2 &=~ ADC_SMPR2_SMP1_0;
	
	ADC1->SMPR2 |=  ADC_SMPR2_SMP2_2;
	ADC1->SMPR2 &=~ ADC_SMPR2_SMP2_1;
	ADC1->SMPR2 &=~ ADC_SMPR2_SMP2_0;
	
	// Set the sequence length to 2 by setting the L[3:0] bit to 1 (because we're using two channels)
	ADC1->SQR1 |= ADC_SQR1_L_0;
	
	/*
	// Specify channel number 1 of the 1st conversion in SQR3 register. Set SQR3[3:0] to 0001
	ADC1->SQR3 &=~ ADC_SQR3_SQ1_3;
	ADC1->SQR3 &=~ ADC_SQR3_SQ1_2;
	ADC1->SQR3 &=~ ADC_SQR3_SQ1_1;
	ADC1->SQR3 |=  ADC_SQR3_SQ1_0;
	*/
	
	// Initialize Port A pins 1 and 2 as analog pins. Set MODER1[1:0] and MODER2[1:0] to 11
	GPIOA->MODER |= GPIO_MODER_MODE1_1;
	GPIOA->MODER |= GPIO_MODER_MODE1_0;
	
	GPIOA->MODER |= GPIO_MODER_MODE2_1;
	GPIOA->MODER |= GPIO_MODER_MODE2_0;	
}

void ADC_enable() {
	// Enable the ADC by setting the ADON bit in the ADC->CR2 register
	ADC1->CR2 |= ADC_CR2_ADON;
	// Wait a short time for the ADC to stabilize
	delay(100);	
}

void ADC_disable() {
	// The ADC can be disabled by clearing the ADON bit in the CR2 register
	ADC1->CR2 &=~ ADC_CR2_ADON;
}

void ADC_start(int channel) {
	/* Since our ADC is operating using polling, this function keeps one channel in the conversion sequence at a time. Whatever
   * channel is passed into the function will be kept in the conversion sequence */
 	
	// Clear the sequence register, then write the channel number to bit 0
	ADC1->SQR3 = 0;
	ADC1->SQR3 |= (channel << 0);
	
	// Clear the status register
	ADC1->SR = 0;
	
	// Start the conversion for the current channel by setting the SWSTART bit to 1
	ADC1->CR2 |= ADC_CR2_SWSTART;
	
}

void ADC_wait_for_conversion() {
	// Wait for the EOC flag to be set, which will happen when the current conversion is finished
	while(!(ADC1->SR & (1 << 1)));	
}

uint16_t ADC_getval() {
	// Read the data register
	return ADC1->DR;
}


//=============================================================================
// End of file
//=============================================================================