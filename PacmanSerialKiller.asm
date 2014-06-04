;-----------ENCABEZADO---------------------------------------------------------
            #INCLUDE<P16F873A.INC>
			__CONFIG _XT_OSC & _WDT_OFF & _CP_OFF & _PWRTE_ON &_BODEN_OFF & _LVP_OFF & _CPD_OFF & _DEBUG_OFF
            LIST P=16F873A
;-----------DEFINICIONES---------------------------------------------------
			#DEFINE RS PORTC,0
			#DEFINE E PORTC,1
			#DEFINE BUS PORTB
;-----------REGISTROS------------------------------------------------------
			CBLOCK  20H
			CMD
			DATO
			CNN
			ROOST
			TUPAC
			TROOPER0
			TROOPER1
            TROOPER2
            TROOPER3
			V0
			V1
			V2
			ENDC
;-----------INICIO--------------------------------------------------------
			ORG 000H

            BCF     STATUS,RP1
			BSF     STATUS,RP0

			CLRF    TRISA
			MOVLW   0F0H
			MOVWF   TRISB
            CLRF    TRISC
            BSF     TRISC,7
            
            MOVLW 07H
			MOVWF OPTION_REG
            MOVLW   19H
            MOVWF   SPBRG           ;Configura la velocidad a 9600bps
            CLRF    TXSTA
            BSF     TXSTA,2
            BSF     TXSTA,5

			BCF     STATUS,RP0
			CLRF    PORTA
			CLRF    PORTB
            CLRF    PORTC
            clrf    RCSTA
            BSF     RCSTA,4
            BSF     RCSTA,7

;-----------INICIALIZACION Y CONF DE LCD---------------------------------
			CALL    LCD_INI
			CALL    LCD_CONF
			MOVLW   01H
			CALL    LCD_CMD
			CALL    T5MS
			CALL    CYC
 ;----------PRINCIPAL-----------------------------------------------------
MAIN:		MOVLW   01H
			CALL    LCD_CMD
			CALL    T5MS
			MOVLW   01H
			CALL    LCD_CMD
			CALL    T5MS
;-----------MOSTRAR CARACTERES------------------------------------------
;-----------COMIDA ANTES DE PACMAN & PACMAN----------------------------
        	CLRF    TROOPER0
			CLRF    TROOPER1
			MOVLW   80H
			CALL    LCD_CMD
			CLRF    CNN
			MOVLW   00H
			CALL    LCD_DATO
			INCF    CNN,1
			MOVLW   00H
			CALL    LCD_DATO
			MOVLW   06H   ;INDICA EN QUE POSICION INICIARA EL PACMAN 06H
			SUBWF   CNN,W
			BTFSC   STATUS,Z
			GOTO    SANCTUARY
			GOTO    $-7
;-----------COMIDA DESPUES DE PACMAN------------------------------------
SANCTUARY:  MOVLW   87H
			MOVWF   ROOST
			BSF     TROOPER0,7
			MOVLW   01H
			MOVWF   TUPAC
			CALL    LCD_DATO
			INCF    CNN,1
			MOVLW   00H
			CALL    LCD_DATO
			MOVLW   0EH
			SUBWF   CNN,W
			BTFSS   STATUS,Z
			GOTO    $-6
			MOVLW   03H
			CALL    LCD_DATO
            MOVLW   0C0H    ;2NDO RENGLON
			CALL    LCD_CMD
			CALL    T5MS
			MOVLW   00H
			CALL    LCD_DATO
			CLRF    CNN
			INCF    CNN,1
			MOVLW   00H
			CALL    LCD_DATO
			MOVLW   10H
			SUBWF   CNN,0
			BTFSS   STATUS,Z
			GOTO    $-6
            CALL    TXTINI
;-----------LEER DATOS DEL TECLADO-------------------------------
TECLADO: 	CALL    Get_Serial
			XORLW   'a'            ;3CH
			BTFSC   STATUS,Z
			GOTO    IZQUIERDA

            MOVF    RCREG,0
			XORLW   'd'
			BTFSC   STATUS,Z
			GOTO    DERECHA

            MOVF    RCREG,0
			XORLW   'w'
			BTFSC   STATUS,Z
			GOTO    ARRIBA

            MOVF    RCREG,0
			XORLW   's'
			BTFSC   STATUS,Z
			GOTO    ABAJO

            ;BCF     PIR1,RCIF
            GOTO    TECLADO
;-----------VALORES PARA POSICION--------------------------------
TABLA:		ADDWF   PCL,1
            DT      01H,02H,04H,08H,10H,20H,40H,80H
