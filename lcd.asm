;-------------------------------------------------------------------------------
;  Vázquez Coronil, Jaime
;  Grupo: L9
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

			.global lcdIni
			.global lcda2seg
			.global escribeLetra
			.global Lee
			.global	lcdPintaDer, lcdPintaIzq, lcdBorraTodo, lcdBorra, lcdBat, lcdHrt, lcdDosPuntos, lcdAnt, lcdPintaIzq4


;-------------------------------------------------------------------------------
; void lcdIni (void)
;-------------------------------------------------------------------------------
lcdIni		;Conectar puertos del LCD con el exterior
			mov.w	#0xFFD0, &LCDCPCTL0
			mov.w	#0xFC3F, &LCDCPCTL1
			mov.w	#0x00F8, &LCDCPCTL2

			;Reloj=ACLK, Divisor=1, Predivisor=16, 4MUX, Low power
			mov.w	#LCDDIV_1 | LCDPRE__16 | LCD4MUX | LCDLP, &LCDCCTL0;

 			;VLCD=2'6 interno, V2-V5 interno, V5=0, charge pump con referencia interna
 			mov.w	#VLCD_1 | VLCDREF_0 | LCDCPEN, &LCDCVCTL
 			;Habilitar sincronizacion de reloj
 			mov.w	#LCDCPCLKSYNC, &LCDCCPCTL
 			mov.w	#LCDCLRM, &LCDCMEMCTL	;Borrar memoria del LCD

			bis.w	#LCDON, &LCDCCTL0		;Encender LCD_C
			ret

;-------------------------------------------------------------------------------
;		unsigned int lcda2seg (char c);
;		Recibe un caracter ASCII imprimible y devuelve su representación a 14 segmentos
;		Devuelve 0xFFFF, si está fuera de rango
;-------------------------------------------------------------------------------
lcda2seg	;Pasar de ASCII A 14segmentos
			cmp.w	#32, R12			;Esta entre 32 y 127?
			jl 		SalidaErr
			cmp.w	#128, R12
			jge		SalidaErr
										;...no, sigo
			sub.b	#32, R12
			rla.w	R12					;Multiplico R12 porque tengo que utilizar Tab14Seg
			mov.w	Tab14Seg(R12), R12	;Dejo el resultado en R12 y salgo
			ret
SalidaErr	mov.w	#0xFFFF, R12		;Error, devuelvo FFFF
			ret
;----------------------------------------------------------------------------------
; 		void escribeLetra (int seg14, char pos);
;		Escribe una letra en una posición determinada del lcd, recibe un caracter en 14segmentos y la posición del
;		lcd en la que quiere ser escrita.
;----------------------------------------------------------------------------------

escribeLetra	;Vamos a escribir un digito
			dec.b	R13
			rla.b	R13					;SHORT = 2 BYTES
			mov.w	TabDig(R13), R13
			mov.b	R12, 0(R13)			;Escribo el byte menos significativo
			swpb	R12					;Cambio los dos bytes para poder manejar el msb
			and.b	#5, 1(R13)			;Donde hay un cero se borra
			add.b	R12, 1(R13)
			ret
;-----------------------------------------------------------------------------
;		unsigned short int Lee (char);
;		Lee un dígito del lcd y devuelve su representación en 14segmentos
;-----------------------------------------------------------------------------

Lee				;Vamos a leer el caracter anterior
			mov.b	R12, R13
			clr.w   R12
			clr.w	R14
			dec.b 	R13
			rla.w	R13
			mov.w	TabDig(R13),R13		;Utilizo TabDig, R13 apunta a la posición del dígito que quiero leer
			mov.b	1(R13), R12			;Leo la parte alta
			bic.w	#5, R12				;Me quito los dos bits que no me interesan
			swpb	R12					;Le doy la vuelta a R12 (los 8 msb pasan a ser los 8 lsb)
			mov.b	0(R13), R14			;Muevo la parte baja a R14
			bis.w   R14, R12			;Y la meto en R12
			ret
