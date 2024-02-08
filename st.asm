;-------------------------------------------------------------------------------
;  Vázquez Coronil, Jaime
;  Grupo: L9
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;-------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
			.bss SystemTimer, 4
			.bss Periodo, 2

			.global stIni, stTime

;-------------------------------------------------------------------------
;				void stIni (unsigned int periodo);
;				Inicializa el SystemTimer
;--------------------------------------------------------------------------
stIni
			mov.w	R12, &Periodo
			mov.w	R12,&TA2CCR0			;Configuramos tiempo
			mov.w	#CCIE,&TA2CCTL0			;Habilitamos la interrupción del CCR0

			mov.w	#TASSEL__ACLK|MC__CONTINUOUS|TACLR,&TA2CTL
			nop
			eint							;Habilitamos IRQ
			nop
			ret

;-------------------------------------------------------------------------------------
;				unsigned long stTime (void);
;				Devuelve el valor actual del system timer
;-------------------------------------------------------------------------------------
stTime
			push.w sr
			nop
			dint							;Deshabilitamos IRQ
			nop

			mov.w	&SystemTimer, R12		;Movemos la parte baja

			mov.w	&SystemTimer+2, R13		;Movemos la parte alta

			pop.w sr
			nop
			eint							;Habilitamos IRQ
			nop
			ret

;-------------------------------------------------------------------------------
;				stA2ISR
;
;				Subrutina de servicio de interrupción, incrementa la variable SystemTimer
;				Actualiza también el valor del CCR0 para que la próxima IRQ se produzca en tiempo y forma
;-------------------------------------------------------------------------------
stA2ISR
			add.w	#1, &SystemTimer
			adc.w	&SystemTimer+2			;Incrementamos el SystemTimer

			add.w 	&Periodo, &TA2CCR0		;Actualizamos el valor del CCR0

			reti
			.intvec	TIMER2_A0_VECTOR, stA2ISR
