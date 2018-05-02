;*****************************************************************************************************************************************************
;*															SECCION DE BSS																			 *
;*****************************************************************************************************************************************************
section .bss


;*****************************************************************************************************************************************************
;*															SECCION DE DATA																			 *
;*****************************************************************************************************************************************************
section .data
;=======================================================
; MACROS
;=======================================================
%macro PRINTSTRING 1
	PUSH AX
	PUSH CX
	PUSH BX

	MOV DX, %1		; COLOCO EL MENSAJE A IMPRIMIR
	MOV AH, 9 	 	; MUEVO 9 PARA LA IMPRIMIR EN PANTALLA
	INT 21H			; LLAMADA AL A INTERRUPCION 21H

	POP BX
	POP CX
	POP AX
%endmacro
%macro IMPRIMECHAR 1
	PUSH AX
	PUSH CX
	PUSH BX

	MOV AH, 02H		; DUNCION PARA IMPRIMIR UN CARACTER
	MOV DL, %1 		; CARACTER DE SALIDA A IMPRIMIR
	INT 21H 		; INTERRUPCION 21H

	POP BX
	POP CX
	POP AX
%endmacro
%macro open_file 2 				; P1: NOMBRE DEL ARCHIVO, P2: HANDLE DONDE DEVOLVERE EL MANEJADOR DEL ARCHIVO
	MOV AH, 3DH 				; FUNCION PARA ABRIR EL FICHERO
	MOV AL, 010B				; APERTURA SOLO DE LECTURA/ESCRITURA
	MOV DX, %1 					; NOMBRE DEL ARCHIVO
	INT 21H						; LLAMADA A LA INTERRUPCION PARA ABRIR

	;JC USERFILE_ERR 		    ; SI HUBO UN ERROR....

	MOV %2, AX	 				; MUEVO EL HANDLE AL PARAMETRO 2
%endmacro
%macro close_file 1 			; P1: HANDLE
	MOV AH, 3EH					; FUNCION PARA CERRAR UN FICHERO
	MOV BX, %1 					; PONGO EL HANDLE DEL ARCHIVO EN CUESTION
	INT 21H 					; CIERRO EL ARCHIVO
%endmacro
%macro read_file 3 				; P1: HANDLE, P2: BUFFER DE CARATERES, P3, NUMERO DE CARACTERES LEIDOS
	MOV BX, %1 					; MUEVO EL HANDLE A BX 
	MOV AH, 3FH					; FUNCION PARA LA LECTURA DE UN FICHERO
	MOV CX, 0FFH 				; 255 CARACTERES
	MOV DX, %2 					; EN DONDE SE DEPOSITARAN LOS CARACTERES LEIDOS
	INT 21H
	
	;JC USERFILE_ERR 	

	MOV %3, AX 					; PONGO EL NUMERO DE CARACTERES LEIDOS
%endmacro
%macro write_in_file 3 			; P1: HANDLE, P2: # BYTES A ESCRIBIR, P3: BUFFER
	MOV AH, 40H 				; FUNCION PARA ESCRITURA EN UN ARCHIVO					
	MOV BX, %1 					; COLOCO EL HANDLER EN BX
	MOV CX, %2 					; NUMERO DE BYTES A ESCRIBIR
	MOV DX, %3 					; EL BUFFER DE DONDE SE TOMARAN LOS CARACTERES
	INT 21H 					; LLAMADA A LA INTERRUPCION 21
%endmacro
%macro create_file 2 			; P1: NOMBRE DEL ARCHIVO, P2: LUGAR DONDE SE VA A GUARDAR EL HANDLE DEL ARCHIVO
	MOV AH, 3CH 				; FUNCION PARA CREAR UN NUEVO ARCHIVO
	MOV DX, %1 					; NOMBRE DEL ARCHIVO A CREAR 
	MOV CX, 00H                 ; CREACION DE UN ARCHIVO NORMAL
	INT 21H

	;JC USERFILE_ERR 

	MOV %2, AX 					; HANDLE DEL ARCHIVO
%endmacro
%macro CL_STRING 1 				; P1: CADENA A LIMPIAR (BUFFER)
	PUSH BX
	PUSH AX
	PUSH DX
	PUSH CX

	XOR DX,DX
	MOV BX,BX
	MOV BX, %1
	CALL CLEAN_STRING

	POP CX
	POP DX
	POP AX
	POP BX
%endmacro
%macro IN_STRING 1 				; P1: BUFFER DONDE GUARDO LOS DATOS
	PUSH BX
	PUSH AX
	PUSH DX
	PUSH CX

	XOR DX, DX
	XOR BX, BX
	MOV BX, %1
	CALL INPUT_STRING

	POP CX
	POP DX
	POP AX
	POP BX