;-----------MOVIMIENTOS--------------------------------------------
IZQUIERDA:	BTFSS   PORTB,4
			GOTO    $-1
			MOVLW   01H
			SUBWF   ROOST,W
			BTFSS   STATUS,DC
			GOTO    GOKUI
			MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   ' '
			CALL    LCD_DATO
			MOVLW   01H
			SUBWF   ROOST,1
			CALL    CK
			MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   02H
			MOVWF   TUPAC
			CALL    LCD_DATO
			GOTO    TECLADO

DERECHA:	BTFSS   PORTB,6
			GOTO    $-1
			MOVLW   8FH
			SUBWF   ROOST,W
			BTFSC   STATUS,Z
			GOTO    GOKUD
			MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   ' '
			CALL    LCD_DATO
			MOVLW   01H
			ADDWF   ROOST,1
			CALL    CK
			MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   01H
			MOVWF   TUPAC
			CALL    LCD_DATO
			GOTO    TECLADO

ARRIBA: 	BTFSS   PORTB,5
			GOTO    $-1
			BTFSS   ROOST,6
			GOTO    TECLADO
			MOVF    ROOST,0
			CALL    LCD_CMD
			MOVLW   ' '
			CALL    LCD_DATO
			MOVLW   0x40
			SUBWF   ROOST,1
			CALL    CK
			MOVF    ROOST,0
			CALL    LCD_CMD
			MOVF    TUPAC,0
			CALL    LCD_DATO
			GOTO    TECLADO

ABAJO: 		BTFSS   PORTB,5
			GOTO    $-1
			BTFSC   ROOST,6
			GOTO    TECLADO
			MOVF    ROOST,0
			CALL    LCD_CMD
			MOVLW   ' '
			CALL    LCD_DATO
			MOVLW   40H
			ADDWF   ROOST,1
			CALL    CK
			MOVF    ROOST,0
			CALL    LCD_CMD
			MOVF    TUPAC,0
			CALL    LCD_DATO
			GOTO    TECLADO
;-----------REGRESO CUANDO SE LLEGA AL VALOR LIMITE DE PANTALLA------------
GOKUI:  	MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   ' '
			CALL    LCD_DATO
			MOVLW   00H
			ADDWF   ROOST,1
			CALL    CK
			MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   02H
			MOVWF   TUPAC
			CALL    LCD_DATO
			GOTO    TECLADO

GOKUD:      MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   ' '
			CALL    LCD_DATO
			MOVLW   00H
			SUBWF   ROOST,1
			CALL    CK
			MOVF    ROOST,W
			CALL    LCD_CMD
			MOVLW   01H
			MOVWF   TUPAC
			CALL    LCD_DATO
			GOTO    TECLADO
;-----------VERIFICAR IZQUIERDA O DERECHA------------------------------
CK:         BTFSS   ROOST,6
            GOTO    CKU
            GOTO    CKD
MAIDEN:     CALL    IRON
            RETURN
CKU:        BTFSS   ROOST,3
            GOTO    FAP0
            GOTO    FAP1
CKD:        BTFSS   ROOST,3
            GOTO    FAP2
            GOTO    FAP3
;-----------COMPARAR POSICION PARA INCREMENTAR REGISTRO----------------
FAP0:		MOVLW   07H
			ANDWF   ROOST,W
			CALL    TABLA
			IORWF   TROOPER0,1
			GOTO    MAIDEN

FAP1:		MOVLW   07H
			ANDWF   ROOST,W
			CALL    TABLA
			IORWF   TROOPER1,1
			GOTO    MAIDEN

FAP2:		MOVLW   07H
			ANDWF   ROOST,0
			CALL    TABLA
			IORWF   TROOPER2,1
			GOTO    MAIDEN

FAP3:		MOVLW   07H
			ANDWF   ROOST,0
			CALL    TABLA
			IORWF   TROOPER3,1
			GOTO    MAIDEN
;-----------VERIFICA LA CANTIDAD DE FRUTRAS------------------------------
IRON:       MOVLW   0FFH
			SUBWF   TROOPER0,W
			BTFSS   STATUS,Z
			RETURN
			MOVLW   0FFH
			SUBWF   TROOPER1,W
			BTFSS   STATUS,Z
			RETURN
			MOVLW   0FFH
			SUBWF   TROOPER2,0
			BTFSS   STATUS,Z
			RETURN
			MOVLW   0FFH
			SUBWF   TROOPER3,0
			BTFSS   STATUS,Z
			RETURN
			MOVLW   01H
			CALL    LCD_CMD
			CALL    T5MS
			CALL    TERMTXT
			CALL    T1S
			GOTO    MAIN
;-----------LIBRERIAS AUXILIARES---------------------------------------
			#INCLUDE<TIEMPOS.INC>
			#INCLUDE<LCD.INC>
			#INCLUDE<CARACTERES.INC>
			#INCLUDE<TEXTOS.INC>
            #INCLUDE<COMSERIAL.INC>
;-----------FIN----------------------------------------------------
            END