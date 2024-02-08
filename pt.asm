;-------------------------------------------------------------------------------
;  Vázquez Coronil, Jaime
;  Grupo: L9
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;-------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"msp430ports.h"  ; Include device header file
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
			.global ptConfigura, ptEscribe, ptLee

			.global TabPuertos
			.global	TabBits


;-------------------------------------------------------------------------------
;	puerto_t ptConfigura (int puerto, int bit, int modo);
;
;	Crea un nuevo puerto y lo configura
;-------------------------------------------------------------------------------

ptConfigura
						push.w 	R10
						clr.w	R10

						mov.w	R12, R15				; Guardamos puerto en R15
						cmp.w	#0, R12
						jlo		ConfiguraER
						cmp.w	#11, R12				; Comprobamos que el puerto esta entre 0 y 10
						jge		ConfiguraER

						rla.w	R12						;La tabla de puertos son SHORTS
						mov.w	TabPuertos(R12), R11	; R11=Puerto
						and.w	#7, R13					;Tomamos los 3 lsb

						;Voy a preguntar por los modos
						;bis.b	TabBits(R13),PDIR(R11)

Modo01					mov.w	R14, R10				;Hacemos una copia del modo EN R10
						and.w	#3, R10					;Hacemos una mascara de los bits 0 y 1 en R10

						cmp.w	#0, R10					;Es PT_DIG?
						jeq		Modo23					;Saltamos sin hacer nada
						cmp.w	#1, R10					;Es FUNC1?
						jeq		FUNC1					;Si, saltamos
						cmp.w	#2, R10					;Es FUNC2?
						jeq		FUNC2

FUNC3					bis.b	TabBits(R13),PSELC(R11)	;Es FUNC3
						jmp		Modo23
FUNC1					bis.b	TabBits(R13),PSEL0(R11)
						bic.b	TabBits(R13),PSEL1(R11)
						jmp 	Modo23
FUNC2					bic.b	TabBits(R13),PSEL0(R11)
						bis.b	TabBits(R13),PSEL1(R11)
						jmp		Modo23


Modo23					mov.w	R14, R10				;Hacemos una copia del modo EN R10
						and.w	#12, R10				;Nos quedamos con los bits 2 y 3

						cmp.w	#0, R10					;Es entrada?
						jeq		Modo45					;No hacemos nada ya que por defecto esta en entrada
						cmp.w	#4, R10					;Es entrada con res de pullup?
						jeq		EntradaPULLUP
						cmp.w	#8, R10					;Es entrada con res de pulldown?
						jeq		EntradaPULLDOWN
						;cmp.w	#12, R10				;Si no es ninguna de las anteriores, es salida
						bis.b	TabBits(R13), PDIR(R11)
						jmp		Modo45

EntradaPULLUP			bic.b	TabBits(R13), PDIR(R11)
						bis.b	TabBits(R13), PREN(R11)	;Habilitamos resistencia...
						bis.b	TabBits(R13), POUT(R11)	; de pullup
						jmp		Modo45

EntradaPULLDOWN			bic.b	TabBits(R13), PDIR(R11)
						bis.b	TabBits(R13), PREN(R11)	;Habilitamos resistencia...
						bic.b	TabBits(R13), POUT(R11)	; de pulldown


Modo45					mov.w	R14, R10				;Hacemos una copia del modo EN R10
						bit.b	#BIT5, R10				;Es activo en baja o en alta?
						jz		ACTIVOALTA

ACTIVOBAJA				bit.b	#BIT4, R10				;Es activo baja, lo iniciamos en OFF o en ON?
						jz		SALIDA1					;BIT4=0, iniciamos en OFF
						jmp		SALIDA0
ACTIVOALTA				bit.b	#BIT4, R10
						jnz		SALIDA1
						;jmp		SALIDA0
SALIDA0					bic.b	TabBits(R13), POUT(R11)
						jmp		GuardarPT
SALIDA1					bis.b	TabBits(R13), POUT(R11)
						jmp		GuardarPT