%endmacro
%macro EQUALS 2 				; P1: STRING 1, P2: STRING 2
	MOV byte[igualdad], 1h 		; ASUMO QUE SON IGUALES
	XOR BX, BX
	XOR SI, SI
	XOR AX, AX
	XOR DX, DX
	MOV BX, %1
	MOV SI, %2
	CALL COMPARA_STRING
	XOR BX, BX
	XOR AX, AX
	XOR DX, DX
	XOR SI, SI
%endmacro
%macro COUNT 2 					; P1: STRING A CONTAR, P2: LUGAR DONDE SE GUARDARA LA CUENTA
	PUSH BX
	PUSH CX
	PUSH AX
	PUSH DX
	XOR BX, BX
	MOV BX, %1
	CALL COUNT_CHAR
	MOV %2, CL
	POP DX
	POP AX
	POP CX
	POP BX
%endmacro
%macro ANALIZAR 1 				; P1: LA DIRECCION DE MEMORIA DE LA CADENA A ANALIZAR
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH AX
	PUSH SI
	;------------------------
	MOV BX, %1 					; MOVER LA CADENA A BX PARA PODER HACER EL ANALISIS
	MOV CX, 00H 				; MUEVO EL CONTADOR
	MOV SI, funcion
	MOV DI, funcion
	CALL STATE_0
	;------------------------
	POP SI
	POP AX
	POP DX
	POP CX
	POP BX
%endmacro
%macro EVALUA_TERM 2 			; P1: CADENA (MISMO FORMATO QUE FUNCION), P2: INDICE DE CADENA
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DX
	;-------------------------
	MOV BX, %1      			; MUEVO LA POSICION BX A FUNCION 
	XOR AX, AX 					; LIMPIO AX
	MOV AL, 09h 				; MUEVO AL 9 PARA DESPUES MULTIPLICARLO POR EL FACTOR O INDICE QUE QUIERO ENCONTRAR
	MOV CL, %2
	MUL CL 						; MULTIPLICO POR EL INDICE
	ADD BX, AX
	MOV byte[tipo_term], 03h
	CALL EVL_TERM
	;-------------------------
	POP DX
	POP SI
	POP CX
	POP AX
	POP BX
%endmacro
%macro GET_VAR 2				; P1: CADENA, P2: INDICE
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DX
	;-------
	MOV BX, %1 					; PUNTERO DE LA CADENA DONDE VOY A EXTRAER LA VARIABLE
	
	;-------
	POP DX
	POP SI
	POP CX
	POP AX
	POP BX
%endmacro
%macro GET_NUM 2 				; P1: CADENA, P2: INDICE
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DX
	;-------
	MOV BX, %1 					; MUEVO EL PUNTERO A LA POSICION DE BX
	XOR AX, AX 					; LIMPIO EL REGISTRO AX
	MOV AL, 09H 				; MUEVO EL NUEVE PARA PODER MOVERME DENTRO DE CADA TERMINO
	MOV CL, %2 					; MUEVO EL INDICE DEL TERMINO (0,1,2,3)
	MUL CL 						; MULTIPLICO AL * CL
	ADD BX, AX 					; SUMO BX + AX PARA MOVERME EN LA POSICION
	INC BX 						; SUMO 1 PARA PODER POSICIONARME DESPUES DEL SIGNO DEL TERMINO
	MOV SI, coef 				; MUEVO EL PUNTERO DEL COEF PARA OBTENER EL NUMERO
	CALL OBT_NUM
	;-------
	POP DX
	POP SI
	POP CX
	POP AX
	POP BX
%endmacro
%macro GET_EXP 2
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DX
	;-------
	MOV BX, %1 					; MUEVO EL PUNTERO A LA POSICION DE BX
	XOR AX, AX 					; LIMPIO EL REGISTRO AX
	MOV AL, 09H 				; MUEVO EL NUEVE PARA PODER MOVERME DENTRO DE CADA TERMINO
	MOV CL, %2 					; MUEVO EL INDICE DEL TERMINO (0,1,2,3)
	MUL CL 						; MULTIPLICO AL * CL
	ADD BX, AX 					; SUMO BX + AX PARA MOVERME EN LA POSICION
	INC BX 						; ME MUEVO UNA POSICION MAS PARA EMPEZAR CON EL RECORRIDO
	MOV SI, expo
	CALL OBT_EXP
	;-------
	POP DX
	POP SI
	POP CX
	POP AX
	POP BX
%endmacro
%macro TO_NUM1 2 				; P1: CADENA DONDE SE ENCUENTRA EL NUMERO, P2: DONDE VA EL RESULTADO
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DX
	;------
	MOV %2, 00h 		        ; LIMPIO LA VARIABLE
	MOV BX, %1 					; POSICIONO EL PUNTERO AL INICIO DE LA CADENA
	;INC BX 						; ME POSICIONO DONDE INICIA EL NUMERO
	MOV AL, byte[BX]			; MUEVO EL CARACTER
	SUB AL, 30H 				; LE QUITO 30 PARA TENER EL VALOR EN HEXA
	MOV %2, AL 			        ; MUEVO EL RESULTADO A LA VARIABLE
	;------
	POP DX
	POP SI
	POP CX
	POP AX
	POP BX