;-------------------------------------------------------------------------------
;			void lcdPintaIzq4 (char c);
;			Desplaza SOLO los 4 digitos de la derecha de la pantalla un carácter hacia la izquierda.
;			(SOLO desplaza los dígitos 3, 4, 5, 6)
;----------------------------------------------------------------------------
lcdPintaIzq4
			push.w	R10
			mov.b	#4, R11				;PRIMERO LEEMOS EL DIGITO4 ----(Leemos 4, escribimos 3, leemos5, escribimos 4...)
Bucle		mov.b	R11, R13			;R11 nos indica por qué dijito vamos
			mov.b	R13, R15			;Hacemos una copia
			clr.w	R14					;R14=0, porque es un registro auxiliar
			dec.b 	R13
			rla.w	R13					;TabDig es de shorts
			mov.w	TabDig(R13),R13		;En R13 estara el LCDMEM del digito correspondiente
			mov.b	1(R13),	R10			;Muevo el byte msb
			bic.w	#5, R10				;Enmascaro, y me quito los dos bits que no me interesan
			swpb 	R10					;Le doy la vuelta a R10
			mov.b	0(R13), R14			;Leo el byte bajo...
			bis.w	R14, R10			;... y lo meto en R10

			dec.w	R15
			dec.w	R15					;Decremento dos veces porque tengo que escrbir en el digito anterior(si leo en 2 escribo en 1)
			rla.b	R15
			mov.w	TabDig(R15), R15
			mov.b	R10, 0(R15)			;Escribo el byte menos significativo
			swpb	R10					;Cambio los dos bytes para poder manejar el msb
			bic.b	#5, R10				;Nos quitamos los dos bits que no nos interesan
			and.b	#5, 1(R15)			;Hacemos and para no variar los dos bits que no nos interesan
			bis.b	R10, 1(R15)			;Pasamos el byte mas significativo
			inc.b	R11

			cmp.b	#7, R11				;He terminado de desplazarlos todos?
			jlo		Bucle				;No, sigo
										;si... escribo el caracter mandado en c
			call	#lcda2seg
			mov.b	#6, R15					;Escribo en el digito 6
			dec.b	R15
			rla.b	R15
			mov.w	TabDig(R15), R15
			mov.b	R12, 0(R15)			;Escribo el byte menos significativo
			swpb	R12					;Cambio los dos bytes para poder manejar el msb
			mov.b	R12, 1(R15)
			bic.b	#5, 1(R15)			;Donde hay un cero se borra

			pop.w	R10
			ret

;-------------------------------------------------------------------------------
;			void lcdPintaIzq (char c);
;			Desplaza el contenido de la pantalla un carácter a la izquierda
;----------------------------------------------------------------------------
lcdPintaIzq
			push.w	R10
			mov.b	#2, R11				;PRIMERO LEEMOS EL DIGITO2 ----(Leemos 2, escribimos 1, leemos3, escribimos 2...)
BucleTodo	mov.b	R11, R13			;R11 nos indica por qué dijito vamos
			mov.b	R13, R15			;Hacemos una copia
			clr.w	R14					;R14=0, porque es un registro auxiliara
			dec.b 	R13
			rla.w	R13					;TabDig es de shorts
			mov.w	TabDig(R13),R13		;En R13 estara el LCDMEM del digito correspondiente
			mov.b	1(R13),	R10			;Muevo el byte msb
			bic.w	#5, R10				;Enmascaro, y me quito los dos bits que no me interesan
			swpb 	R10					;Le doy la vuelta a R12
			mov.b	0(R13), R14			;Leo el byte bajo...
			bis.w	R14, R10			;... y lo meto en R12

			dec.w	R15
			dec.w	R15					;Decremento dos veces porque tengo que escrbir en el digito anterior(si leo en 2 escribo en 1)
			rla.b	R15
			mov.w	TabDig(R15), R15
			mov.b	R10, 0(R15)			;Escribo el byte menos significativo
			swpb	R10					;Cambio los dos bytes para poder manejar el msb
			bic.b	#5, R10				;Nos quitamos los dos bits que no nos interesan
			and.b	#5, 1(R15)			;Hacemos and para no variar los dos bits que no nos interesan
			bis.b	R10, 1(R15)			;Pasamos el byte mas significativo
			inc.b	R11

			cmp.b	#7, R11				;He terminado de desplazarlos todos?
			jlo		BucleTodo				;No, sigo
										;si... escribo el caracter mandado en c
			call	#lcda2seg
			mov.b	#6, R15					;Escribo en el digito 6
			dec.b	R15
			rla.b	R15
			mov.w	TabDig(R15), R15
			mov.b	R12, 0(R15)			;Escribo el byte menos significativo
			swpb	R12					;Cambio los dos bytes para poder manejar el msb
			mov.b	R12, 1(R15)
			bic.b	#5, 1(R15)			;Donde hay un cero se borra

			pop.w	R10
			ret
