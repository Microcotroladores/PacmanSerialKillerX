;-----------INICIALIZACION LCD------------------------------------
LCD_INI:	CALL	T15MS
			MOVLW	03H
			MOVWF	BUS
			CALL	CMD_SIG
			CALL	T5MS
			MOVLW	03H		
			MOVWF	BUS
			CALL	CMD_SIG
			CALL	T100US
			MOVLW	03H
			MOVWF	BUS
			CALL	CMD_SIG
			CALL	T40US
			MOVLW	02H			
			MOVWF	BUS
			CALL	CMD_SIG
			CALL	T40US
			RETURN
		
;-----------CONFIGURACION LCD-------------------------------------------
LCD_CONF:	MOVLW	2CH
			CALL	LCD_CMD
			MOVLW	0CH	
			CALL	LCD_CMD
			MOVLW	06H	
			CALL	LCD_CMD
			RETURN

;-----------ENVIAR COMANDO-----------------------------------------------
LCD_CMD:	MOVWF	CMD			
			SWAPF	CMD,W
			ANDLW	0FH			
			CALL	CMD_SIG
			MOVF	CMD,W
			ANDLW	0FH			
			CALL	CMD_SIG
			CALL	T40US
			RETURN

;-----------ENVIAR DATO A LCD---------------------------------------------
LCD_DATO:	MOVWF	DATO
			SWAPF	DATO,W
			ANDLW	0FH							
			CALL	DATO_SIG
			MOVF	DATO,W
			ANDLW	0FH
			CALL	DATO_SIG
			CALL	T40US
			RETURN

;-----------SIGUIENTE COMANDO---------------------------------------
CMD_SIG:	MOVWF	BUS
			BCF		RS
			BSF		E		
			BCF		E
			BCF		RS
			CLRF	BUS			
			RETURN

;-----------SIGUIENTE DATO----------------------------------------
DATO_SIG:	MOVWF	BUS
			BSF		RS			
			BSF		E
			BCF		E
			BCF		RS
			CLRF	BUS			
			RETURN