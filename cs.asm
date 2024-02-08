;-------------------------------------------------------------------------------
;  Vázquez Coronil, Jaime
;  Grupo: L9
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;-------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"pt.h"
            
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

			.global csIniLFXT
			.global	csConfDCO
			.global	TabDCO, csConfClk

;-------------------------------------------------------------------------------
;			void csIniLFXT (void);
;			Las tareas que realiza son;
;			-Configurar los pines E/S para que tengan la función de los pines del oscilador
;			-Habilitar el oscilador
;			-Esperar a que el oscilador se estabilice
;-------------------------------------------------------------------------------

csIniLFXT
			bis.b	#BIT4,&PJSEL0
			bic.b	#BIT4,&PJSEL1			;Asociamos pin al modulo primario

			mov.b	#0xA5,&CSCTL0_H			;Desbloqueamos los registros CSCTL

			bic.w	#LFXTOFF,&CSCTL4		;Habilitamos el oscilador LFXT (#BIT0=LFXTOFF)

Espera		bic.w	#LFXTOFFG,&CSCTL5		;Borrar flag de fallo del oscilador	LFXT
			bic.w	#OFIFG,&SFRIFG1			;Borrar flag de fallo en un oscilador LFXT/HFXT
			bit.w	#LFXTOFFG,&CSCTL5		;Esta estable?
			jnz		Espera					;No, esperar...

			bic.w	#ENSTFCNT1,&CSCTL5		;Detector de fallo de arranque del LFXT deshabilitado

			mov.b	#0,&CSCTL0_H			;Bloqueamos los registros CSCTL
			ret

;-------------------------------------------------------------------------------
;			void csConfDCO (uint8_t mhz);
;
;			Configura la velocidad del DCO
;-------------------------------------------------------------------------------

csConfDCO
			cmp.b	#0, R12
			jlo		ERROR
			cmp.b	#10, R12
			jge		ERROR

			mov.b	#0xA5,&CSCTL0_H			;Desbloqueamos los registros CSCTL
			rla.b	R12						;Multiplicamos por 2 porque TabDCO tiene elementos word (2bytes)

			call	TabDCO(R12)

Volver		mov.b	#0,&CSCTL0_H			;Bloqueamos los registros CSCTL
ERROR		ret

Modo0		jmp 	Volver

Modo1		bic.w	#BIT1,&CSCTL1			;0
			bic.w	#BIT2,&CSCTL1			;0
			bis.w	#BIT3,&CSCTL1			;1
			jmp 	Volver

Modo2		bic.w	#BIT1,&CSCTL1			;0
			bis.w	#BIT2,&CSCTL1			;1
			bic.w	#BIT3,&CSCTL1			;0
			jmp 	Volver

Modo3		bic.w	#BIT1,&CSCTL1			;0
			bis.w	#BIT2,&CSCTL1			;1
			bis.w	#BIT3,&CSCTL1			;1
			jmp 	Volver

Modo4		bis.w	#BIT1,&CSCTL1			;1
			bic.w	#BIT2,&CSCTL1			;0
			bic.w	#BIT3,&CSCTL1			;0
			jmp 	Volver

Modo5		bis.w	#BIT1,&CSCTL1			;1
			bic.w	#BIT2,&CSCTL1			;0
			bis.w	#BIT3,&CSCTL1			;1
			jmp 	Volver

Modo6		bis.w	#BIT1,&CSCTL1			;1
			bis.w	#BIT2,&CSCTL1			;1
			bic.w	#BIT3,&CSCTL1			;0
			jmp 	Volver

Modo7		bis.w	#DCORSEL, &CSCTL1
			jmp		Modo4

Modo8		bis.w	#DCORSEL, &CSCTL1
			jmp		Modo5

Modo9		bis.w	#DCORSEL, &CSCTL1
			jmp		Modo6
			nop

TabDCO	.word	Modo0
		.word	Modo1
		.word	Modo2
		.word	Modo3
		.word	Modo4
		.word	Modo5
		.word	Modo6
		.word	Modo7
		.word	Modo8
		.word	Modo9

;-------------------------------------------------------------------------------
;			int csConfClk (uint8_t clk, uint8_t fuente, uint8_t divisor);
;							R12				R13				R14
;
;			Configura el reloj clk con una fuente y un divisor determinados, son números sin signo de
;			8 bits que codifican las distintas posibilidades
;-------------------------------------------------------------------------------

csConfClk
			mov.b	#0xA5,&CSCTL0_H				;Desbloqueamos los registros CSCTL

			cmp.b	#0, R12						;Comprobamos CLK correcto
			jlo		Error
			cmp.b	#3, R12
			jge		Error

			cmp.b	#0, R13						;Comprobamos FUENTE correcta
			jlo		Error
			cmp.b	#6, R13
			jge		Error						;Si fuente no esta entre 0 y 5, error
			and.w	#7,R13 						;Hacemos mascara, solo nos interesan 3 bits

			cmp.b	#0, R14						;Conmprobamos DIVISOR correcto
			jlo		Error
			cmp.b	#6, R14
			jge		Error						;Si fuente no esta entre 0 y 5, error

			and.w	#7,R14 						;Hacemos mascara, solo nos interesan 3 bits

RELOJES		cmp.b	#0, R12
			jeq		csMCLK
			cmp.b	#1, R12
			jeq		csSMCLK

csACLK
			bis.b	#BIT0,&CSCTL6
			jmp		fuenteACLK
csMCLK
			bis.b	#BIT1,&CSCTL6
			jmp		fuenteMCLK
csSMCLK
			bis.b	#BIT0,&CSCTL6
			jmp		fuenteSMCLK


fuenteACLK
			swpb	R13						;Cambiamos el byte msb por el lsb
			mov.w	R13,&CSCTL2				;Movemos SELA
			jmp		DivisorA

fuenteMCLK
			mov.w	R13,&CSCTL2				;Movemos SELM
			jmp		DivisorM

fuenteSMCLK
			rla.w	R13
			rla.w	R13
			rla.w	R13
			rla.w	R13						;Pasamos los bits del 0 al 4 (Para el SMCLK son los Bits del 0 al 4 en CSCTL2)
			mov.w	R13,&CSCTL2				;Movemos SELS
			jmp		DivisorS

DivisorA
			swpb	R14
			mov.w	R14,&CSCTL3				;Movemos DIVA
			jmp		ConfFin

DivisorM
			mov.w	R14,&CSCTL3				;Movemos DIVM
			jmp		ConfFin

DivisorS
			rla.w	R14
			rla.w	R14
			rla.w	R14
			rla.w	R14						;Pasamos los bits del 0 al 4 (Para el SMCLK son los Bits del 0 al 4 en CSCTL2)
			mov.w	R14,&CSCTL3				;Movemos DIVS
			jmp		ConfFin

ConfFin		clr.w	R12				        ;Devolvemos un 0, todo ha ido bien
			mov.b	#0,&CSCTL0_H			;Bloqueamos los registros CSCTL
			ret

Error		mov.w	#-1, R12				;Ha habido un error
			mov.b	#0,&CSCTL0_H			;Bloqueamos los registros CSCTL
			ret