;-------------------------------------------------------------------------------
;			void lcdPintaDer (char c);
;			Desplaza el contenido de la pantalla un carácter a la derecha
;----------------------------------------------------------------------------
lcdPintaDer
			push.w	R10
			mov.b	#5, R11				;PRIMERO LEEMOS EL DIGITO5
Sigue		mov.b	R11, R13
			mov.b	R13, R15			;Hacemos una copia
			clr.w	R14
			dec.b 	R13
			rla.w	R13					;TabDig es de shorts
			mov.w	TabDig(R13),R13		;En R13 estara el LCDMEM del digito correspondiente
			mov.b	1(R13),	R10			;Muevo el byte msb
			bic.w	#5, R10				;Enmascaro, y me quito los dos bits que no me interesan
			swpb 	R10					;Le doy la vuelta a R10
			mov.b	0(R13), R14			;Leo el byte bajo...
			bis.w	R14, R10			;... y lo meto en R10

			rla.b	R15
			mov.w	TabDig(R15), R15
			mov.b	R10, 0(R15)			;Escribo el byte menos significativo
			swpb	R10					;Cambio los dos bytes para poder manejar el msb
			mov.b	R10, 1(R15)
			bic.b	#5, 1(R15)			;Donde hay un cero se borra
			dec.b	R11

			cmp.b	#1, R11
			jhs		Sigue

			call	#lcda2seg
			clr.w	R15					;Escribo en el primer digito
			mov.w	TabDig(R15), R15
			mov.b	R12, 0(R15)			;Escribo el byte menos significativo
			swpb	R12					;Cambio los dos bytes para poder manejar el msb
			mov.b	R12, 1(R15)
			bic.b	#5, 1(R15)			;Donde hay un cero se borra

			pop.w	R10
			ret

;-----------------------------------------------------------------------------
;			void lcdBorraTodo (void);
;			Borra el contenido de la pantalla
;---------------------------------------------------------------------------------------

lcdBorraTodo
			bis.w	#LCDCLRBM+LCDCLRM,&LCDCMEMCTL		;Borramos todos los registros de memoria de video y de parpadeo (LCD.pdf)
			ret

;-----------------------------------------------------------------------------
;			void lcdBorra (void);
;			Borra los dígitos de la pantalla
;---------------------------------------------------------------------------------------
lcdBorra
			mov.b	#1, R12
Borro		mov.b	R12, R13
			dec.b	R13
			rla.b	R13
			mov.w	TabDig(R13), R13
			mov.w	#0, 0(R13)
			inc.w	R12
			cmp.b	#7, R12
			jlo		Borro
			ret
;------------------------------------------------------------------------------------
;			void lcdBat (unisgned char b);
;			Establece el estado de las barras del indicador de nivel de batería.
;---------------------------------------------------------------------------------
lcdBat
			cmp.b	#0, R12
			jz		Bat0
			cmp.b	#1, R12
			jz		Bat1
			cmp.b	#2, R12
			jz 		Bat2
			cmp.b	#3, R12
			jz 		Bat3
			cmp.b	#4, R12
			jz 		Bat4
			cmp.b	#5, R12
			jz 		Bat5
			cmp.b	#6, R12
			jz 		Bat6
			jmp		Fin