%endmacro
%macro TO_NUM2 2 				; P1: CADENA DONDE SE ENCUENTRA EL NUMERO, P2: DONDE VA EL RESULTADO
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DX
	;------
	XOR AX, AX
	MOV %2, 00h 		        ; LIMPIO LA VARIABLE
	MOV BX, %1 					; POSICIONO EL PUNTERO AL INICIO DE LA CADENA
	;INC BX 						; ME POSICIONO DONDE INICIA EL NUMERO
	MOV AL, byte[BX]			; MUEVO EL CARACTER
	SUB AL, 30H 				; LE QUITO 30 PARA TENER SU VALOR
	MOV CL, 0AH 				; MUEVO A CL EL 10
	MUL CL 						; AX * 10 
	MOV %2, AL 					; GUARDO EL NUMERO EN LA MEMORIA LA VARIABLE
	;INC BX 						; INCREMENTO BX
	MOV AL, byte[BX]			; OBTENGO EL SIGUIENTE NUMERO
	SUB AL, 30H 				; LE QUITO 30 PARA PODER SACAR EL VALOR
	ADD %2, AL 					; LE SUMO EL SIGUIENTE DIGITOS
	;------
	POP DX
	POP SI
	POP CX
	POP AX
	POP BX
%endmacro
%macro NUM_TO_CHAR 2 						; P1: VARIABLE TIPO WORD DONDE ALMACENARE LA RESPUESTA, P2: ARREGLO DONDE SE ALMACENARA EL ARREGLO
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH DX
	PUSH SI
	;--------
	XOR AX, AX 
	XOR DX, DX
	XOR CX, CX
	XOR BX, BX
	MOV AX, word[%1] 						; PONIENDO LA VARIABLE QUE ALMACENA EL NUMERO Y QUE VOY A COMVENRTIR
	MOV BX, %2 								; LA DIRECCION DE LA CADENA
	CALL DEC_TO_CHAR
	;--------
	POP SI
	POP DX
	POP CX
	POP AX
	POP BX
%endmacro
%macro NUM_SALIDA 2 						 ; P1: ARREGLO DONDE ESTA EL RESULTADO DE LA NUM_TO_CHAR, P2: DONDE QUIERO LA SALIDA
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH DX
	PUSH SI
	;--------
	MOV BX, %1
	MOV SI, %2
	CALL MOSTRARRESP1
	;--------
	POP SI
	POP DX
	POP CX
	POP AX
	POP BX
%endmacro
;=====================================================================================================================================================
pausemens           db 10,"** PRESS ANY KEY TO CONTINUE.... ***$"
igualdad            db  0 										; BANDERA QUE VA A USARSE PARA SABER SI DOS STRINGS SON IGUALES
mensal              db 10,"********** SALIENDO ..... **********",10,13,"$"
;--------------------------------------
; MENU PRINCIPAL
;--------------------------------------
menu 				db "*********************************************************",10,13,
					db "*                 MENU PRINCIPAL CALCULADORA            *",10,13,
					db "*********************************************************",10,13,
					db "*  1) DERIVAR FUNCION                                   *",10,13,
					db "*  2) INTEGRAR FUNCION                                  *",10,13,
					db "*  3) INGRESAR FUNCIONES                                *",10,13,
					db "*  4) IMPRIMIR FUNCIONES                                *",10,13,
					db "*  5) GRAFICAR FUNCION                                  *",10,13,
					db "*  6) RESOLVER ENCUACION                                *",10,13,
					db "*  7) REPORTES                                          *",10,13,
					db "*  8) SALIR                                             *",10,13,
					db "*********************************************************",10,13,
					db "* >> $"

;=====================================================================================================================================================
der_menu 			db "*********************************************************",10,13,
					db "*                 DERIVAR UNA FUNCION                   *",10,13,
					db "*********************************************************",10,13,
					db "* INGRESE LA FUNCION:                                   *",10,13,
					db "*********************************************************",10,13,
					db " >> $"

error_analisis      db "************** ERROR EN LA CADENA DE ENTRADA *************",10,13,"$"

aceptado 			db "************** CADENA ACEPTADA ***************************",10,13,"$"

entrada times 255   db "$"

mder1 				db "DERIVADA 1$"
mder0 				db "DERIVADA 0$"
;----------------------------------------------------------------------------------------------------
funcion 			db "$$$$$$$$$" 													; ALMACENA
					db "$$$$$$$$$" 													; TERMINOS DE 
					db "$$$$$$$$$"													; CADA
					db "$$$$$$$$$"													; FUNCION

derivada 			db "$$$$$$$$$"													; ALMACENA
					db "$$$$$$$$$" 													; TERMINOS 
					db "$$$$$$$$$"													; DE LA FUNCION
					db "$$$$$$$$$"													; DERIVADA

