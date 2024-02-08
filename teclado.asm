;-------------------------------------------------------------------------------
;  Vázquez Coronil, Jaime
;  Grupo: L9
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;-------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
			.bss	ScanTeclas,1
			.bss	Tecla, 1

			.global	kbIni, kbScan, kbGetc


L0	.equ	BIT2				;Linea0, linea1....
L1	.equ	BIT7
L2	.equ	BIT4
L3	.equ	BIT5

C0	.equ	BIT0				;Columna0, columna1...
C1	.equ	BIT3
C2	.equ	BIT3
C3	.equ	BIT2

Rebote		.equ	32768/100 - 1;Rebote = 10ms

;----------------------------------------------------------------------------------
;			void kbIni (void);
;
;		Configuramos LINEAS como ENTRADAS con resistencia de PULLIP
;		Configuramos COLUMNAS como salida con valor 0
;----------------------------------------------------------------------------------
kbIni
			;COLUMNAS
			bic.b	#C0, &P2OUT
			bic.b	#C1+C3, &P9OUT
			bic.b	#C2, &P4OUT			;Configuramos las columnas con valor 0

			bis.b	#C0, &P2DIR
			bis.b	#C1+C3, &P9DIR
			bis.b	#C2, &P4DIR			;Configuramos las columnas en modo salida


			;LINEAS
			bic.b	#L0, &P3DIR			;LINEAS como ENTRADAS
			bic.b	#L1, &P4DIR
			bic.b	#L2+L3, &P2DIR

			bis.b	#L0, &P3REN
			bis.b	#L1, &P4REN
			bis.b	#L2+L3, &P2REN		;Activamos todas las RESISTENCIAS de las lineas...

			bis.b	#L0, &P3OUT
			bis.b	#L1, &P4OUT
			bis.b	#L2+L3, &P2OUT		;...con resistencias de PULLUP

			bis.b	#L0, &P3IES
			bis.b	#L1, &P4IES
			bis.b	#L2+L3, &P2IES		;Habilitamos lineas sensibles al FLANCO DE BAJADA

			bic.b	#L0, &P3IFG
			bic.b	#L1, &P4IFG
			bic.b	#L2+L3, &P2IFG		;Borramos FLAGS

			bis.b	#L0, &P3IE
			bis.b	#L1, &P4IE
			bis.b	#L2+L3, &P2IE		;Habilitamos INTERRUPCION

			ret

;-----------------------------------------------------------------------------------------------------------
;
;			char kbScan (void);
;
;			Devolvemos el código ASCII de la tecla pulsada
;			si no se pulsa ninguna tecla o si se pulsan varias a la vez devuelve 0
;
;-----------------------------------------------------------------------------------------------------------------
kbScan		;Tenemos que hacer el proceso de barrido
			bic.b	#C0, 	&P2DIR
			bic.b	#C1+C3, &P9DIR			;DESACTIVAMOS TODAS LAS COLUMNAS
			bic.b	#C2, 	&P4DIR

			clr.b	&ScanTeclas

			;--------------------------------------COLUMNA 0--------------------------------------------
			;Activamos C0 (COMO SALIDA CON VALOR 0)
			bic.b	#C0, &P2OUT
			bis.b	#C0, &P2DIR

			;Comprobaremos una a una cada línea
			bit.b	#L0, &P3IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC0L1					;...no se ha pulsado, saltamos.
			mov.w	#0, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC0L1		bit.b	#L1, &P4IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC0L2					;...no se ha pulsado, saltamos.
			mov.w	#4, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC0L2		bit.b	#L2, &P2IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC0L3					;...no se ha pulsado, saltamos.
			mov.w	#8, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC0L3		bit.b	#L3, &P2IN				;1-sin pulsar   0-pulsada
			jnz 	VerC1					;...no se ha pulsado, saltamos.
			mov.w	#12, R12					;A R12 el desplazamiento para TabTeclas
			inc.b	&ScanTeclas				;;Incrementamos el contador de teclas pulsadas



			;Hemos revisado toda la Columna0, ahora desactivamos C0 y activamos C1
