Send_Serial:    MOVWF   TXREG
                CALL    T1MS
                NOP
                RETURN
Get_Serial:     BTFSS   PIR1,RCIF
                GOTO    Get_Serial
                MOVF    RCREG,0
                BCF     PIR1,RCIF
                RETURN