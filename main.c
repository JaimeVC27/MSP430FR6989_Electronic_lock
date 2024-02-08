//--------------------------------------------------------------------
//  Vázquez Coronil, Jaime
//  Grupo: L9
//--------------------------------------------------------------------

#include <msp430.h> 
#include "msp430ports.h"
#include "pt.h"
#include "cs.h"
#include "lcd.h"
#include "st.h"
#include "teclado.h"

//Estados
#define Reposo          0
#define Prealarma       1
#define Abierto         2
#define Alarma          3

//Constantes de diseño
#define FTA2            32768   //Frecuencia del TA2 EN Hz
#define FContador       1       //1 vez por segundo
#define Fparpadeo       2       //2 veces por segundo (Medio apagado, medio encendido)
#define FEstados        100

//Constantes calculadas
#define FST             100
#define periodo         FTA2/FST-1     //CCR0
#define perContador     FST/FContador
#define perParpadeo     FST/Fparpadeo
#define perEstados      FST/FEstados

puerto_t LED1, LED2;

unsigned short int modo = Reposo;
unsigned short int Tiempo=60;
unsigned long ProxEjecContador=0;

void Contador (void);
void Parpadeos (void);
void Estados (void);

int main(void){

    WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	PM5CTL0 &= ~LOCKLPM5;       //Desbloquea los puertos de E/S

	LED1 = ptConfigura(1,0, PT_ESDIG|PT_SALIDA|PT_OFF|PT_ACTIVOALTA );  //Configuramos LED1
	LED2 = ptConfigura(9,7, PT_ESDIG|PT_SALIDA|PT_OFF|PT_ACTIVOALTA);   //Configuramos LED2

	csIniLFXT();                                                        //Habilitamos el oscilador LFXT
	lcdIni();                                                           //Iniciamos la pantalla LCD
	kbIni ();                                                           //Iniciamos Teclado
	lcdBorraTodo();                                                     //Borramos toda la pantalla LCD
	stIni(periodo);                                                     //Establecemos TIC del SystemTimer

	lcdHrt (1);                                                         //Empezamos el programa en Reposo (Corazon encendido)

	while(1){
	    Contador();
	    Parpadeos();
	    Estados();
	}
	//return 0;
}

void Contador(void){
    //static unsigned long ProxEjec=0;

    if(stTime() >= ProxEjecContador){
        ProxEjecContador += perContador;

        if(modo == Prealarma){
            if(Tiempo == 0){                    //Si se acaba el tiempo, pasamos al estado de alarma
               lcdBorraTodo();                  //borramos la pantalla LCD, empieza a parpadear la Antena y
               lcdAnt(1);                       //parpadea LED1
               ptEscribe(LED1, 1);
               ptEscribe(LED2, 0);
               modo = Alarma;
               return;
            }

            lcdBat(Tiempo/10);                  //Encendemos barras del nivel de batería

            escribeLetra(lcda2seg(Tiempo%10 + '0'), 2); //Esccribimos las unidades de segundos que quedan

            if(Tiempo/10 != 0){
                escribeLetra(lcda2seg(Tiempo/10 + '0'), 1); //Escribimos las decenas de segundos que quedan
            }else{
                escribeLetra(lcda2seg(' '), 1);             //Si quedan 0 decenas, no esccribimos nada
            }
            Tiempo--;
        }
    }
}

void Parpadeos(void){
    static unsigned long ProxEjec=0;
    static unsigned short int parpadeo=1;

    if(stTime() >= ProxEjec){
        ProxEjec += perParpadeo;

        switch (modo){
        case    Reposo:
            break;
        case    Prealarma:
            ptEscribe(LED1, parpadeo);
            break;
        case    Abierto:
            ptEscribe(LED2, parpadeo);
            break;
        case    Alarma:
            lcdAnt(parpadeo);
            break;
        }

        parpadeo = !parpadeo;
    }
}

void Estados (void){
    static unsigned long ProxEjec = 0;
    char letra;

    if(stTime() >= ProxEjec){
        ProxEjec += perEstados;

        letra = kbGetc();

        switch (modo){
                case    Reposo:
                    if(letra != 0){                     //Pasamos a Prealarma si se pulsa cualquier tecla
                        lcdHrt (0);
                        Tiempo = 60;
                        lcdDosPuntos (1);
                        modo = Prealarma;
                        if(letra >= '0' && letra <= '9'){
                            lcdPintaIzq4(letra);
                        }
                        ProxEjecContador = stTime();
                    }
                    break;
                case    Prealarma:
                    if(letra >= '0' && letra <= '9'){   //Escribimos las teclas que se pulsen
                        lcdPintaIzq4(letra);
                    }
                    if(Lee(3)==lcda2seg('1') && Lee(4)==lcda2seg('2') && Lee(5)==lcda2seg('3') && Lee(6)==lcda2seg('4') && letra == 'F'){
                        letra = 0;                      //Si la clave en pantalla es 1234, cambiamos de estado a Abierto
                        lcdBorraTodo();
                        ptEscribe(LED1, 0);
                        ptEscribe(LED2, 1);
                        modo = Abierto;
                    }
                    break;
                case    Abierto:
                    if(letra == 'B'){                   //Si pulsamos la tecla 'Cool', pasamos al estado de reposo
                        lcdHrt(1);
                        ptEscribe(LED2, 0);
                        modo = Reposo;
                        letra = 0;
                    }
                    break;

                case    Alarma:
                    if(letra >= '0' && letra <= '9'){   //Escribimos las teclas que se pulsen
                        lcdPintaIzq(letra);
                    }
                    if(Lee(1)==lcda2seg('1') && Lee(2)==lcda2seg('2') && Lee(3)==lcda2seg('3') && Lee(4)==lcda2seg('4') && Lee(5)==lcda2seg('5') && Lee(6)==lcda2seg('6') && letra == 'F'){
                        letra = 0;                      //Si la clave en pantalla es 123456, cambiamos de estado a Reposo
                        lcdBorraTodo();
                        lcdHrt (1);
                        ptEscribe(LED1, 0);
                        ptEscribe(LED2, 0);
                        lcdAnt(0);
                        modo = Reposo;
                    }
                    break;
                }
    }
}
