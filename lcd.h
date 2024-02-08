//--------------------------------------------------------------------
//  Vázquez Coronil, Jaime
//  Grupo: L9
//--------------------------------------------------------------------
/*
 * lcd.h
 *
 *  Created on: 26 nov. 2021
 *      Author: 34633
 */

#ifndef LCD_H_
#define LCD_H_

void lcdIni (void);
unsigned int lcda2seg (char c);
void escribeLetra (int seg14, char pos);
unsigned short int Lee (char);
void lcdPintaIzq (char c);
void lcdPintaDer (char c);
void lcdBorraTodo (void);
void lcdBorra (void);
void lcdBat (unsigned char b);
void lcdHrt (char h);
void lcdAnt (char A);
void lcdDosPuntos (char p);
void lcdPintaIzq4 (char c);

//void lcdPintaIzq (char c);

#endif /* LCD_H_ */
