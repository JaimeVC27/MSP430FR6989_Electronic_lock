//--------------------------------------------------------------------
//  Vázquez Coronil, Jaime
//  Grupo: L9
//--------------------------------------------------------------------
/*
 * cs.h
 *
 *  Created on: 5 dic. 2021
 *      Author: 34633
 */

#ifndef CS_H_
#define CS_H_

#define CS_DCO1_00   0 //(Velocidad 1’00 MHz)
#define CS_DCO2_67   1 //(Velocidad 2’67 MHz)
#define CS_DCO3_50   2 //(Velocidad 3’50 MHz)
#define CS_DCO4_00   3 //(Velocidad 4’00 MHz)
#define CS_DCO5_33   4 //(Velocidad 5’33 MHz)
#define CS_DCO7_00   5 //(Velocidad 7’00 MHz)
#define CS_DCO8_00   6 //(Velocidad 8’00 MHz)
#define CS_DCO16_00  7 //(Velocidad 16’00 MHz)
#define CS_DCO21_00  8 //(Velocidad 21’00 MHz).
#define CS_DCO24_00  9 //(Velocidad 24’00 MHz).

#define CS_MCLK     0       //RELOJES DISPONIBLES
#define CS_SMCLK    1
#define CS_ACLK     2

#define CS_LFXT     0       //FUENTES DISPONIBLES
#define CS_VLO      1
#define CS_LFMOD    2
#define CS_DCO      3
#define CS_MOD      4
#define CS_HFXT     5

#define CS_DIV1     0       //DIVISORES DISPONIBLES
#define CS_DIV2     1
#define CS_DIV4     2
#define CS_DIV8     3
#define CS_DIV16    4
#define CS_DIV32    5

typedef unsigned char uint8_t;

void csIniLFXT (void);
void csConfDCO (uint8_t mhz);
int csConfClk (uint8_t clk, uint8_t fuente, uint8_t divisor);

#endif /* CS_H_ */