Bat0		mov.b	#BIT4, &LCDM14
			mov.b	#BIT4, &LCDM18
			jmp		Fin
Bat1		mov.b	#BIT4, &LCDM14
			mov.b	#BIT4|BIT5, &LCDM18
			jmp		Fin
Bat2		mov.b	#BIT4|BIT5, &LCDM14
			mov.b	#BIT4|BIT5, &LCDM18
			jmp		Fin
Bat3		mov.b	#BIT4|BIT5, &LCDM14
			mov.b	#BIT4|BIT5|BIT6, &LCDM18
			jmp		Fin
Bat4		mov.b	#BIT4|BIT5|BIT6, &LCDM14
			mov.b	#BIT4|BIT5|BIT6, &LCDM18
			jmp		Fin
Bat5		mov.b	#BIT4|BIT5|BIT6, &LCDM14
			mov.b	#BIT4|BIT5|BIT6|BIT7, &LCDM18
			jmp		Fin
Bat6		mov.b	#BIT4|BIT5|BIT6|BIT7, &LCDM14
			mov.b	#BIT4|BIT5|BIT6|BIT7, &LCDM18

Fin			ret

;-----------------------------------------------------------------------------------
;			void lcdHrt (char h);
;			Escribe o borre el dígito del corazón en la pantalla LCD
;-----------------------------------------------------------------------------------
lcdHrt
			cmp.b	#0, R12
			jz		CorazonOFF

CorazonOn	mov.b	#BIT2, &LCDM3
			jmp		FinCorazon

CorazonOFF	bic.b	#BIT2, &LCDM3
FinCorazon	ret

;--------------------------------------------------------------------------------
;			void lcdAnt (char A);
;			Escribe o borra el dígito de la antena en la pantalla LCD
;--------------------------------------------------------------------------------
lcdAnt
			tst.b	R12
			jz		AntenaOFF

AntenaON	bis.b	#BIT2, &LCDM5
			jmp		AntenaFin

AntenaOFF	bic.b	#BIT2, &LCDM5
AntenaFin	ret

;---------------------------------------------------------------------------------
;			void lcdDosPuntos (char p)
;			Escribe o borra los dos puntos de la pantalla LCD
;--------------------------------------------------------------------------------
lcdDosPuntos
			cmp.b	#0, R12
			jz		PuntosOFF

PuntosOn	mov.b	#BIT2, &LCDM7
			jmp		FinPuntos

PuntosOFF	bic.b	#BIT2, &LCDM7
FinPuntos	ret

;-------------------------------------------------------------------------------
; Tabla de conversiÃ³n de 14 segmentos
;-------------------------------------------------------------------------------
			;       abcdefgm   hjkpq-n-