tipo_term 			db 0

coef 	times 5     db "$" 															; ALMACENA EL COEFICIENTE DEL TERMINO A PROCESAR
expo 	times 3     db "$" 															; ALMACENA EL EXPONENETE DEL TERMIO A PROCESAR

coef_num 			db 0h

tam 				db 0h

salida  times 7     db '$'

resul 				dw 0h

charArr 			db '$'
;-----------------------------------------------------------------------------------------------------
;*****************************************************************************************************************************************************
;*															SECCION DE TEXT																			 *
;*****************************************************************************************************************************************************
section .text

	global MAIN

	MAIN:
		ORG 100H
		JMP MENU_PRINCIPAL


	MENU_PRINCIPAL:
		CALL CLS
		PRINTSTRING menu 										; IMPRIMIENDO EL MUNUN PRINCIPAL
		CALL GETCHAR 											; OBTIENIENDO EL INGRESO DE LA ENTRADA DEL CARACTER
		CMP AL, '1'												; SI LA OPCION ES 1
		JE OP_DERIVAR 											; --SALTA A DERIVAR
		CMP AL, '2'												; SI ES LA OPCION 2
		JE OP_INTEGRAR 											; --SALTA A INTEGRAR
		CMP AL, '3'												; SI ES LA OPCION 3
		JE OP_IN_FUN 											; --SALTA A INGRESAR FUNCIONES
		CMP AL, '4'												; SI ES LA OPCION 4
		JE OP_PR_FUN 											; -- SALTA A IMPRIMIR FUNCIONES
		CMP AL, '5'												; SI ES LA OPCION 5
		JE OP_GR_FUN 											; -- SALTA A GRAFICAR LA FUNCION
		CMP AL, '6'												; SI ES LA OPCION 6
		JE OP_RE_FUN 											; -- SALTA A RESOLVER ECUACION
		CMP AL, '7'												; SI ES LA OPCION 7
		JE OP_REP_FUN 											; -- SALTA A REPORTES DE APLICACION
		CMP AL, '8'												; SI ES LA OPCION 8
		JE SALIR_PROGRAMA 										; ---SALE
		JMP MENU_PRINCIPAL 										; CUALQUIER OTRA OPCIONE VUELVE A PEDIR LA ENTRADA
		
	SALIR_PROGRAMA:
		CALL EXIT

