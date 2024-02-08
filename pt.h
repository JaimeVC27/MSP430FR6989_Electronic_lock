//--------------------------------------------------------------------
//  Vázquez Coronil, Jaime
//  Grupo: L9
//--------------------------------------------------------------------
/*
 * pt.h
 *
 *  Created on: 11 nov. 2021
 *      Author: 34633
 */

#ifndef PT_H_
#define PT_H_

#define PT_ESDIG (0)
#define PT_FUNC1 (1)
#define PT_FUNC2 (2)
#define PT_FUNC3 (3)
#define PT_ENTRADA (0<<2)
#define PT_ENTRADA_PULLUP (1<<2)
#define PT_ENTRADA_PULLDOWN (2<<2)
#define PT_SALIDA (3<<2)
#define PT_OFF (0<<4)
#define PT_ON (1<<4)
#define PT_ACTIVOALTA (0<<5)
#define PT_ACTIVOBAJA (1<<5)

typedef unsigned char puerto_t;

puerto_t ptConfigura (int puerto, int bit, int modo);
int ptLee (puerto_t pt);
void ptEscribe (puerto_t pt, int valor);


#endif /* PT_H_ */
