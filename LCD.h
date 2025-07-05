/*******************************
 * FUNCTION PROTOTYPES
 *******************************
 */
// Delay Functions
void tim6_delay(void);
void delay(int ms);

// LCD related functions
void LCD_port_init(void);
void LCD_init(void);
void LCD_write(unsigned char data);
void place_lcd_cursor(unsigned char lineno);
// END Functions