;*****************************************************************************************************************************************************
;*															SECCION DE DERIVAR   																	 *
;*****************************************************************************************************************************************************
	OP_DERIVAR:
		CL_STRING entrada 										; LIMPIA LA ENTRADA
		CALL CLS 												; LIMPIA LA PANTALLA
		PRINTSTRING der_menu 									; IMPRIME EL MENU
		IN_STRING entrada 										; OBTENGO LA ENTRADA DEL TECLADO
		ANALIZAR entrada 										; ANALIZA LA ENTRADA PARA PODER  TOMAR LOS TERMINOS DE LA FUNCION
		;*-------------------------------------------------------
		; LLAMADA ALA DERIVADA
		CALL DERIVA_FUNCION
		;*------------------------------------------------------- 
		CALL LIMPIAR_FUN
		CALL SYSPAUSE 											; PAUSA
		JMP MENU_PRINCIPAL


	DERIVA_FUNCION:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;-------------
		; AQUI INICIARIA LA DERIVACION
		MOV BX, funcion 										; BX APUNTA AL ARREGLO DE STRINGS DE FUNCION
		MOV CX, 00H												; CX CONTIENE 0 AHORA
		MOV SI, derivada 										; SI APUNTA AL ARREGLO DE STRINGS DE LA DERIVADA
		LOOP_DER:
			CMP CL, 03h											; EL CONTADOR ES MAYOR A 3?
			JG FIN 												; SI ES MAYOR ENTONCES TERMINA
			EVALUA_TERM funcion, CL 							; EVALULO LA POSICION CL DEL ARREGLO DE LA FUNCION
			CMP byte[tipo_term], 02h 							; SI TIENE EXPONENTE
			JE LLAMA_DE2
			CMP byte[tipo_term], 01h
			JE LLAMA_DE1
			CMP BYTE[tipo_term], 00h
			JE LLAMA_DE0
			LLAMA_DE0:
				CALL DERIVA0 									; LLAMA A LA DERIVADA DE TIPO 1
				XOR AX, AX 										; LIMPIO EL REGISTRO
				JMP DER_VUELVE
			LLAMA_DE1:
				CALL DERIVA1
				XOR AX, AX 										; LIMPIO EL REGISTRO
				JMP DER_VUELVE
			LLAMA_DE2:
				CALL DERIVA2									; LLAMADA ALA ENCARGADA DERIVAR EL QUE TIENE EXPONENTE
				XOR AX, AX 										; LIMPIO AX
				JMP DER_VUELVE
			DER_VUELVE:
				;----------
				; AUMENTO
				;----------
				ADD BX, 09H										; AUMENTAR UNA POSICION EN BX EN EL ARREGLO DE FUNCION
				ADD SI, 09H 									; AUMENTAR UNA POSICION EN SI EN EL ARREGLO DE DERIVADA
				INC CX											; INCREMENTO EL CONTADOR
				MOV byte[tipo_term], 003h
				JMP LOOP_DER
		;-------------
		FIN:
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	DERIVA0:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		PRINTSTRING mder0
		IMPRIMECHAR 10
		;------
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	DERIVA1:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		PRINTSTRING mder1
		IMPRIMECHAR 10
		;------
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	DERIVA2:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		MOV byte[coef_num], 0h
		CL_STRING coef 											; LIMPIO EL COEFICIENTE
		CL_STRING expo 											; LIMPIO EL EXPONENTE
		CL_STRING salida
		GET_NUM BX, CL 											; OBTENGO EL NUMERO
		GET_EXP BX, CL 											; OBTENGO EL EXPONENTE
		COUNT coef, [tam] 										; CUENTO EL TAMANO DEL COEFICIENTE
		CMP byte[tam], 01h 										; SI ES 1?
		JE P_COEF1 												; SI SI.. VAS A PROCESAR EL COEF 1
		JMP P_COEF2 											; SI NO FIJO TE VAS AL COEF 2
		;---------
		P_COEF1:
			TO_NUM1 coef, byte[coef_num] 							; OBTENGO EL NUMERO DE COEFICIENTE EN HEXA
			JMP P_CONT
		P_COEF2:
			TO_NUM2 coef, byte[coef_num]							; OBTNEGO EL COEFICIENTE DE DOS DIGITOS
			JMP P_CONT
		;---------
		P_CONT:
			XOR DX, DX
			XOR AX, AX
			MOV DL, byte[expo]									; GUARDO EL EXPONENTE
			SUB DL, 30H 										; LE SUBSTRAIGO 30H PARA PODER OBTENER EL NUMERO EN HEXA
			MOV AL, byte[coef_num]								; GUARDO EL COEFICIENTE EN AL PARA HACER LA MULTIPLICACION
			MUL DL 												; MULTIPLICO DL * AL
			MOV AH, 00H
			MOV word[resul], AX 								; GUARDO EL RESULTADO
			NUM_TO_CHAR resul, charArr 							; CONVIERTO EL NUMERO A ARREGLO
			NUM_SALIDA charArr, salida 							; CONVIERTO EL ARREGLO EN STRING DE SALIDA
			PRINTSTRING salida
			IMPRIMECHAR 10
		;------
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