VerC1
			bic.b	#C0, &P2DIR				;Desactivamos C0

			;--------------------------------------COLUMNA 1--------------------------------------------
			;Activamos C1 (COMO SALIDA CON VALOR 0)
			bic.b	#C1, &P9OUT
			bis.b	#C1, &P9DIR

			;Comprobaremos una a una cada línea
			bit.b	#L0, &P3IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC1L1					;...no se ha pulsado, saltamos.
			mov.w	#1, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC1L1		bit.b	#L1, &P4IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC1L2					;...no se ha pulsado, saltamos.
			mov.w	#5, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC1L2		bit.b	#L2, &P2IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC1L3					;...no se ha pulsado, saltamos.
			mov.w	#9, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC1L3		bit.b	#L3, &P2IN				;1-sin pulsar   0-pulsada
			jnz 	VerC2					;...no se ha pulsado, saltamos.
			mov.w	#13, R12					;A R12 el desplazamiento para TabTeclas
			inc.b	&ScanTeclas				;;Incrementamos el contador de teclas pulsadas



			;Hemos revisado toda la Columna1, ahora desactivamos C1 y activamos C2
VerC2
			bic.b	#C1, &P9DIR				;Desactivamos C1

			;--------------------------------------COLUMNA 2--------------------------------------------
			;Activamos C2 (COMO SALIDA CON VALOR 0)
			bic.b	#C2, &P4OUT
			bis.b	#C2, &P4DIR

			;Comprobaremos una a una cada línea
			bit.b	#L0, &P3IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC2L1					;...no se ha pulsado, saltamos.
			mov.w	#2, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC2L1		bit.b	#L1, &P4IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC2L2					;...no se ha pulsado, saltamos.
			mov.w	#6, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC2L2		bit.b	#L2, &P2IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC2L3					;...no se ha pulsado, saltamos.
			mov.w	#10, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC2L3		bit.b	#L3, &P2IN				;1-sin pulsar   0-pulsada
			jnz 	VerC3					;...no se ha pulsado, saltamos.
			mov.w	#14, R12					;A R12 el desplazamiento para TabTeclas
			inc.b	&ScanTeclas				;;Incrementamos el contador de teclas pulsadas


			;Hemos revisado toda la Columna2, ahora desactivamos C2 y activamos C3
VerC3
			bic.b	#C2, &P4DIR				;Desactivamos C2

			;--------------------------------------COLUMNA 3--------------------------------------------
			;Activamos C1 (COMO SALIDA CON VALOR 0)
			bic.b	#C3, &P9OUT
			bis.b	#C3, &P9DIR

			;Comprobaremos una a una cada línea
			bit.b	#L0, &P3IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC3L1					;...no se ha pulsado, saltamos.
			mov.w	#3, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas


VerC3L1		bit.b	#L1, &P4IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC3L2					;...no se ha pulsado, saltamos.
			mov.w	#7, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC3L2		bit.b	#L2, &P2IN				;Si vale 1 no esta pulsada, si vale 0 se ha pulsado
			jnz		VerC3L3					;...no se ha pulsado, saltamos.
			mov.w	#11, R12					;Posicion que ocupa la tecla en TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

VerC3L3		bit.b	#L3, &P2IN				;1-sin pulsar   0-pulsada
			jnz 	ScanComp				;...no se ha pulsado, saltamos.
			mov.w	#15, R12				;A R12 el desplazamiento para TabTeclas
			inc.b	&ScanTeclas				;Incrementamos el contador de teclas pulsadas

			;Ya hemos terminado el barrido, vamos a comprobar que solo se ha pulsado una tecla

ScanComp	cmp.w	#2, &ScanTeclas			;Se han pulsado 2 o más teclas?
			jhs		ScanError				;...Si, error
			cmp.w	#0, &ScanTeclas			;...no. Se han pulsado 0 teclas?
			jeq		ScanError				;Si, devolvemos 0

TodoBien	mov.b	TabTeclas(R12),R12		;Dejamos en R12 el valor en ASCII de la tecla pulsada
			jmp		ScanAcaba				;Dejamos las columnas activas antes de salir