Tab14Seg	.byte	00000000b, 00000000b	;Espacio
			.byte	00000000b, 00000000b	;!
			.byte	00000000b, 00000000b	;"
			.byte	00000000b, 00000000b	;#
			.byte	00000000b, 00000000b	;$
			.byte	00000000b, 00000000b	;%
			.byte	00000000b, 00000000b	;&
			.byte	00000000b, 00000000b	;'
			.byte	00000000b, 00000000b	;(
			.byte	00000000b, 00000000b	;)
			.byte	00000011b, 11111010b	;*
			.byte	00000011b, 01010000b	;+
			.byte	00000000b, 00000000b	;,
			.byte	00000011b, 00000000b	;-
			.byte	00000000b, 00000000b	;.
			.byte	00000000b, 00101000b	;/
			;       abcdefgm   hjkpq-n-
			.byte	11111100b, 00101000b	;0
			.byte	01100000b, 00100000b	;1
			.byte	11011011b, 00000000b	;2
			.byte	11110011b, 00000000b	;3
			.byte	01100111b, 00000000b	;4
			.byte	10110111b, 00000000b	;5
			.byte	10111111b, 00000000b	;6
			.byte	10000000b, 00110000b	;7
			.byte	11111111b, 00000000b	;8
			.byte	11100111b, 00000000b	;9
			.byte	00000000b, 00000000b	;:
			.byte	00000000b, 00000000b	;;
			.byte	00000000b, 00100010b	;<
			.byte	00010011b, 00000000b	;=
			.byte	00000000b, 10001000b	;>
			.byte	00000000b, 00000000b	;?
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 00000000b	;@
			.byte	01100001b, 00101000b	;A
			.byte	11110001b, 01010000b	;B
			.byte	10011100b, 00000000b	;C
			.byte	11110000b, 01010000b	;D
			.byte	10011110b, 00000000b	;E
			.byte	10001110b, 00000000b	;F
			.byte	10111101b, 00000000b	;G
			.byte	01101111b, 00000000b	;H
			.byte	10010000b, 01010000b	;I
			.byte	01111000b, 00000000b	;J
			.byte	00001110b, 00100010b	;K
			.byte	00011100b, 00000000b	;L
			.byte	01101100b, 10100000b	;M
			.byte	01101100b, 10000010b	;N
			.byte	11111100b, 00000000b	;O
			;       abcdefgm   hjkpq-n-
			.byte	11001111b, 00000000b	;P
			.byte	11111100b, 00000010b	;Q
			.byte	11001111b, 00000010b	;R
			.byte	10110111b, 00000000b	;S
			.byte	10000000b, 01010000b	;T
			.byte	01111100b, 00000000b	;U
			.byte	01100000b, 10000010b	;V
			.byte	01101100b, 00001010b	;W
			.byte	00000000b, 10101010b	;X
			.byte	00000000b, 10110000b	;Y
			.byte	10010000b, 00101000b	;Z
			.byte	10011100b, 00000000b	;[
			.byte	00000000b, 10000010b	;\;
			.byte	11110000b, 00000000b	;]
			.byte	01000000b, 00100000b	;^
			.byte	00010000b, 00000000b	;_
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 10000000b	;`
			.byte	00011010b, 00010000b	;a				BYTE BAJO, BYTE ALTO
			.byte	00111111b, 00000000b	;b
			.byte	00011011b, 00000000b	;c
			.byte	01111011b, 00000000b	;d
			.byte	00011010b, 00001000b	;e
			.byte	10001110b, 00000000b	;f
			.byte	11110111b, 00000000b	;g
			.byte	00101111b, 00000000b	;h
			.byte	00000000b, 00010000b	;i
			.byte	01110000b, 00000000b	;j
			.byte	00000000b, 01110010b	;k
			.byte	00000000b, 01010000b	;l
			.byte	00101011b, 00010000b	;m
			.byte	00100001b, 00010000b	;n
			.byte	00111011b, 00000000b	;o
			;       abcdefgm   hjkpq-n-
			.byte	00001110b, 10000000b	;p
			.byte	11100111b, 00000000b	;q
			.byte	00000001b, 00010000b	;r
			.byte	00010001b, 00000010b	;s
			.byte	00000011b, 01010000b	;t
			.byte	00111000b, 00000000b	;u
			.byte	00100000b, 00000010b	;v
			.byte	00101000b, 00001010b	;w
			.byte	00000000b, 10101010b	;x
			.byte	01110001b, 01000000b	;y
			.byte	00010010b, 00001000b	;z
			.byte	00000000b, 00000000b	;{
			.byte	00000000b, 00000000b	;|
			.byte	00000000b, 00000000b	;}
			.byte	00000000b, 00000000b	;~
			.byte	00000000b, 00000000b	;

TabDig		.short	LCDM10				;Posicion del digito 1
			.short	LCDM6				;Posicion del ditio 2
			.short	LCDM4				;Posicion del digito 3
			.short	LCDM19				;Posicion del digito 4
			.short	LCDM15				;Posicion del digito 5
			.short	LCDM8				;Posicion del digito 6