;***************************************************************************************************
;*								ANALIZADOR LEXICO                           					   *
;***************************************************************************************************
	STATE_0:
		CMP byte[BX], '+'										; ES SIGNO DE +
		JE INCREMENTA 											; SALTA AL INCREMENTO
		CMP byte[BX], '-'										; ES SIGNO DE -
		JE INCREMENTA 											; SALTA AL INCREMENTO
		JMP SALTA_1 											; SALTA A 1 SIN INCREMENTAR 							
		INCREMENTA:
			;-----SIGNO-------
			MOV AL, byte[BX]									; MUEVO EL CARACTER A AL
			MOV byte[SI], AL 									; GUARDO EL CARACTER
			INC SI
			;-----------------
			INC BX												; INCREMENTA BX Y SALTA
			JMP STATE_1
		SALTA_1:
			;--------------------------
			MOV byte[SI], '+'
			INC SI 												; EN CASO DE QUE NO HUBIESE SIGNO LE AGREO POSITIVO
			;--------------------------
			JMP STATE_1

	STATE_1:
		CMP byte[BX], '0'										; LIMITE INFERIOR
		JL ERROR_A
		CMP byte[BX], '9' 										; LIMITA SUPERIOR
		JG ERROR_A
		; GUARDAR NUMERO 										
		;----------------
		MOV AL, byte[BX]									; MUEVO EL CARACTER A AL
		MOV byte[SI], AL 									; GUARDO EL CARACTER
		INC SI
		;----------------
		INC BX 													; INCREMENTAR PARA EL SIGUIENTE CARACTER
		CMP byte[BX], '$'										; TERMINO LA CADENA?
		JE ACEPTAR
		CMP byte[BX], '0'										; LIMITE INFERIOR
		JL SALTA_2
		CMP byte[BX], '9' 										; LIMITA SUPERIOR
		JG SALTA_2
		; GUARDAR NUMERO
		;------------------
		MOV AL, byte[BX]									; MUEVO EL CARACTER A AL
		MOV byte[SI], AL 									; GUARDO EL CARACTER
		INC SI
		;------------------
		INCREMENTA1:
			INC BX
		SALTA_2:			
			JMP STATE_2

	STATE_2:
		CMP byte[BX], '$'										; TERMINO LA CADENA?
		JE ACEPTAR
		CMP byte[BX], 'A'										; SI ES UNA LETRA
		JL ERROR_A 												; SI ES MENOR ES ERROR_A
		CMP byte[BX], 'Z'										; SI ES Z MAYUSCULA O MENOR
		JG EVALUA_MINUS
		; GUARDA CARACTER
		;------------------------
		MOV AL, byte[BX]									; MUEVO EL CARACTER A AL
		MOV byte[SI], AL 									; GUARDO EL CARACTER
		INC SI
		;------------------------
		JMP INCREMENTA2
		EVALUA_MINUS:
			CMP byte[BX], 'a'									; SI ES MINUSCULA
			JL ERROR_A
			CMP byte[BX], 'z'									; SI ES MAYOR A Z
			JG ERROR_A
			; GUARDO
			;----------------
			MOV AL, byte[BX]									; MUEVO EL CARACTER A AL
			MOV byte[SI], AL 									; GUARDO EL CARACTER
			INC SI
			;---------------
		INCREMENTA2:
			INC BX
		SALTA_3:
			JMP STATE_3


	STATE_3:
		CMP byte[BX], '$'										; ES EL FINAL DE LA CADENA?
		JE ACEPTAR 												; ACEPTA LA CADENA
		CMP byte[BX], '^'										; VIENE EL SOMBRERO?
		JNE SALTA_4
		INCREMENTA3:
			MOV AL, byte[BX]									; MUEVO EL CARACTER A AL
			MOV byte[SI], AL 									; GUARDO EL CARACTER
			INC SI
			INC BX
			JMP STATE_4
		SALTA_4:
			CMP BYTE[BX], '$'
			JE ACEPTAR
			ADD DI, 09H
			MOV SI, DI
			JMP STATE_0

	STATE_4:
		CMP byte[BX], '0'										; LIMITE INFERIOR
		JL ERROR_A
		CMP byte[BX], '9' 										; LIMITA SUPERIOR
		JG ERROR_A
		; GUARDAR NUMERO
		;--------------------------
		MOV AL, byte[BX]									; MUEVO EL CARACTER A AL
		MOV byte[SI], AL 									; GUARDO EL CARACTER
		ADD DI, 09H
		MOV SI, DI
		;---------------------------
		INC BX
		CMP byte[BX], '$'										; FINALIZO LA CADENA?
		JE ACEPTAR
		JMP STATE_0										

	ERROR_A:
		CALL CLS
		IMPRIMECHAR 10
		PRINTSTRING error_analisis
		IMPRIMECHAR 10
		CALL SYSPAUSE
		RET

	ACEPTAR:
		;CALL CLS
		;IMPRIMECHAR 10
		;PRINTSTRING aceptado
		;IMPRIMECHAR 10
		;MOV DI, funcion
		;PRINTSTRING DI
		;IMPRIMECHAR 10
		;ADD DI, 09H
		;PRINTSTRING DI
		;IMPRIMECHAR 10
		;ADD DI, 09H
		;PRINTSTRING DI
		;IMPRIMECHAR 10
		;ADD DI, 09H
		;IMPRIMECHAR 10
		;CALL LIMPIAR_FUN
		;CALL SYSPAUSE
		RET

	LIMPIAR_FUN:
		MOV DI, funcion
		CL_STRING DI
		ADD DI, 09H
		CL_STRING DI
		ADD DI, 09H
		CL_STRING DI
		ADD DI, 09H
		CL_STRING DI
		RET

;*****************************************************************************************************************************************************
;*															SECCION DE INTEGRAR      																 *
;*****************************************************************************************************************************************************	
	OP_INTEGRAR:
		CALL CLS
		IMPRIMECHAR 'I'
		IMPRIMECHAR 10
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL
;*****************************************************************************************************************************************************
;*															SECCION DE INGRESAR FUNCIONES	        												 *
;*****************************************************************************************************************************************************
	OP_IN_FUN:
		CALL CLS
		IMPRIMECHAR 'I'
		IMPRIMECHAR 'F'
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

;*****************************************************************************************************************************************************
;*															SECCION DE IMPRIMIR FUNCIONES 															 *
;*****************************************************************************************************************************************************
	OP_PR_FUN:
		CALL CLS
		IMPRIMECHAR 'P'
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

;*****************************************************************************************************************************************************
;*															SECCION DE GRAFICAR FUNCIONES															 *
;*****************************************************************************************************************************************************
	OP_GR_FUN:
		CALL CLS
		IMPRIMECHAR 'G'
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

;*****************************************************************************************************************************************************
;*															SECCION DE RESOLVER ECUACION															 *
;*****************************************************************************************************************************************************
	OP_RE_FUN:
		CALL CLS
		IMPRIMECHAR 'R'
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

;*****************************************************************************************************************************************************
;*															SECCION DE REPORTES															             *
;*****************************************************************************************************************************************************
	OP_REP_FUN:
		CALL CLS
		IMPRIMECHAR 'R'
		IMPRIMECHAR 'P'
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

