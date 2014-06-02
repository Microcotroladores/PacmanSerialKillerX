Send_Serial:    BSF     STATUS,RP0
                BSF     TXSTA,5
                BCF     STATUS,RP0
                MOVWF   TXREG
                CALL    T1MS
                NOP
                BSF     STATUS,RP0
                BCF     TXSTA,5
                BCF     STATUS,RP0
                RETURN
Get_Serial:     BSF     RCSTA,4 
                BTFSS   PIR1,RCIF
                GOTO    Get_Serial
                MOVF    RCREG,0
                RETURN