GuardarPT												;Guardamos el numero de puerto en los bits del 3 al 6
						rla.w	R15
						rla.w	R15
						rla.w	R15
						and.w	#120, R15				;Nos quedamos solo con los bits del 3 al 6
						clr.w	R12
						bis.w	R15, R12				;Añadimos PUERTO
						bis.w	R13, R12				;Añadimos BIT
						bit.b	#BIT5, R14				;Pol=1 o =0?
						jz		ptConfiguraFIN			;=0... 	no hago nada
						bis.b	#BIT7, R12				;...=1, Ponemos bit de POL a 1
						jmp 	ptConfiguraFIN

ConfiguraER				mov.w	#0xFF, R12				;Ha habido error, devolvemos FF

ptConfiguraFIN			and.w	#0xFF, R12				;Devuelve justo un byte

						pop.w	R10
						ret


;-------------------------------------------------------------------------------
;	int ptLee (puerto_t pt);
;
;	Lee un puerto, devuelve un 0 si el puerto esta desactivado y un número distinto de 0 en caso contrario
;-------------------------------------------------------------------------------

ptLee
			mov.w	R12, R13
			mov.w	R12, R14
			and.w	#7, R13 		;Numero de bit en R13

			and.w	#120, R14
			rra.w 	R14
			rra.w 	R14
			rra.w 	R14				; R14=PUERTO

			cmp.w	#0, R14
			jlo		ptLeeFIN
			cmp.w	#11, R14
			jge		ptLeeFIN				;Comprobamos que el puerto esta entre 0 y 10
			rla.w	R14  					;LA TABLA DE PUERTOS ES DE SHORTS (2 BYTES)

			mov.w 	R12, R15;
			mov.w	TabPuertos(R14),R11
			and.w	#128, R15				;R15=POLARIDAD BIT7

			tst.w	R15						;Es activa en alta o en baja?
			jnz		LeeACTBAJA				;Es activa en baja, salto...
ACTALTA		bit.b	TabBits(R13),PIN(R11) 	;Es activa en alta, pregunto cuanto vale (0=OFF, 1=ON)
			jz		LeeOFF
			jmp		LeeON
LeeACTBAJA	bit.b	TabBits(R13),PIN(R11)	;Es activo en alta, pregunto cuanto vale (0=ON,  1=OFF)
			jnz		LeeOFF

LeeON		mov.w	#1, R12					;Es ON, devuelvo 1
			jmp		ptLeeFIN
LeeOFF		mov.w	#0, R12					;Es OFF, devuelvo 0
ptLeeFIN	ret

;-------------------------------------------------------------------------------
;	void ptEscribe (puerto_t pt, int valor);
;
;	Escribimos en un puerto, si vale 0 el puerto se desactiva, en caso contrario se activa.
;-------------------------------------------------------------------------------

ptEscribe
				mov.w	R13, R11				;R11 = valor de activado o desactivado el puerto
				mov.w	R12, R13				;Valor del puerto pt
				and.w	#7, R13					;R13 = BIT

				mov.w 	R12, R14
				and.w	#120, R14
				rra.w 	R14
				rra.w 	R14
				rra.w 	R14 					;R14=PUERTO
				cmp.w	#0, R14
				jlo		ptEscribeFIN
				cmp.w	#11, R14
				jge		ptEscribeFIN 			;Comprobamos que el valor del puerto es correcto

				rla.w	R14
				mov.w	TabPuertos(R14), R15	;La tabla es de shorts (2 bytes cada uno)
				bit.b	#BIT7, R12 				;¿Activa en ALTA o BAJA?
				jz		ActivaALTA

ActivaBAJA		tst.w	R11						;Es activo en baja, (0 activado, 1 desactivado)
				jz		Ponemos1				;Desactivado, escribimos 1
				jmp		Ponemos0				;Activado, escribimos 0

ActivaALTA		tst.w	R11						;Es activo en alta  (0 desactivado, 1 activado)
				jnz		Ponemos1				;Activado, escribimos 1
				;jmp	Ponemos 0				;Desactivado, escribimos 0

Ponemos0		bic.b	TabBits(R13), POUT(R15)
				jmp		ptEscribeFIN
Ponemos1		bis.b	TabBits(R13), POUT(R15)
				jmp 	ptEscribeFIN

ptEscribeFIN	ret