;*****************************************************************************************************************************************************
;*															SECCION DE SUBRUTINAS																	 *
;*****************************************************************************************************************************************************
	;--------------------------------------
	; FUNCIONES DE ANALISIS DE TERMINOS
	;--------------------------------------
	EVL_TERM:
		CMP byte[BX], '$'
		JE ES_FIN
		CMP byte[BX], '+'
		JE ES_NUM
		CMP byte[BX], '-'
		JE ES_NUM
		;-----------------
		CMP byte[BX], '0'
		JL SIG_TERM
		CMP byte[BX], '9'
		JG SIG_TERM
		JMP ES_NUM
		;-----------------
		SIG_TERM:
		CMP byte[BX], 'A'
		JL SIG_TERM1
		CMP byte[BX], 'Z'
		JG SIG_TERM1
		JMP ES_VAR
		;-----------------
		SIG_TERM1:
		CMP byte[BX], '^'
		JE ES_EXP
		;-----------------
		JMP ES_VAR


	ES_EXP:
		MOV byte[tipo_term], 02h
		INC BX
		JMP ES_FIN

	ES_NUM:
		MOV byte[tipo_term], 00h
		INC BX
		JMP EVL_TERM

	ES_VAR:
		MOV byte[tipo_term], 01h
		INC BX
		JMP EVL_TERM

	ES_FIN:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH SI
		PUSH DI
		;CALL LIMPIAR_FUN
		POP DI
		POP SI
		POP CX
		POP AX
		POP BX
		RET


	OBT_NUM:
		CMP byte[BX], '$'					; ES SIGNO DE DOLAR?
		JE OBT_NUM_FIN
		CMP byte[BX], '0' 					; ES MENOR A 0?
		JL OBT_NUM_FIN
		CMP byte[BX], '9'					; ES MAYOR A 9?
		JG OBT_NUM_FIN
		MOV AL, byte[BX] 					; COPIO EL CARACTER
		MOV byte[SI], AL 					; LO ALMACENO EN LA POSICION
		INC BX 								; BX++
		INC SI 								; SI++
		JMP OBT_NUM 						; DE NUEVO SALTO
		OBT_NUM_FIN:
			RET

	OBT_EXP:
		CMP byte[BX], '^'					; SI ES DIFERENTE AL SOMBRERITO?
		JE OBTE_EXP_FIN
		INC BX
		JMP OBT_EXP
		OBTE_EXP_FIN:
			INC BX
			MOV AL, byte[BX]				; ME MUEVO UNA POSICION MAS
			MOV byte[SI], AL 				; GUARDO EL EXPONENTE EN AL
			RET
	
	;--------------------------------------
	; IMPRIME FUNCION - DERIVADA - INTEGRAL
	;--------------------------------------
	IMPRIME_FUNCION:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		MOV SI, funcion
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		IMPRIMECHAR 10
		;------
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	IMPRIME_DERIVADA:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		MOV SI, derivada
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		IMPRIMECHAR 10
		;------
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET
	;--------------------------------------
	; OBTIENE UN CARACTER, SALIDA EN AL
	;--------------------------------------
	GETCHAR:
		MOV AH, 1
		INT 21H
		RET

	;--------------------------------------
	; EL ANALOG AL SYSTEM PAUSE
	;--------------------------------------
	SYSPAUSE:
		PRINTSTRING pausemens
		MOV AH, 7
		INT 21H
		RET

	;--------------------------------------
	; LIMPIA LA PANTALLA
	;--------------------------------------
	CLS:
		MOV AH, 00H
		MOV AL, 02H
		INT 10h
		RET

	;--------------------------------------
	; INGRESA UN STRING HASTA SALTO DE LINEA
	; BX SE DEBE DE PONER LA DIRECCIN DE LA CADENA
	; Y DEBE HACERSE UN XOR A LOS REGISTROS
	;--------------------------------------
	INPUT_STRING:
		INSLOOP:
			CALL GETCHAR
			CMP AL, 13
			JE ENDINS
			MOV byte[BX], AL
			INC BX
			JMP INSLOOP
		ENDINS:	
		XOR BX, BX
		XOR DX, DX
		RET

	;-------------------------------------
	; SUBRUTINA PARA LIMPIAR UNA CADENA
	; COLOCO EN BX LA CADENA A LIMPIAR
	; HAGO XOR EN BX Y DX
	;--------------------------------------
	CLEAN_STRING:
		CLEANS: 					
			MOV DL, byte[BX]		; CAPTURO EL CARACTER QUE ESTOY RECORRIENDO
			CMP DL, '$' 			; COMPARO SI ES UN $
			JE ENDCLEANS 			; SI LO ES, YA TERMINE DE RECORRER LA CADENA
			MOV byte[BX], '$' 		; DE NO SERLO MUEVO A ESA POSICION DE MEMORIA UN $
			INC BX 					; INCREMENTO BX
			JMP CLEANS 				; Y VUELVO A EMPEZAR EL CICLO
		ENDCLEANS:					
			XOR BX, BX					; LIMPIO BX
			XOR DX, DX 					; LIMPIO DX
			RET

	;--------------------------------------
	; SUBRUTINA DE COMPARACION DE DOS STRINGS
	;--------------------------------------
	COMPARA_STRING:
			MOV DL, byte[BX]									; TOMANDO DE STRING 1
			MOV AL, byte[SI] 									; TOMANDO DE STRING 2
			CMP DL, AL 											; SON AMBOS IGUALES?
			JE TERM1 											; SI SON IGUALES, VA A PROBAR SI YA FINALIZO LA CADENA
			JMP TERM2 											; EN CASO DE QUE NO.. ESTE TERMINA
		TERM1:
			CMP DL, '$' 										; COMPARA SI YA TERMINO EL $
			JE END_COMP 										; TERMINA LA COMPARACION
			INC BX 												; SINO... BX++
			INC SI 												; SINO... SI++
			JMP COMPARA_STRING 									; VUELVE A EMPEZAR
		TERM2: 										
			MOV byte[igualdad], 0								; MUEVO A IGUALDAD 0 PARA INDICAR QUE NO LO SON
			JMP END_COMP 										; SALTO AL TERMINAR LA COMPARACION
		END_COMP:
			RET 		

	;--------------------------------------
	; CONTAR CARACTERES DEL STRING
	;--------------------------------------
	COUNT_CHAR:
		XOR DX, DX
		XOR CX, CX
		MOV CL, 00H
		LOOP_C:
			MOV DL, byte[BX]
			CMP DL, '$'
			JE END_C
			INC CL
			INC BX
			JMP LOOP_C
		END_C:
			RET

	;--------------------------------------
	; PARA CONVERTIR UN NUMERO A CHAR
	;--------------------------------------
	DEC_TO_CHAR:
		LOOPCHAR1:
			MOV CX, 00H 					; MUEVO EL CONTADOR DE 16BITS
			MOV DH, 00H
			MOV DL, 0AH 					; MUEVO EL 10 EL REGISTRO DL
			;-DIVISION
			LOOPCHAR2:
				CMP AX, DX 					; IF (AX < DL)
				JL ENDLOOPC2
				SUB AX, DX 					; AX = AX - DL
				INC CX
				JMP LOOPCHAR2
			ENDLOOPC2:
			;---------
			ADD AX, 030H 					; LE SUMO 30
			MOV byte[BX], AL 				; MUEVO EL RESIDUO
			MOV AX, CX 						; MUEVO EL COCIENTE PARA LA SIGUIENTE DIVISION
			CMP AX, 00H 					; ES EL COCIENTE 0 ?
			JE ENDLOOP1         			; SI LO ES, TERMINA...
			INC BX
			JMP LOOPCHAR1 					; SI NO PUES ENTONCES CONTINUA
		ENDLOOP1:
			INC BX
			MOV byte[BX], '$'
			XOR BX, BX
			RET

	MOSTRARRESP1:
		MOV CX , '$'			; MI SIGNO DE FINALIZACION
		PUSH CX 				; METO "$"
		LOOPMOS1:
			XOR AL, AL		 	; LIMPIO AL
			MOV AL, byte[BX]    ; MUEVO EL CARACTER AL
			CMP AL, '$'			; ES SIMBOLO DE DOLAR?
			JE ENDMOS1 			; TERMINA
		MUESTRA1:
			XOR AH, AH 			; LIMPIO LOS REGISTRO AH
			XOR DX, DX			; LIMPIO DX PARA USARLOS
			;IMPRIMECHAR AL 		; LO ENVIO DE PARAMETRO
			MOV CX, AX			; MUEVO LO QUE TRAE AL
			PUSH CX				; VUELVO A PUSHEAR
			INC BX				; INCREMENTO BX
			JMP LOOPMOS1
		ENDMOS1:
			CALL MOSTRARAUX1
			RET

	MOSTRARAUX1:
		;XOR CX, CX
		POP CX
		LOOPAUX1:
			XOR CX, CX
			POP CX
			CMP CL, '$'
			JE ENDAUX1
			;IMPRIMECHAR CL
			;===============
			PUSH BX
			PUSH AX
			PUSH CX 
			PUSH DX
			;=========
			;MOV byte[charaux], CL 
			;write_in_file [repHandle], 01H, charaux
			MOV byte[SI], CL
			INC SI 
			;=========
			POP DX 
			POP CX 
			POP AX
			POP BX
			;=============== 
			JMP LOOPAUX1
		ENDAUX1:
			RET
	; SALIDA DEL PROGRAMA
	;--------------------------------------
	EXIT:
		CALL CLS
		PRINTSTRING mensal
		MOV AH, 04CH
		INT 21H