ScanError	mov.w	#0, R12					;Error, devolvemos 0
			;jmp		ScanAcaba

ScanAcaba	;Volvemos a dejar todas las columnas activas
			bic.b	#C0, &P2OUT
			bic.b	#C1+C3, &P9OUT
			bic.b	#C2, &P4OUT			;Configuramos las columnas con valor 0

			bis.b	#C0, &P2DIR
			bis.b	#C1+C3, &P9DIR
			bis.b	#C2, &P4DIR			;Configuramos las columnas en modo salida

			ret

;----------------------------------------------------------------------------------------------
;
;			char kbGetc (void);
;
;			Devuelve la tecla almacenada en el buffer del teclado y lo vacia.
;----------------------------------------------------------------------------------------------
kbGetc
			mov.b	&Tecla, R12			;Pasamos a R12 la tecla almacenada en el buffer del teclado
			clr.b 	&Tecla				;Vaciamos el buffer

			ret

;--------------------------------------------------------------------------
;
;			kbISR
;
;		Subrutina de atención a la interrupción de la línea, sus tareas son:
;		-Borrar flags
;		-Deshabilitar interrupciones
;		-Programar el Timer2_A1 para que produzca una interrupcion a los 10ms
;----------------------------------------------------------------------------

kbISR
			bic.b	#L0, &P3IFG
			bic.b	#L1, &P4IFG
			bic.b	#L2+L3, &P2IFG		;Borramos FLAGS de las LINEAS

			bic.b	#L0, &P3IE
			bic.b	#L1, &P4IE
			bic.b	#L2+L3, &P2IE		;Deshabilitamos INTERRUPCIONES

			push.w	R12					;No podemos alterar ningun registro en una ISR

			mov.w	&TA2R, R12			;Capturamos el momento en el que se ha producido la IRQ

			add.w	#Rebote, R12		;Añadimos 10ms
			mov.w	R12, &TA2CCR1		;Movemos a CCR1

			pop.w	R12

			mov.w	#CCIE, &TA2CCTL1	;Habilitamos la interrupción del CCR1

			reti

			.intvec PORT2_VECTOR, kbISR
			.intvec PORT3_VECTOR, kbISR
			.intvec PORT4_VECTOR, kbISR
			.text

;--------------------------------------------------------------------------------------------------
;			kbRebote
;
;			Subrutina de atención a la interrupción secundaria del TimerA2 (CCR1), sus tareas son:
;			-Borrar flag y deshabilitar IRQ
;			-Hacer barrido y guardar la tecla pulsada en el buffer.
;			-Habilitar las IRQ de las lineas
;--------------------------------------------------------------------------------------------------

kbRebote
			bic.b	#L0, &P3IE
			bic.b	#L1, &P4IE
			bic.b	#L2+L3, &P2IE		;Deshabilitamos INTERRUPCIONES

			push.w	R12					;Guardamos registros que usamos

			call	#kbScan				;Hacemos un barrido del teclado

			mov.b	R12, &Tecla			;Guardamos la tecla pulsada en el buffer

			clr.w	&TA2CCTL1			;Deshabilitamos interrupción del CCR1 y borramos flag.

			pop.w	R12

			bic.b	#L0, &P3IFG
			bic.b	#L1, &P4IFG
			bic.b	#L2+L3, &P2IFG		;Borramos FLAGS de las LINEAS

			bis.b	#L0, &P3IE
			bis.b	#L1, &P4IE
			bis.b	#L2+L3, &P2IE		;Habilitamos INTERRUPCIONES

			reti

			.intvec	TIMER2_A1_VECTOR, kbRebote
			.text


TabTeclas	.byte	'1'
			.byte	'2'
			.byte	'3'
			.byte	'C'
			.byte	'4'
			.byte	'5'
			.byte	'6'
			.byte	'D'
			.byte	'7'
			.byte	'8'
			.byte	'9'
			.byte	'E'
			.byte	'A'
			.byte	'0'
			.byte	'B'
			.byte	'F'
