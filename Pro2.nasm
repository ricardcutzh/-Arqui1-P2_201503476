;*****************************************************************************************************************************************************
;*															SECCION DE BSS																			 *
;*****************************************************************************************************************************************************
section .bss
memhandle  resb 2
pathHandle resb 2
rep_e_hand resb 2
rep_evl_handle   resb 2
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
	PUSH DX

	MOV DX, %1		; COLOCO EL MENSAJE A IMPRIMIR
	MOV AH, 9 	 	; MUEVO 9 PARA LA IMPRIMIR EN PANTALLA
	INT 21H			; LLAMADA AL A INTERRUPCION 21H

	POP DX
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

	JC ERROR_FILE   		    ; SI HUBO UN ERROR....

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
	
	JC ERROR_FILE 	

	MOV %3, AX 					; PONGO EL NUMERO DE CARACTERES LEIDOS
%endmacro
%macro write_in_file 3 			; P1: HANDLE, P2: # BYTES A ESCRIBIR, P3: BUFFER
	PUSH AX
	PUSH CX
	PUSH BX
	PUSH DX
	XOR BX, BX
	XOR CX, CX
	XOR AX, AX
	XOR DX, DX

	MOV AH, 40H 				; FUNCION PARA ESCRITURA EN UN ARCHIVO					
	MOV BX, %1 					; COLOCO EL HANDLER EN BX
	MOV CX, %2 					; NUMERO DE BYTES A ESCRIBIR
	MOV DX, %3 					; EL BUFFER DE DONDE SE TOMARAN LOS CARACTERES
	INT 21H 					; LLAMADA A LA INTERRUPCION 21

	POP DX 
	POP BX
	POP CX
	POP AX
%endmacro
%macro create_file 2 			; P1: NOMBRE DEL ARCHIVO, P2: LUGAR DONDE SE VA A GUARDAR EL HANDLE DEL ARCHIVO
	MOV AH, 3CH 				; FUNCION PARA CREAR UN NUEVO ARCHIVO
	MOV DX, %1 					; NOMBRE DEL ARCHIVO A CREAR 
	MOV CX, 00H                 ; CREACION DE UN ARCHIVO NORMAL
	INT 21H

	JC ERROR_FILE 

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
%macro COUNT2 2
	PUSH BX
	PUSH CX
	PUSH AX
	PUSH DX
	XOR BX, BX
	MOV BX, %1
	CALL COUNT_CHAR
	XOR CH, CH
	MOV %2, CX
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
%macro ANALIZER 1 				; P1: LA DIRECCION DE MEMORIA DE LA CADENA A ANALIZAR
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH AX
	PUSH SI
	;------------------------
	CALL LIMPIAR_FUN
	XOR DI, DI
	MOV BX, %1
	MOV CX, 00H
	MOV SI, funcion
	MOV DI, funcion
	; AQUI METO EL PRIMER SIGNO
	MOV AL, byte[BX]
	MOV byte[SI], AL
	INC SI
	INC BX
	; AQUI LLAMO A LA FUNCION QUE ANALIZA
	CALL ANALIZAR2
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
	PUSH DI
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
	POP DI
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
	XOR AX, AX 					; LIMPIO EL REGISTRO
	MOV AL, 09H 				; MUEVO EL 9 PARA PODER MOVERME
	MOV CL, %2 					; MUEVO EL INDICE INDICADO A CL
	MUL CL 						; MULTIPLICO AX * CL
	ADD BX, AX 					; SUMO BX + AX
	INC BX 						; ME MUEVO DONDE EMPIEZA EL NUMERO
	MOV SI, vari 				; MUEVO EL PUNTERO SI PARA PODER APUNTAR A LA POSICION DE MEMORIA DE VARI
	CALL OBT_VAR 				; SALTO AL LOOP PARA OBTENER LA VARIABLE
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
	PUSH DI
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
	POP DI
	POP DX
	POP SI
	POP CX
	POP AX
	POP BX
%endmacro
%macro GET_EXP 2				; P1: CADENA, P2: INDICE
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
	INC BX 						; INCREMENTO BX
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
	PUSH DI
	;--------
	XOR AX, AX 
	XOR DX, DX
	XOR CX, CX
	XOR BX, BX
	MOV AX, word[%1] 						; PONIENDO LA VARIABLE QUE ALMACENA EL NUMERO Y QUE VOY A COMVENRTIR
	MOV BX, %2 								; LA DIRECCION DE LA CADENA
	CALL DEC_TO_CHAR
	;--------
	POP DI
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
%macro GUARDA_FUN 1  			; P1: DIRECCION DE LA FUNCION QUE VOY A ESCRIBIR, P2: NOMBRE DEL ARCHIVO DONDE LO VOY A HACER
	PUSH BX
	PUSH CX
	PUSH DX 
	PUSH AX
	PUSH SI
	PUSH DI
	;***************
	MOV SI, %1
	CALL ESCRIBE_F
	;***************
	POP DI
	POP SI
	POP AX 
	POP DX
	POP CX
	POP BX 
%endmacro
%macro A_NEGATIVO 1 			; P1: VARIABLE QUE QUIERO PASAR A NEGATIVO
	PUSH AX 
	XOR AL, AL 		; LIMPIO EL REGISTRO
	MOV AL, byte[%1]; MUEVO LA VARIABLE AL REGISTRO 
	NOT AL 			; APLICO NOT
	ADD AL, 01H		; LE SUMO 1 A AL	
	MOV [%1], AL 	; DEVUELVO AL PARAMETRO 1 A AL
	POP AX
%endmacro
%macro POW 3  					; P1: NUMERO A ELEVAR, P2: EXPONENTE, P3: LUGAR DONDE SE ALMACENA LA RESPUESTA (WORD)
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	;---------
	XOR BX, BX
	XOR AX, AX
	XOR DX, DX
	XOR CX, CX 
	MOV AX, %1 					; COLOCO EL NUMERO A ELEVAR EN AX
	MOV BX, %1
	MOV CL, %2 					; COLOCO EL EXPONENTE EN CX
	CALL DO_POW 				; LLAMO A QUE HAGA EL ELEVADO
	MOV %3, AX 					; MUEVO EL RESULTADO A LA VARIABLE
	;---------
	POP DX
	POP CX
	POP BX
	POP AX
%endmacro
%macro A_NEGATIVO_W 1 			; P1: VARIABLE QUE QUIERO NEGATIVA
	PUSH AX
	XOR AX, AX
	MOV AX, word[%1]			; MUEVO EL NUMERO EN LA VARIABLES
	NOT AX 						; NUEGO AX
	ADD AX, 01H 				; LE SUMO 1
	MOV word[%1], AX 			; MUEVO AX A LA VRIABLE NUEVAMENTE		
	POP AX 
%endmacro
%macro DRAW_CHAR 4 								; P1: CURSOR ROW, P2: CURSOR COLUM, P3:CHAR, P4:COLOR
	PUSH BX
	PUSH AX
	PUSH DX
	PUSH CX
	;--------------------------------------------
	MOV AH, 02H 								; FUNCION A LLAMAR PARA POSICIONAR EL CURSOR
	MOV BH, 00H 								; PAGINA
	MOV DH, %1 									; POSICIONO FILA
	MOV DL, %2 									; POSICIONO COLUMNA
	INT 10H
	; ESCRIBIENDO EL CHAR 
	MOV AH, 09H 								; FUNCION PARA ESCRIBIR EL CARACTER
	MOV AL, %3 									; CARACTER A ESCRIBIR
	MOV BH, 00H 								; PAGINA A POSCICIONAR
	MOV BL, %4 									; COLOR 
	MOV CX, 01H 								; NUMERO DE CARACTER A ESCRIBIR
	INT 10H
	;-------------------------------------------
	POP CX
	POP DX
	POP AX
	POP BX
%endmacro
%macro DRAW_PIX 3 				; P1: ROW, P2: COLUMN, P3: COLOR 
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	;------
	MOV AH, 00CH
	MOV AL, %3
	MOV BH, 00H
	MOV CX, %2
	MOV DX, %1
	INT 10H
	;------
	POP DX
	POP CX
	POP BX
	POP AX
%endmacro
%macro DRAW_H_LINE 4 							; P1: ROW, P2: COLUM, P3: MAX, P4: COLOR 
	PUSH BX
	PUSH SI
	PUSH CX
	PUSH DX
	PUSH AX 
	MOV word[row], %1
	MOV word[colum], %2
	MOV word[max], %3
	MOV word[color], %4
	MOV CX, word[colum]
	MOV DX, word[row]
	CALL H_LINE
	POP AX
	POP DX
	POP CX
	POP SI
	POP BX
%endmacro
%macro DRAW_V_LINE 4 							; P1: ROW, P2: COLUM, P3: MAX, P4: COLOR
	PUSH BX
	PUSH SI
	PUSH CX
	PUSH DX
	PUSH AX 
	MOV word[row], %1
	MOV word[colum], %2
	MOV word[max], %3
	MOV word[color], %4
	MOV CX, word[colum]
	MOV DX, word[row]
	CALL V_LINE
	POP AX
	POP DX
	POP CX
	POP SI
	POP BX
%endmacro
%macro READ_FUN 1 				; P1: NUMERO DE FUNCION QUE DESEO LEER, COMIENZA CON LA 1 -- 15, DEVUELVE EN auxiliar
	PUSH BX
	PUSH CX
	PUSH SI
	PUSH AX
	PUSH DX
	;------
	MOV byte[indice], %1
	CALL SEARCH_FUN
	;------
	POP DX
	POP AX
	POP SI
	POP CX
	POP BX
%endmacro
;=====================================================================================================================================================
pausemens           db 10,"** PRESS ANY KEY TO CONTINUE.... ***$"
errorMSG 			db 10,"** ERROR PARA ABRIR UN ARCHIVO *****$"
igualdad            db  0 										; BANDERA QUE VA A USARSE PARA SABER SI DOS STRINGS SON IGUALES
mensal              db 10,"********** SALIENDO ..... **********",10,13,"$"
correcto 			db "********* FUNCION INGRESADA Y GUARDADA CORRECTAMENTE ********$"
memoria 			dw "mt.txt$"
reporte_equ 		dw "re.txt$"
reporte_evl 		dw "evl.txt$"
lenght 				db 00h 
es_imp 				db 00h
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
					db "*  9) CONFIGURACION                                     *",10,13,
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


separador           db "*********************************************************",'$'
resDer1 			db " FUNCION INGRESADA >> $"
resDer2 			db " DERIVADA DE FUNCION >> $"
resInt 				db " INTEGRAL DE FUNCION >> $"
;----------------------------------------------------------------------------------------------------
int_menu 			db "*********************************************************",10,13,
					db "*                 INTEGRAR UNA FUNCION                  *",10,13,
					db "*********************************************************",10,13,
					db "* INGRESE LA FUNCION:                                   *",10,13,
					db "*********************************************************",10,13,
					db " >> $"

ing_menu            db "*********************************************************",10,13,
					db "*                 INGRESAR UNA FUNCION                  *",10,13,
					db "*********************************************************",10,13,
					db "* INGRESE LA FUNCION:                                   *",10,13,
					db "*********************************************************",10,13,
					db " >> $"

ruta_menu 			db "*********************************************************",10,13,
					db "*             INGRESAR LA RUTA DE ARCHIVO               *",10,13,
					db "*********************************************************",10,13,
					db "* RUTA DEL ARCHIVO:                                     *",10,13,
					db "*********************************************************",10,13,
					db " >> $"		

resol_menu 			db "*********************************************************",10,13,
					db "*         INGRESAR FUNCION DE 2DO GRADO                 *",10,13,
					db "*********************************************************",10,13,
					db "* INGRESAR FUNCION:                                     *",10,13,
					db "*********************************************************",10,13,
					db " >> $"		
;----------------------------------------------------------------------------------------------------
funcion 			db "$$$$$$$$$" 													; ALMACENA
					db "$$$$$$$$$" 													; TERMINOS DE 
					db "$$$$$$$$$"													; CADA
					db "$$$$$$$$$"													; FUNCION
					db "$$$$$$$$$"

derivada 			db "$$$$$$$$$"													; ALMACENA
					db "$$$$$$$$$" 													; TERMINOS 
					db "$$$$$$$$$"													; DE LA FUNCION
					db "$$$$$$$$$"													; DERIVADA
					db "$$$$$$$$$"

integral 			db "$$$$$$$$$" 													; ALMACENA LA INTEGRAL DE LA FUNCION
					db "$$$$$$$$$"
					db "$$$$$$$$$"
					db "$$$$$$$$$"
					db "$$$$$$$$$"

tipo_term 			db 0h

charAux 			db 00h

coef 	times 5     db "$" 															; ALMACENA EL COEFICIENTE DEL TERMINO A PROCESAR
expo 	times 3     db "$" 															; ALMACENA EL EXPONENETE DEL TERMIO A PROCESAR
vari    times 2 	db "$"

coef_num 			db 0h

tam 				db 0h

salida  times 7     db '$'

resul 				dw 0h

charArr 			db '$'

error 				db 00h

int_num 			db 00h

entero 				db 00H
decimal 			db 00h

contenido times 255 db '$'

contenido2 times 255 db '$'

auxiliar times 50   db '$'

contador 			db 00h
indice 				db 00h
;*****************************************************************************************************

;*****************************************************************************************************
menu_ing 			db "*********************************************************",10,13,
					db "*                 MENU PRINCIPAL CALCULADORA            *",10,13,
					db "*********************************************************",10,13,
					db "*  1) INGRESO DE FUNCION                                *",10,13,
					db "*  2) CARGA DE FUNCIONES                                *",10,13,
					db "*  3) SALIR A MENU PRINCIPAL                            *",10,13,
					db "*********************************************************",10,13,
					db "* >> $"
;-----------------------------------------------------------------------------------------------------
menu_print          db "*********************************************************",10,13,
					db "*                 FUNCIONES EN MEMORIA:                 *",10,13,
					db "*********************************************************",10,'$'
;-----------------------------------------------------------------------------------------------------
path 	 times 50   dw "$"
;-----------------------------------------------------------------------------------------------------
ban_grado 			db 00h
;-----------------------------------------------------------------------------------------------------
msg_mayor 			db 10,"***************** LA ECUACION NO ES DE 2do GRADO *****************",10,'$'
;-----------------------------------------------------------------------------------------------------
a 					dw 00H
b 					dw 00h
c 					dw 00h 		 ; ESTOS ALMACENAN EL VALOR DA A,B,C
s_a 				db 00h 
s_b 				db 00h
s_c 				db 00h       ; ESTOS ULTIMOS SE ENCARGAN DE VER QUE SIGNO TIENE CADA TERMINO
;-----------------------------------------------------------------------------------------------------
pow_resul 			dw 00h
aux_resul1 			dw 00h
aux_resul2 			dw 00h
aux_resul3 			dw 00h
;-----------------------------------------------------------------------------------------------------
msg_sol 			db " >> solucion : $"
;-----------------------------------------------------------------------------------------------------
menu_rep			db "*********************************************************",10,13,
					db "*                 MENU DE REPORTES                      *",10,13,
					db "*********************************************************",10,13,
					db "*  1) FUNCIONES EN SISTEMA                              *",10,13,
					db "*  2) ECUACIONES INGRESADAS                             *",10,13,
					db "*  3) SALIR A MENU PRINCIPAL                            *",10,13,
					db "*********************************************************",10,13,
					db "* >> $"
;-----------------------------------------------------------------------------------------------------
encabezado_rep  	db "                        REPORTE"
rep_eq_fun 			db "| Funcion: "
rep_eq_sol 			db " | solucion: "
len 				db 00h
;-----------------------------------------------------------------------------------------------------
mes_rep 			db "*********************************************************",10,13,
					db "*                 REPORTE GENERADO                      *",10,13,
					db "*********************************************************",10,13,'$'
;=============================
; VARIABLES GRAFICO
;==============================
row  				dw 00H
colum 				dw 00H
max 				dw 00H
color 				db 00H
;--------------------------
prueba 				db "+2.5x^2+4x-8$$$$$$$$$$"
pruebas times 50    db "$"
;---------------------------
xcord 				dw 00H
ycord 				dw 00H
;---------------------------
limite_menor 		dw -06H
limite_superior     dw 06H
espaciado 			db 00h
;---------------------------
menu_config 		db "*********************************************************",10,13,
					db "*                 MENU CONFIGURACION                    *",10,13,
					db "*********************************************************",10,13,
					db "*  1) LIMITE SUPERIOR                                   *",10,13,
					db "*  2) LIMITE INFERIOR                                   *",10,13,
					db "*  3) ESPACIADO DE X                                    *",10,13,
					db "*  4) VER CONFIGURACIONES                               *",10,13,
					db "*  5) SALIR                                             *",10,13,
					db "*********************************************************",10,13,
					db "* >> $"

conf_sup 			db " LIMITE SUPERIOR >> $"
conf_inf 			db " LIMITE INFERIOR >> -$"

guardado 			db " CONFIGURACION GUARDADA...$"

ycordaux 			dw 00H
xcordaux 			dw 00h
;*****************************************************************************************************************************************************
;*															SECCION DE TEXT																			 *
;*****************************************************************************************************************************************************
section .text

	global MAIN

	MAIN:
		ORG 100H
		;POW 03H, 02H, word[pow_resul]
		;NUM_TO_CHAR pow_resul, charArr 								; CONVIERTO EL NUMERO A ARREGLO
		;NUM_SALIDA charArr, salida 								; CONVIERTO EL ARREGLO EN STRING DE SALIDA
		;PRINTSTRING salida
		;CALL SYSPAUSE
		;CALL EXIT
		CALL REP_EQ
		CALL RESET_MEM
		JMP MENU_PRINCIPAL

	MENU_PRINCIPAL:
		CALL LIMPIAR_FUN
		CALL LIMPIAR_DERIVADA
		CALL LIMPIAR_INT
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
		CMP AL, '9'
		JE CONFIG
		JMP MENU_PRINCIPAL 										; CUALQUIER OTRA OPCIONE VUELVE A PEDIR LA ENTRADA
		
	SALIR_PROGRAMA:
		CALL EXIT

	W_FUN:
		CL_STRING contenido
		;*******************************************************************
		; AQUI HARE EL PROCESO DE ESCRIBIR LAS FUNCIONES
		;*******************************************************************
		;-- ABRIR:
			open_file memoria, [memhandle]
		;-- LEER:
			read_file [memhandle], contenido, [tam]
			;PRINTSTRING contenido
		;-- CERRAR:
			close_file [memhandle]
		;-- CREAR NUEVO:
			create_file memoria, [memhandle]
		;-- ESCRIBE LA FUNCION INGRESADA
			GUARDA_FUN funcion
			MOV byte[charAux], ';'
			write_in_file [memhandle], 01h, charAux
			COUNT contenido, [tam]
			write_in_file [memhandle], [tam], contenido
			close_file [memhandle]
			RET

	RESET_MEM:
		create_file memoria, [memhandle]
		close_file [memhandle]
		RET

;*****************************************************************************************************************************************************
;*															SECCION DE DERIVAR   																	 *
;*****************************************************************************************************************************************************
	OP_DERIVAR:
		MOV byte[error], 00h
		CL_STRING entrada 										; LIMPIA LA ENTRADA
		CALL CLS 												; LIMPIA LA PANTALLA
		PRINTSTRING der_menu 									; IMPRIME EL MENU
		IN_STRING entrada 										; OBTENGO LA ENTRADA DEL TECLADO
		ANALIZAR entrada 										; ANALIZA LA ENTRADA PARA PODER  TOMAR LOS TERMINOS DE LA FUNCION
		CMP byte[error], 01h
		JE ERROR_ANALIZAR
		;*-------------------------------------------------------
		; LLAMADA ALA DERIVADA
		CALL DERIVA_FUNCION
		;*------------------------------------------------------- 
		CALL W_DER
		CALL W_FUN
		CALL LIMPIAR_FUN
		CALL LIMPIAR_DERIVADA
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
			CMP CL, 04h											; EL CONTADOR ES MAYOR A 3?
			JG FIN 												; SI ES MAYOR ENTONCES TERMINA
			EVALUA_TERM funcion, CL 							; EVALULO LA POSICION CL DEL ARREGLO DE LA FUNCION
			CMP byte[tipo_term], 02h 							; SI TIENE EXPONENTE
			JE LLAMA_DE2
			CMP byte[tipo_term], 01h
			JE LLAMA_DE1
			CMP BYTE[tipo_term], 00h
			JE LLAMA_DE0
			JMP DER_VUELVE
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
				MOV byte[tipo_term], 000h
				JMP LOOP_DER
		;-------------
		FIN:
		PRINTSTRING separador
		IMPRIMECHAR 10 
		PRINTSTRING resDer1
		CALL IMPRIME_FUNCION
		IMPRIMECHAR 10
		PRINTSTRING resDer2
		CALL IMPRIME_DERIVADA
		IMPRIMECHAR 10
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
		;MOV byte[SI], '+' 										; MUEVO EL SIGNO MAS
		;INC SI
		;MOV byte[SI], '0'										; LE AGREGO EL 0 YA QUE ES LA DERIVADA DE UNA CONSTANTE
		;IMPRIMECHAR 10
		;PRINTSTRING mder0
		;IMPRIMECHAR 10
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
		CL_STRING coef
		PUSH BX
		GET_NUM BX, 0H
		POP BX
		MOV DL, byte[BX]
		MOV byte[SI], DL 										; PONGO EL SIGNO DE EL TERMINO
		INC SI 													; SI ++
		MOV DI, coef
		L_SAL1:
			CMP byte[DI], '$'								; ES EL SIGNO DE DDOLAR?
			JE L_SAL_FIN1
			MOV DL, byte[DI] 								; MUEVO EL CARACTER DE SALIDA
			MOV byte[SI], DL 								; PASO EL CARACTER A SI
			INC SI
			INC DI 											; INCREMENTO SI Y DL
			JMP L_SAL1
		L_SAL_FIN1:
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
		MOV word[resul], 00H
		MOV byte[tam], 00h
		CL_STRING charArr
		CL_STRING coef 											; LIMPIO EL COEFICIENTE
		CL_STRING expo 											; LIMPIO EL EXPONENTE
		CL_STRING salida
		CL_STRING vari
		GET_NUM BX, 0h 											; OBTENGO EL NUMERO
		GET_EXP BX, 0h 											; OBTENGO EL EXPONENTE
		GET_VAR BX, 0h
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
			SUB DL, 001H 										; LE RESTO 1 AL EXPONENTE
			ADD DL, 30H 										; LE SUMO 30 PARA CONVERTIRLO A SU EQUIVALENTE EN CARACTER
			MOV byte[expo], DL 									; LO GUARDO EN LA VARIABLE EXPONENTE
			;---------------------------------------------------
			; SACANDO LA DERIVADA DEL TERMINO
			;---------------------------------------------------
			PUSH DX
			PUSH BX
			PUSH SI
			PUSH DI
			XOR DL, DL
			MOV DL, byte[BX] 									; OBTENGO EL SIGNO
			MOV byte[SI], DL 									; PONGO EL SIGNO EN DERIVADA
			INC SI 
			;--------------
			; ESCIBE SALIDA
			;--------------
			MOV DI, salida
			L_SAL:
				CMP byte[DI], '$'								; ES EL SIGNO DE DDOLAR?
				JE L_SAL_FIN
				MOV DL, byte[DI] 								; MUEVO EL CARACTER DE SALIDA
				MOV byte[SI], DL 								; PASO EL CARACTER A SI
				INC SI
				INC DI 											; INCREMENTO SI Y DL
				JMP L_SAL
			L_SAL_FIN:
			MOV DL, byte[vari] 									; MUEVO LA VARIABLE A DL
			MOV byte[SI], DL 									; PONGO LA VARIABLE A SI
			INC SI 												; MUEVO SI
			MOV DL, '^'											; MUEVO EL SOMBRERITO A DL
			MOV byte[SI], DL 									; MUEVO EL SOMBRERO A DL
			INC SI 												; MUEVO SI
			MOV DL, byte[expo]									; MUEVO EL NUEVO EXPONENTE
			MOV byte[SI], DL 									; LO PONGO EN SI
			POP DI
			POP SI
			POP BX
			POP DX
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	W_DER:
		CL_STRING contenido
		;*******************************************************************
		; AQUI HARE EL PROCESO DE ESCRIBIR LAS FUNCIONES
		;*******************************************************************
		;-- ABRIR:
			open_file memoria, [memhandle]
		;-- LEER:
			read_file [memhandle], contenido, [tam]
			;PRINTSTRING contenido
		;-- CERRAR:
			close_file [memhandle]
		;-- CREAR NUEVO:
			create_file memoria, [memhandle]
		;-- ESCRIBE LA FUNCION INGRESADA
			GUARDA_FUN derivada
			MOV byte[charAux], ';'
			write_in_file [memhandle], 01h, charAux
			COUNT contenido, [tam]
			write_in_file [memhandle], [tam], contenido
			close_file [memhandle]
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
		MOV byte[error], 01h
		;CALL CLS
		;IMPRIMECHAR 10
		;PRINTSTRING error_analisis
		;IMPRIMECHAR 10
		;CALL SYSPAUSE
		RET

	ACEPTAR:
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
		ADD DI, 09H
		CL_STRING DI
		RET

	LIMPIAR_DERIVADA:
		MOV DI, derivada
		CL_STRING DI
		ADD DI, 09H
		CL_STRING DI
		ADD DI, 09H
		CL_STRING DI
		ADD DI, 09H
		CL_STRING DI
		ADD DI, 09H
		CL_STRING DI
		RET

	LIMPIAR_INT:
		MOV DI, integral
		CL_STRING DI
		ADD DI, 09H
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
		MOV byte[vari], 'x'										; EN CASO DE QUE VENGA LA INTEGRAL DE UNA CONSTANTE
		MOV byte[error], 00h
		CL_STRING entrada 										; LIMPIO LA ENTRADA
		CALL CLS 												; LIMPIO LA PANTALLA
		PRINTSTRING int_menu	 								; IMPRIMO EL MENU DE INEGRAR UNA FUNCION 
		IN_STRING entrada 										; INGRESO LA FUNCION
		ANALIZAR entrada 										; ANALIZAR LA ENTRADA
		CMP byte[error], 01h 									; HUBO ERROR EN ANALISIS?
		JE ERROR_ANALIZAR
		;--------------------------------------------------------
		; LLAMADA A LA INTEGRAL DE LA FUNCION
		;--------------------------------------------------------
		CALL INTEGRA_FUNCION
		PRINTSTRING separador
		IMPRIMECHAR 10 
		PRINTSTRING resDer1
		CALL IMPRIME_FUNCION
		IMPRIMECHAR 10 
		PRINTSTRING resInt
		CALL IMPRIME_INTEGRAL
		IMPRIMECHAR '+'
		IMPRIMECHAR 'C'
		IMPRIMECHAR 10
		;--------------------------------------------------------
		CALL W_INTE
		CALL W_FUN
		CALL LIMPIAR_FUN
		CALL LIMPIAR_INT
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

	INTEGRA_FUNCION:
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH AX
		PUSH SI
		PUSH DI
		;----------------------
		; INICIA LA DERIVACION
		;----------------------
		MOV BX, funcion
		MOV CX, 00H
		MOV SI, integral
		LOOP_INT:
			CMP CL, 04H 										; CONTADOR PARA PODER LLEVAR EL CONTROL
			JG FIN_INT
			EVALUA_TERM funcion, CL 							; EVALUA EL TERMINO
			CMP byte[tipo_term], 02H							; EVALUO EL TERMINO
			JE LLAMA_INT2
			CMP byte[tipo_term], 01H 							; EVALUO EL TERMINO
			JE LLAMA_INT1
			CMP byte[tipo_term], 00H 							; EVALUO EL TERMINO
			JE LLAMA_INT0
			JMP INT_VUELVE
			LLAMA_INT0:
				CALL INTEGRA0
				JMP INT_VUELVE
			LLAMA_INT1:
				CALL INTEGRA1
				JMP INT_VUELVE
			LLAMA_INT2:
				CALL INTEGRA2
				JMP INT_VUELVE
			INT_VUELVE:
				ADD BX, 09H
				ADD SI, 09H
				INC CX
				MOV byte[tipo_term], 000h
				JMP LOOP_INT
		;----------------------
		FIN_INT:
		PRINTSTRING separador
		IMPRIMECHAR 10
		POP DI
		POP SI
		POP AX
		POP DX
		POP CX
		POP BX
		RET

	INTEGRA0:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		CL_STRING coef 											; LIMPIO EL COEFICIENTE
		GET_NUM BX, 00H 										; OBTENER EL COEFICIENTE
		MOV DL, byte[BX] 										; OBTENGO EL SIGNO DE EL TERMINO
		MOV byte[SI], DL 										; SI ++
		INC SI
		MOV DI, coef 											; MUEVO EL COEFICIENTE
		I_SAL:
			CMP byte[DI], '$'									; LLEGUE AL SIGNO DE DOLAR?
			JE I_SAL_FIN
			MOV DL, byte[DI]									; SI NO ENTONCES EMPIEZO A COLOLAR EL COEFICIENTE
			MOV byte[SI], DL 									; PONGO EL CARACTER
			INC SI
			INC DI
			JMP I_SAL
		I_SAL_FIN:
		;------
		MOV DL, byte[vari]										; MUEVO LA VARIABLE
		MOV byte[SI], DL 										; LA COLOCO EN LA SALIDA
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	INTEGRA1:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		CL_STRING salida
		CL_STRING charArr
		CL_STRING coef 											; LIMPIO EL COEFICIENTE
		CL_STRING vari 											; LIMPIO LA VARIABLE
		GET_NUM BX, 00H 										; OBTENGO EL COEFICIENTE
		GET_VAR BX, 00H 										; OBTENGO LA VARIABLE
		;----------------
		; COLOCANDO SIGNO
		;----------------
		MOV DL, byte[BX]										; GUARDO EL SIGNO DE LA EXPRESION
		MOV byte[SI], DL 										; COLOCO EL SIGNO DE LA EXPRESION
		INC SI 													; ME MUEVO A LA SIGUIENTE POSICION DE LA SALIDA DE LA INTEGRAL
		;----DIVISION-------
		COUNT coef, [tam]										; VER EL TAMANO DEL COEFICIENTE
		CMP byte[tam], 01h 										; ES 1?
		JE CONV_1
		CMP byte[tam], 02h										; ES 2?
		JE CONV_2
		CONV_2:
			TO_NUM2 coef, byte[coef_num]						; CONVIERTO EL COEFICIENTE EN NUMERO HEXA
			JMP CONT_INT
		CONV_1:
			TO_NUM1 coef, byte[coef_num]						; CONVIERTO EL NUMERO
			JMP CONT_INT
		CONT_INT:
		XOR AX, AX
		MOV AL, byte[coef_num]									; MUEVO EL NUMERO PARA PODER HACER LA DIVISION CORRESPONDIENTE
		MOV CL, 02h 											; MUEVO EL 2 PARA PODER REALIZAR LA DIVISION
		DIV CL 													; HAGO LA DIVISION
		MOV byte[resul], AL 									; MUEVO EL COCIENTE A LA PARTE ENTERA
		MOV byte[entero], AH 									; GUARDO AH
		NUM_TO_CHAR resul, charArr 								; CONVIERTO EL NUMERO A ARREGLO
		NUM_SALIDA charArr, salida 								; CONVIERTO EL ARREGLO EN STRING DE SALIDA
		;-------------------------
		; ESCRIBO LA SALIDA
		MOV DI, salida
		W_SAL1:
			CMP byte[DI], '$'									; ES UN SIGNO DE DOLAR?
			JE W_SAL1_FIN
			MOV DL, byte[DI]									; MUEVO EL CARACTER PARA PODER ESCRIBIRLO
			MOV byte[SI], DL 									; ESCRIBO EL CARACTER
			INC SI 												; SI ++
			INC DI 												; DI ++
			JMP W_SAL1
		W_SAL1_FIN:
		;-------------------------
		CMP byte[entero], 00H 									; ES EL REMAINDER 0?
		JE TERM_INT
		CL_STRING charArr										; LIMPIO EL ARREGLO DE CHAR 
		CL_STRING salida 										; LIMPIO LA SALIDA
		MOV AL, AH 												; MUEVO EL RESIDUO A AL
		XOR AH, AH 												; LIMPIO A AH
		MOV CL, 0AH 											; MUEVO EL 10 A CL
		MUL CL 													; AX * 10 
		MOV CL, 02H 											; MUEVO 2 A CL 
		DIV CL 													; DIVIDO AX / 2
		MOV byte[resul], AL 									; MUEVO EL RESULTADO A DECIMAL
		NUM_TO_CHAR resul, charArr 								; CONVIERTO EL NUMERO A ARREGLO
		NUM_SALIDA charArr, salida 								; CONVIERTO EL ARREGLO EN STRING DE SALIDA
		;-------------------------
		; ESCRIBO . Y LA DIVISION 
		;--------------------------
		MOV byte[SI], '.'										; ESCRIBO EL PUNTO DECIMAL
		INC SI
		MOV DI, salida
		W_SAL2:
			CMP byte[DI], '$'									; ES UN SIGNO DE DOLAR?
			JE W_SAL2_FIN
			MOV DL, byte[DI]									; MUEVO EL CARACTER EN CUESTION
			MOV byte[SI], DL 									; ESCRIBO EL CARACTER
			INC SI
			INC DI
			JMP W_SAL2
		W_SAL2_FIN:
		;----FIN DIVISION-----------
		TERM_INT:
		MOV DL, byte[vari]										; MUEVO LA VARIABLE
		MOV byte[SI], DL 										; ESCRIBO LA VARIABLE
		INC SI
		MOV byte[SI], '^'										; MUEVO EL SOMBRERO Y LUEGO PONGO EL EXPONENTE
		INC SI
		MOV byte[SI], '2'										; PONGO EL EXPONENTE
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	INTEGRA2:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		CL_STRING vari 											; LIMPIO LA VARIABLE
		CL_STRING coef 											; LIMPIO EL COEFICIENTE
		CL_STRING expo 											; LIMPIO EL EXPONENTE
		GET_NUM BX, 00H 										; OBTENGO EL COEFICIENTE DEL TERMINO
		GET_VAR BX, 00H 										; OBTENGO LA VARIABLE DEL TERMINO
		GET_EXP BX, 00H 										; OBTENGO EL EXPONENTE DEL TERMINO
		ADD byte[expo], 01h 									; LE SUMO UNO AL EXPONENTE
		;*****************
		; COLOCANDO SIGNO
		;*****************
		MOV DL, byte[BX] 										; COLOCO EN DL EL SIGNO DEL TERMINO
		MOV byte[SI], DL  										; COLOCO EN SI LA PRIMERA POSICION EL SIGNO DEL TERMINO
		INC SI  												; INCREMENTO SI 
		;*****************
		COUNT coef, [tam]										; CUENTO EL NUMERO DE DIGITOS DEL COEFICIENTE
		CMP byte[tam], 01h 										; TIENE TAMANO 1
		JE UT1
		CMP byte[tam], 02h 										; TIENE TAMANO 2
		JE UT2
		UT2:	
			TO_NUM2 coef, byte[coef_num]
			JMP CONT_INT2
		UT1:
			TO_NUM1 coef, byte[coef_num]
			JMP CONT_INT2
		CONT_INT2:
		;*******************************************************
		; INICIO DE DIVISION
		;*******************************************************
		MOV DL, byte[expo]
		SUB DL, 30H
		XOR AX, AX
		MOV AL, byte[coef_num]									; MUEVO EL NUMERO PARA PODER HACER LA DIVISION CORRESPONDIENTE
		MOV CL, DL 												; MUEVO EL 2 PARA PODER REALIZAR LA DIVISION
		DIV CL 													; HAGO LA DIVISION
		MOV byte[resul], AL 									; MUEVO EL COCIENTE A LA PARTE ENTERA
		MOV byte[entero], AH 									; GUARDO AH
		NUM_TO_CHAR resul, charArr 								; CONVIERTO EL NUMERO A ARREGLO
		NUM_SALIDA charArr, salida 								; CONVIERTO EL ARREGLO EN STRING DE SALIDA
		;******************************************************
		; ESCRIBO LA SALIDA
		;******************************************************
		MOV DI, salida
		W_SAL3:
			CMP byte[DI], '$'									; ES SIGNO DE DOLDAR?
			JE W_SAL3_FIN
			MOV DL, byte[DI]									; MUEVO EL CARACTER
			MOV byte[SI], DL 									; GUARDO EN SI, LO QUE TIENE DL
			INC SI
			INC DI
			JMP W_SAL3
		W_SAL3_FIN:
		CMP byte[entero], 00h 									; ES CERO EL RESIDUO?
		JE TERM_INT2
		;******************************************************
		CL_STRING charArr
		CL_STRING salida
		MOV CH, byte[expo]
		SUB CH, 30H
		MOV AL, AH 												; MUEVO EL RESIDUO A AL
		XOR AH, AH 												; LIMPIO A AH
		MOV CL, 0AH 											; MUEVO EL 10 A CL
		MUL CL 													; AX * 10 
		MOV CL, CH 	 											; MUEVO CH QUE ES EL EXPONENTE A CL 
		DIV CL 													; DIVIDO AX / CH 
		MOV byte[resul], AL 									; MUEVO EL RESULTADO A DECIMAL
		NUM_TO_CHAR resul, charArr 								; CONVIERTO EL NUMERO A ARREGLO
		NUM_SALIDA charArr, salida 								; CONVIERTO EL ARREGLO EN STRING DE SALIDA
		;******************************************************
		; ESCRIBO EL . Y LA DIVISION
		;******************************************************
		MOV byte[SI], '.'										; ESCRIBO EL PUNTO
		INC SI
		MOV DI, salida
		;******************************************************
		W_SAL4:
			CMP byte[DI], '$'									; ES SIGNO DE DOLAR?
			JE W_SAL4_FIN
			MOV DL, byte[DI] 									; MUEVO LO QUE ESTA EN DI A DL
			MOV byte[SI], DL 									; ESCRIBO EL CARACTER 
			INC SI 
			INC DI
			JMP W_SAL4
		W_SAL4_FIN:
		;******************************************************
		; FIN DE LA DIVISION
		;******************************************************
		TERM_INT2:
		MOV DL, byte[vari] 										; MUEVO LA VARIABLE
		MOV byte[SI], DL 										; COPIO EL CARACTER A SI 
		INC SI 
		MOV byte[SI], '^'										; MUEVO EL SOMBRERITO
		INC SI
		MOV DL, byte[expo]
		MOV byte[SI], DL 
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	W_INTE:
		CL_STRING contenido
		;*******************************************************************
		; AQUI HARE EL PROCESO DE ESCRIBIR LAS FUNCIONES
		;*******************************************************************
		;-- ABRIR:
			open_file memoria, [memhandle]
		;-- LEER:
			read_file [memhandle], contenido, [tam]
			;PRINTSTRING contenido
		;-- CERRAR:
			close_file [memhandle]
		;-- CREAR NUEVO:
			create_file memoria, [memhandle]
		;-- ESCRIBE LA FUNCION INGRESADA
			GUARDA_FUN integral
			MOV byte[charAux], ';'
			write_in_file [memhandle], 01h, charAux
			COUNT contenido, [tam]
			write_in_file [memhandle], [tam], contenido
			close_file [memhandle]
			RET

;*****************************************************************************************************************************************************
;*															SECCION DE INGRESAR FUNCIONES	        												 *
;*****************************************************************************************************************************************************
	OP_IN_FUN:
		CALL CLS
		PRINTSTRING menu_ing
		CALL GETCHAR
		CMP AL, '1' 										; ES OPCION 1?
		JE INGRESO_MANUAL
		CMP AL, '3' 										; ES OPCION 3?
		JE MENU_PRINCIPAL
		CMP AL, '2' 										; ES OPCION 2?
		JE INGRESO_ARCHIVO
		JMP OP_IN_FUN

	INGRESO_MANUAL:
		CALL CLS
		CL_STRING entrada
		PRINTSTRING ing_menu
		IN_STRING entrada
		ANALIZAR entrada
		CMP byte[error], 01h
		JE OP_IN_FUN
		;*******************************************************************
		; AQUI HARE EL PROCESO DE ESCRIBIR LAS FUNCIONES
		;*******************************************************************
		;-- ABRIR:
			open_file memoria, [memhandle]
		;-- LEER:
			read_file [memhandle], contenido, [tam]
			;PRINTSTRING contenido
		;-- CERRAR:
			close_file [memhandle]
		;-- CREAR NUEVO:
			create_file memoria, [memhandle]
		;-- ESCRIBIR LA INGRESADA:
			COUNT entrada, [tam]
			write_in_file [memhandle], [tam], entrada
			MOV byte[charAux], ';'
			write_in_file [memhandle], 01h, charAux
			COUNT contenido, [tam]
			write_in_file [memhandle], [tam], contenido
			close_file [memhandle]
		;*******************************************************************
		IMPRIMECHAR 10
		PRINTSTRING correcto
		IMPRIMECHAR 10
		CALL SYSPAUSE
		JMP OP_IN_FUN

	INGRESO_ARCHIVO:
		CALL CLS
		CL_STRING contenido2
		CL_STRING path
		PRINTSTRING ruta_menu
		IN_STRING path
		;********************************************************************
		; LECTURA DEL ARCHIVO
		;********************************************************************
		; -- ABRIR EL ARCHIVO:
			open_file path, [pathHandle]
		; -- LEER EL ARCHIVO:
			read_file [pathHandle], contenido2, [tam]
		; -- CERRAR EL ARCHIVO:
			close_file [pathHandle]
		; -- VER CONTENIDO:	
		;********************************************************************
		CALL PARSE_CONTENIDO
		IMPRIMECHAR 10
		PRINTSTRING correcto
		IMPRIMECHAR 10
		CALL SYSPAUSE
		JMP OP_IN_FUN

	PARSE_CONTENIDO:
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSH DI
		PUSH AX
		;***************
		MOV BX, contenido2
		MOV CX, 00H
		LOOP_PARSE:
			CMP CX, 014H 											; YA LLEGO A 14?
			JE FIN_PARSE 											; SI ES ASI ENTONCES PARA
			CL_STRING auxiliar
			MOV SI, auxiliar
			LOOP_CONT:
				CMP byte[BX], '$'									; TERMINO LA CADENA
				JE FIN_PARSE
				CMP byte[BX], ';' 									; LLEGO? AL FINAL DE UNA FUNCION?
				JE FIN_CONT
				MOV AL, byte[BX] 									; GUARDO EL CARACTER EN AL 
				MOV byte[SI], AL 									; GUARDO EL CARACTER
				INC BX
				INC SI
				JMP LOOP_CONT
			FIN_CONT:
			ANALIZAR auxiliar
			CMP byte[error], 01h 
			JE PARSE_INC
			;-GUARDO LA FUNCION
			PUSH BX
			PUSH CX
			CALL W_FUN 												; ALMACENO LA FUNCION EN CUESTION
			POP CX
			POP BX
			;------------------
			PARSE_INC:
			INC BX
			INC CX
			JMP LOOP_PARSE
		FIN_PARSE:
		;***************
		POP AX
		POP DI
		POP SI
		POP DX
		POP CX
		POP BX
		RET

;*****************************************************************************************************************************************************
;*															SECCION DE IMPRIMIR FUNCIONES 															 *
;*****************************************************************************************************************************************************
	OP_PR_FUN:
		MOV byte[contador], 00h
		CALL CLS
		PRINTSTRING menu_print
		CALL READ_MEMORY
		CALL COUNT_FUN
		CALL PRINT_MEMORY
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

	READ_MEMORY:
		CL_STRING contenido
		;***********************************
		; LECTURA DE FUNCIONES EN MEMORIA
		;***********************************
		; -- LEER EL ARCHIVO:
			open_file memoria, [memhandle]
		; -- LEER EL ARCHIVO:
			read_file [memhandle], contenido, [tam]
		; -- CERRAR EL ARCHIVO:
			close_file [memhandle]
		; -- REGRESAR
		RET

	COUNT_FUN:
		PUSH BX
		PUSH CX
		PUSH DI
		;*********
		MOV BX, contenido
		XOR CX, CX
		MOV CX, 00H
		LOOP_COUNT:
			CMP byte[BX], '$'									; ES EL FINAL DE LA CADENA?
			JE END_COUNT
			CMP byte[BX], ';'									; ES UN PUNTO Y COMA?
			JNE JMP_COUNT
			INC_COUNT:
			INC CL
			JMP_COUNT:
			INC BX
			JMP LOOP_COUNT 
		END_COUNT:
		;*********
		MOV byte[contador], CL
		CMP byte[contador], 0EH
		JL SIGUE
		MOV byte[contador], 0EH
		SIGUE:
		POP DI
		POP CX
		POP BX
		RET

	PRINT_MEMORY:
		PUSH CX
		PUSH BX
		PUSH AX
		PUSH SI 
		CL_STRING auxiliar 										; LIMPIO LA CADENA AUXILIAR
		MOV BX, contenido 										; PUNTERO AL CONTENIDO
		XOR CX, CX
		MOV CX, 00H
		LOOP_PRINT:
			CMP CL, byte[contador] 								; LLEGO YA AL TOPE?
			JE END_LOOP_PRINT
			CL_STRING auxiliar
			MOV SI, auxiliar
			IN_LOOP:
				CMP byte[BX], '$' 									; TERMINO LA CADENA?
				JE END_LOOP_PRINT
				CMP byte[BX], ';'
				JE IN_END
				MOV AL, byte[BX]									; COPIO EL CARACTER
				MOV byte[SI], AL 									; MUEVO EL CARACTER AL ALUXILIAR
				INC SI
				INC BX
				JMP IN_LOOP
			IN_END:
			;********************
			; IMPRIMO
			;********************
			IMPRIMECHAR '*'
			IMPRIMECHAR ' '
			IMPRIMECHAR '>'
			IMPRIMECHAR '>'
			IMPRIMECHAR ' '
			PRINTSTRING auxiliar
			IMPRIMECHAR 10
			;********************
			INC BX
			INC CX 
			JMP LOOP_PRINT
		END_LOOP_PRINT:
		PRINTSTRING separador
		POP SI
		POP AX
		POP BX
		POP CX
		RET

;*****************************************************************************************************************************************************
;*															SECCION DE GRAFICAR FUNCIONES															 *
;*****************************************************************************************************************************************************
	OP_GR_FUN:
		CALL CLS
		MOV byte[contador], 00h
		CL_STRING contenido 									; LEO EL CONTENIDO DEL ARCHIVO
		CALL READ_MEMORY 										; LEO LA MEMORIA DE LA CALCULADORA
		CALL COUNT_FUN 											; CUENTO LAS FUNCIONES
		;MOV CL, byte[contador]
		;ADD CL, 30H
		;READ_FUN 01H
		;ANALIZER auxiliar
		;CALL IMPRIME_FUNCION
		;IMPRIMECHAR 10
		;CALL EVALUA_FUNCION
		;CALL SYSPAUSE
		;IMPRIMECHAR CL
		;CALL SYSPAUSE
		;JMP MENU_PRINCIPAL 
		;----------------
		CALL GRAPHIC_MODE 										; LLAMO AL MODO GRAFICO
		CALL DIBUJA_MARCO 										; DIBUJO EL MARCO DE LA GRAFICADORA
		CALL DIBUJA_EJES
		;----------------
		; PRUEBAS
		;----------------
		DRAW_PIX -032H, 0AH, 07H
		;----------------
		;CALL GRAPHIC_PAUSE 										; PAUSA PARA PODER VER QUE SE DIBUJE TODO
		JMP MUEVE_FELCHAS
		JMP MENU_PRINCIPAL

	DIBUJA_MARCO:
		;DRAW_H_LINE 14h, 0AH, 026DH, 07H  								; EMPIEZA EN Y = 20, X = 10
		;DRAW_V_LINE 14h, 0AH, 141H, 07H       							; EMPIEZA EN Y = 20, X = 10
		;DRAW_H_LINE 154H, 0AH, 026DH, 07H 								; EMPIEZA EN Y = 340, X = 10 
		;DRAW_V_LINE 14H, 276H, 141H, 07H 								; EMPIEZA EN Y = 20, X = 630
		DRAW_CHAR 00H, 02H, 'F', 07H
		DRAW_CHAR 00H, 03H, '(', 07H 
		DRAW_CHAR 00H, 04H, 'x', 07H
		DRAW_CHAR 00H, 05H, ')', 07H
		DRAW_CHAR 00H, 06H, '=', 07H
		RET

	DIBUJA_EJES:
		; CENTRO X = 140H, Y = AFH
		DRAW_H_LINE 0AFh, 00H, 280H, 03H
		DRAW_V_LINE 00H, 140H, 15EH, 03H
		;DRAW_PIX 0AFH, 133h, 04h
		RET

	MUEVE_FELCHAS:
		XOR CX, CX
		MOV CL, 000H
		LOOP_FLE:
			MOV AH, 01H
			INT 16H
			JNZ UPDATE_GRAPH
			JMP LOOP_FLE
		END_FLE:
		JMP MENU_PRINCIPAL

	UPDATE_GRAPH:
		MOV AH, 00
		INT 16H

		CMP AH, 4DH
		JE MOVE_FOWARD

		CMP AH, 4BH
		JE MOVE_BACKWARDS

		CMP AH, 01H
		JE MENU_PRINCIPAL

		JMP LOOP_FLE

	MOVE_FOWARD:
		INC CL													; INCREMENTO CL 
		CMP CL, byte[contador] 									; LLEGO AL TOPE DEL CONTADOR?
		JG END_FLE 												; SI ES ASI TERMINA
		;************************
		; AQUI DEBERIA DE PINTAR 
		;************************
		CALL REPAINT
		READ_FUN CL
		ANALIZER auxiliar
		CALL EVALUA_FUNCION
		CALL EVALUA_FUNCION2
		CALL ESCRIBE_AUX
		;CL_STRING auxiliar
		;************************************
		; AQUI DEBERIA DE EVALUAR LA FUNCION
		;************************************

		;************************
		JMP LOOP_FLE

	MOVE_BACKWARDS:
		DEC CL 													; INCREMENTO CL
		CMP CL, 01h 											; YA LLEGO A 0?
		JL END_FLE 												; SI ES ASI ENTONCES TERMINA 
		;************************
		; AQUI DEBERIA DE PINTAR
		;************************
		CALL REPAINT
		READ_FUN CL
		ANALIZER auxiliar
		CALL EVALUA_FUNCION
		CALL EVALUA_FUNCION2
		;CL_STRING auxiliar
		;************************	
		JMP LOOP_FLE

	REPAINT:
		CALL GRAPHIC_MODE
		CALL DIBUJA_MARCO
		CALL DIBUJA_EJES
		RET

	SEARCH_FUN:
		MOV BX, contenido
		MOV CL, 00H
		LOOP_S:
			CMP CL, byte[indice] 								; LLEGUE AL INDICE?
			JE FIN_S
			CL_STRING auxiliar
			MOV SI, auxiliar 									; MUEVO EL PUNTERO AL auxiliar PARA PODER LLENAR LA CADENA
			IN_S_LOOP:
				CMP byte[BX], '$' 									; TERMINO LA CADENA?
				JE FIN_S
				CMP byte[BX], ';'
				JE IN_S_FIN
				MOV AL, byte[BX]									; COPIO EL CARACTER
				MOV byte[SI], AL 									; MUEVO EL CARACTER AL ALUXILIAR
				INC SI
				INC BX
				JMP IN_S_LOOP
			IN_S_FIN:
			;-------------
			INC BX
			INC CL
			JMP LOOP_S
		FIN_S:
		RET

	ESCRIBE_AUX:
		PUSH BX
		PUSH SI
		PUSH CX
		;------
		XOR CX, CX 
		MOV BX, auxiliar
		MOV CL, 07h
		L_E:
			CMP byte[BX], '$'
			JE F_L_E
			MOV AL, byte[BX]
			DRAW_CHAR 00H, CL, AL, 07H
			INC CL
			INC BX
			JMP L_E
		F_L_E:
		;------
		POP CX
		POP SI
		POP BX
		RET

	ANALIZAR2:
		AN_LOOP:
			CMP byte[BX], '$' 											; ES EL FINAL DE CADENA?
			JE FIN_AN
			CMP byte[BX], '-' 											; ES MENOS?
			JE AUM_AN
			CMP byte[BX], '+'											; ES MAS?
			JE AUM_AN
			;--------------
			; GUARDO CARAC
			;--------------
			MOV AL, byte[BX]
			MOV byte[SI], AL
			INC SI
			INC BX
			JMP AN_LOOP
			AUM_AN:
				ADD DI, 09H
				MOV SI, DI
				MOV AL, byte[BX]
				MOV byte[SI], AL
				INC SI
				INC BX
				JMP AN_LOOP
		FIN_AN:
		RET

	EVALUA_FUNCION:
		IMPRIMECHAR 10
		PUSH BX
		PUSH SI 
		PUSH DI
		PUSH AX
		PUSH CX
		PUSH DX
		;---------S		
		CL_STRING pruebas
		MOV SI, 00h

		EVL_LOOP:
			;CMP SI, 06H
			CMP SI, word[limite_superior]
			JE FIN_EVL
			;***********************
			; RESETEO RESP
			MOV word[aux_resul2], 00h
			MOV word[aux_resul3], 00h
			; EVALUO:
			CALL EVL_AUX
			; X = SI, Y = RESP
			;***********************
			; GRAGICO
			CL_STRING pruebas
			CL_STRING charArr
			MOV word[ycord], 00h
			MOV word[xcord], 00h
			MOV AX, word[aux_resul2] ; COORDENADA EN Y, EN SI TENGO X
			MOV word[ycord], AX
			MOV word[xcord], SI
			;-------------
			;-------------
			; X * 32
			;-------------
			XOR AX, AX
			MOV AX, word[xcord]
			MOV CL, 0AH
			MUL CL
			MOV word[xcord], AX
			XOR AX, AX
			;--------------
			MOV DX, 0AFH ; CENTRO DE Y

			MOV AX, word[aux_resul2]
			TEST AX, 0x80
			JZ RESTA

			NEG word[aux_resul2]

			MOV AX, word[aux_resul2]
			XOR AH, AH
			MOV word[aux_resul2], AX

			ADD DX, word[aux_resul2]
			
			JMP GUARDAY1

			RESTA:

			MOV AX, word[aux_resul2]
			XOR AH, AH
			MOV word[aux_resul2], AX

			SUB DX, word[aux_resul2]
			

			GUARDAY1:
			MOV word[ycord], DX


			MOV AX, 140H ; CENTRO DE X
			ADD AX, word[xcord]
			MOV word[xcord], AX
			CALL ESCRIBE_SAL
			;-------------------------------
			; PRUEBA
			;-------------------------------
			MOV AX, word[ycord]
			MOV DX, word[xcord]
			MOV word[ycordaux], AX
			MOV word[xcordaux], DX

			ADD word[ycordaux], 01H
			DRAW_PIX word[ycordaux], word[xcord], 07h

			SUB word[ycordaux], 02h
			DRAW_PIX word[ycordaux], word[xcord], 07h

			ADD word[xcordaux], 01h
			DRAW_PIX word[ycord], word[xcordaux], 07h

			SUB word[xcordaux], 02h
			DRAW_PIX word[ycord], word[xcordaux], 07h
			
			;-------------------------------
			DRAW_PIX word[ycord], word[xcord], 07h

			;----------------------
			PR:
			INC SI
			JMP EVL_LOOP
		FIN_EVL:
		;---------
		POP DX
		POP CX
		POP AX
		POP DI
		POP SI
		POP BX
		RET

	EVALUA_FUNCION2:
		PUSH BX
		PUSH SI 
		PUSH DI
		PUSH AX
		PUSH CX
		PUSH DX
		;---------S
		MOV byte[es_imp], 00h		
		CL_STRING pruebas
		MOV SI, -1h
		EVL_LOOP2:
			;CMP SI, -06H
			CMP SI, word[limite_menor]
			JE FIN_EVL2
			;***********************
			; RESETEO RESP
			MOV word[aux_resul2], 00h
			MOV word[aux_resul3], 00h
			; EVALUO:
			CALL EVL_AUX
			; X = SI, Y = RESP
			;***********************
			; GRAGICO
			CL_STRING pruebas
			CL_STRING charArr
			MOV word[ycord], 00h
			MOV word[xcord], 00h
			MOV AX, word[aux_resul2] ; COORDENADA EN Y, EN SI TENGO X
			MOV word[ycord], AX
			MOV word[xcord], SI
			;-----------------------

			;-------------
			; X * 32
			;-------------
			ELEV:
			XOR AX, AX
			MOV AX, word[xcord]
			MOV CL, 0AH
			MUL CL
			MOV word[xcord], AX
			XOR AX, AX
			;--------------
			MOV DX, 0ABH ; CENTRO DE Y 

			MOV AX, word[aux_resul2]
			TEST AX, 0x80
			JZ REST2


			; si el numero es negativo
			NEG word[aux_resul2]

			

			MOV AX, word[aux_resul2]
			XOR AH, AH
			MOV word[aux_resul2], AX
			
			ADD DX, word[aux_resul2]
			
			JMP GUARDAY2

			REST2:
			

			; si el numero es positivo
			MOV AX, word[aux_resul2]
			XOR AH, AH
			MOV word[aux_resul2], AX

			SUB DX, word[aux_resul2]

			GUARDAY2:
			MOV word[ycord], DX


			MOV AX, 140H ; CENTRO DE X
			ADD AX, word[xcord]
			MOV word[xcord], AX

			;CALL ESCRIBE_SAL
			;-----------------------------------------
			MOV AX, word[ycord]
			MOV DX, word[xcord]
			MOV word[ycordaux], AX
			MOV word[xcordaux], DX

			ADD word[ycordaux], 01H
			DRAW_PIX word[ycordaux], word[xcord], 07h

			SUB word[ycordaux], 02h
			DRAW_PIX word[ycordaux], word[xcord], 07h

			ADD word[xcordaux], 01h
			DRAW_PIX word[ycord], word[xcordaux], 07h

			SUB word[xcordaux], 02h
			DRAW_PIX word[ycord], word[xcordaux], 07h
			;-------------------------------------------

			DRAW_PIX word[ycord], word[xcord], 07h
			;-----------------------

			PR2:
			DEC SI
			JMP EVL_LOOP2
		FIN_EVL2:
		;---------
		POP DX
		POP CX
		POP AX
		POP DI
		POP SI
		POP BX
		RET

	EVL_AUX:
		PUSH SI 
		MOV BX, funcion 		; GUARDO LA POSICION QUE LLEVA FUNCION
		MOV DI, funcion 		; LA COPIA DE LA POSICION
		MOV byte[tipo_term], 04h 	; EL TIPO LO RESETEO
		MOV CL, 00H
		AUX_L:
			CMP CL, 004h 			; YA LLEGO A LA 4TA POSICION?
			JE FIN_AUX_L
			EVALUA_TERM funcion, CL  	 ; EVALUA EL TERMINO EN LA POSICION DE CL
			CMP byte[tipo_term], 02h ; ES DE TIPO DE EXPONENTE
			JE EVALUA2
			CMP byte[tipo_term], 01h ; ES EL TIPO QUE NO TIENE EXPONENTE
			JE EVALUA1
			CMP byte[tipo_term], 00h ; EL QUE TIENE UNA CONSTANTE
			JE EVALUA0
			AUX_L_CONT:
			MOV byte[tipo_term], 04h
			ADD DI, 009h
			MOV BX, DI
			INC CL
			JMP AUX_L
		FIN_AUX_L:
		POP SI
		RET

	EVALUA2:
		PUSH BX
		PUSH SI 
		PUSH DI
		PUSH AX
		PUSH CX
		PUSH DX
		;---------
		XOR AX, AX
		MOV word[aux_resul3], 00h
		CMP byte[BX], '$'
		JE CONTINUA2
		;--------
		MOV byte[coef_num], 00h
		MOV byte[tam], 00h
		CL_STRING coef
		CL_STRING expo
		GET_NUM BX, 00H
		GET_EXP BX, 00H
		;-------------------
		; CONVIRTIENDO EXPO
		;MOV AL, byte[expo]
		;SUB AL, 030H
		;-------------------
		; CONVIERTO EL NUMERO
		COUNT coef, [tam]
		CMP byte[tam], 01h
		JE CONVIERTE1
		JMP CONVIERTE2
		CONVIERTE1:
			TO_NUM1 coef, byte[coef_num]
			JMP CONTINUA
		CONVIERTE2:
			TO_NUM2 coef, byte[coef_num]
			JMP CONTINUA
		CONTINUA:
		;**********
		; COEG < 0
		;**********
		CMP byte[coef_num], 0H
		JNE C_2
		MOV byte[coef_num], 01h
		;---------
		; ELEVO
		;---------
		C_2:
		MOV AL, byte[expo]
		SUB AL, 030H
		MOV byte[expo], AL ;<---- AQUI EL PROBLEMA
		POW SI, byte[expo], word[aux_resul3]
		;-----------------------
		; MULTIPLICO
		;-----------------------
		MUL2:
		XOR AX, AX 
		MOV AX, word[aux_resul3]
		MOV DL, byte[coef_num]
		MUL DL
		CMP byte[BX], '-'
		JE EV2_REST
		;ADD word[aux_resul2], AX
		JMP CONTINUA2
		;-----------------------
		EV2_REST:
			;SUB word[aux_resul2], AX
			;BORRE ESTA LINEA
			NEG AX ; * *-1
		CONTINUA2:
		ADD word[aux_resul2], AX  ; SIEMPRE SUMO
		POP DX
		POP CX
		POP AX
		POP DI
		POP SI
		POP BX
		JMP AUX_L_CONT

	EVALUA1:
		PUSH BX
		PUSH SI 
		PUSH DI
		PUSH AX
		PUSH CX
		PUSH DX
		;-----------------------
		CMP byte[BX], '$'
		JE EV1_CONTINUA2
		;-----------------------
		MOV byte[coef_num], 00h
		MOV byte[tam], 00h
		CL_STRING coef
		GET_NUM BX, 00H
		;-----------------------
		; CONVIERTO EL NUMERO
		;-----------------------
		COUNT coef, [tam]
		CMP byte[tam], 01h
		JE E1_CONV1
		JMP E1_CONV2
		E1_CONV1:
			TO_NUM1 coef, byte[coef_num]
			JMP E1_CONTINUA
		E1_CONV2:
			TO_NUM2 coef, byte[coef_num]
			JMP E1_CONTINUA
		E1_CONTINUA:
		;**********
		; COEG < 0
		;**********
		CMP byte[coef_num], 0H
		JNE C_1
		MOV byte[coef_num], 01h
		;-----------------------
		; MULTIPLICO
		;----------------------
		C_1:
		XOR AX, AX
		MOV AX, SI
		MOV DL, byte[coef_num]
		MUL DL
		CMP byte[BX], '-'
		JE EV1_REST
		;ADD word[aux_resul2], AX
		JMP EV1_CONTINUA2
		EV1_REST:
			;SUB word[aux_resul2], AX
			; BORRE ESTA LINEA
			NEG AX
		EV1_CONTINUA2:
		ADD word[aux_resul2], AX ; SIEMPRE SUMO
		;-----------------------
		POP DX
		POP CX
		POP AX
		POP DI
		POP SI
		POP BX
		JMP AUX_L_CONT

	EVALUA0:
		PUSH BX
		PUSH SI 
		PUSH DI
		PUSH AX
		PUSH CX
		PUSH DX
		;----------------------
		CMP byte[BX], '$'
		JE EV0_CONTINUA2
		;----------------------
		MOV byte[coef_num], 00h
		MOV byte[tam], 00h
		CL_STRING coef
		GET_NUM BX, 00H
		;----------------------
		; CONVIERTO NUMERO
		;----------------------
		COUNT coef, [tam]
		CMP byte[tam], 01h
		JE E2_CONV1
		JMP E2_CONV2
		E2_CONV1:
			TO_NUM1 coef, byte[coef_num]
			JMP E2_CONTINUA
		E2_CONV2:
			TO_NUM2 coef, byte[coef_num]
			JMP E2_CONTINUA
		E2_CONTINUA:
		;**********
		; COEG < 0
		;**********
		CMP byte[coef_num], 0H
		JNE C_0
		MOV byte[coef_num], 01h
		;----------------------
		C_0:
		XOR AX, AX
		MOV AH, 00H
		MOV AL, byte[coef_num]
		CMP byte[BX], '-'
		JE EV0_REST
		;ADD word[aux_resul2], AX
		JMP EV0_CONTINUA2
		EV0_REST:
			;SUB word[aux_resul2], AX
			; BORRE ESTA LINEA
			NEG AX
		EV0_CONTINUA2:
		ADD word[aux_resul2], AX ; SIEMPRE SUMO
		POP DX
		POP CX
		POP AX
		POP DI
		POP SI
		POP BX
		JMP AUX_L_CONT

	ESCRIBE_SAL:
		PUSH BX
		PUSH SI
		PUSH CX
		PUSH AX 
		;------
		XOR CX, CX 
		MOV BX, pruebas
		MOV CL, 07h
		L_E1:
			CMP byte[BX], '$'
			JE F_L_E1
			MOV AL, byte[BX]
			DRAW_CHAR 03H, CL, AL, 07H
			INC CL
			INC BX
			JMP L_E1
		F_L_E1:
		;------
		POP AX 
		POP CX
		POP SI
		POP BX
		RET

;*****************************************************************************************************************************************************
;*															SECCION DE CONFIGURACION DE GRAFICA														 *
;*****************************************************************************************************************************************************
	CONFIG:
		CALL CLS
		PRINTSTRING menu_config
		CALL GETCHAR
		CMP AL, '1'
		JE LIM_SUP
		CMP AL, '2'
		JE LIM_INF
		CMP AL, '3'
		JE ESPACIADO_G
		CMP AL, '4'
		JE VER_CONF 
		CMP AL, '5'
		JE MENU_PRINCIPAL
		JMP CONFIG

	LIM_SUP:
		CALL CLS
		PRINTSTRING conf_sup
		CALL GETCHAR
		IMPRIMECHAR 10
		XOR CX, CX
		XOR CH, CH
		MOV CL, AL
		SUB CL, 30H
		MOV word[limite_superior], CX
		XOR CX, CX
		PRINTSTRING guardado
		CALL SYSPAUSE
		JMP CONFIG

	LIM_INF:
		CALL CLS
		PRINTSTRING conf_inf
		CALL GETCHAR
		IMPRIMECHAR 10
		XOR CX, CX
		XOR CH, CH
		MOV CL, AL
		SUB CL, 030H
		NEG CX
		MOV word[limite_menor], CX
		XOR CX, CX
		PRINTSTRING guardado
		CALL SYSPAUSE
		JMP CONFIG

	ESPACIADO_G:
		JMP CONFIG

	VER_CONF:
		CALL CLS
		XOR CX, CX
		XOR AX, AX
		MOV CX, word[limite_superior]
		;---SUP---
		XOR CH,CH
		ADD CL, 030H
		PRINTSTRING conf_sup
		IMPRIMECHAR CL
		;---------
		IMPRIMECHAR 10
		MOV AX, word[limite_menor]
		;---------
		XOR AH, AH 
		NEG AL
		ADD AL, 030H
		PRINTSTRING conf_inf
		IMPRIMECHAR AL
		IMPRIMECHAR 10
		XOR CX, CX
		XOR AX, AX
		CALL SYSPAUSE
		JMP CONFIG

;*****************************************************************************************************************************************************
;*															SECCION DE RESOLVER ECUACION															 *
;*****************************************************************************************************************************************************
	OP_RE_FUN:
		CALL LEE_EQ 											; ABRO EL ARCHIVO
		MOV byte[ban_grado], 00h 								; ASUMO DE INICIO QUE LA FUNCION ES DE GRADO 2
		MOV byte[a], 00h 										; INICIALIZO LAS VARIABLES
		MOV byte[b], 00h 										; --
		MOV byte[c], 00H 										; --
		CALL CLS
		;**************************************
		; INICIO DE OPCION DE RESOLUCION
		;**************************************
		MOV byte[error], 00h 									; EL ANALISIS INICIA SIN ERROR ALGUNO
		CL_STRING entrada 										; LIMPIO LA CADENA DE ENTRADA
		CL_STRING expo 											; LIMPIO EL EXPONENTE
		CL_STRING vari 											; LIMPIO LA VARIABLE
		CL_STRING coef 											; LIMPIO EL COEFICIENTE
		PRINTSTRING resol_menu
		IN_STRING entrada 										; PIDO LA CADENA DE ENTRADA
		PRINTSTRING separador
		IMPRIMECHAR 10
		ANALIZAR entrada 										; ANALIZO LA CADENA DE ENTRADA PARA VERIFICAR QUE CUMPLA CON LAS ESPECIFICACIONES
		CMP byte[error], 01H 									; SI ERROR CONTIENE VALOR DE 1 ENTONCES HUBO
		JE ERROR_ANALIZAR
		;--------------------------------------
		; ESCRIBO LA FUNCION
		;--------------------------------------
		write_in_file [rep_e_hand], 3AH, separador
		MOV byte[charAux], 10
		write_in_file [rep_e_hand], 01h, charAux 
		write_in_file [rep_e_hand], 0BH, rep_eq_fun				; AQUI ESCRIBO "| FUNCION: "
		MOV word[tam], 00h
		COUNT entrada, [tam]
		write_in_file [rep_e_hand], [tam], entrada
		MOV byte[charAux], ' '
		write_in_file [rep_e_hand], 0DH, rep_eq_sol
		;--------------------------------------
		; INICIO DE EVALUACION DE TERMINOS 
		; PARA CORROBORAR QUE SEA GRADO 2
		;--------------------------------------
		CALL VERIFICA_GRADO
		CMP byte[ban_grado], 000H 								; SI EL GRADO ES MENOR A 2 ENTONCES PUEDE PROCEDER DE LO CONTRARIO NO SE HARA
		JE RESOLVE  												; CONTINUARA NORMAL
		PRINTSTRING msg_mayor
		JMP FIN_RE
		;--------------------------------------
		; RESUELVE LA ECUACION
		;--------------------------------------
		RESOLVE:
		; -- OBTENGO LOS TERMINOS:
			CALL OBTENER_TERMINO
			IMPRIMECHAR 10
			PRINTSTRING separador
			IMPRIMECHAR 10
		; -- CALCULAR EL DISCRIMINANTE
			;CALL DISCRIMINANTE
		; -- CALCULO DE PRIMER GRADO
			PRINTSTRING msg_sol
			CALL P_GRADO_RES
			IMPRIMECHAR 10
		;--------------------------------------
		FIN_RE:
		;**************************************
		MOV byte[charAux], 10
		write_in_file [rep_e_hand], 01h, charAux 
		close_file [rep_e_hand]
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

	VERIFICA_GRADO:
		PUSH BX
		PUSH CX
		PUSH AX
		PUSH DX
		;---------
		MOV BX, funcion 										; MUEVO EL PUNTERO A LA FUNCION PARA PODER MOVERME A TRAVEZ DE ELLA
		MOV CX, 00H 											; MUEVO EL CONTADOR PARA PODER LLEVAR EL CONTROL DE LOS TERMINOS QUE SE EVALUAN
		MOV byte[tipo_term], 00h 								; REINICIO LA BANDERA DE EVALUACION
		VER_LOOP:
			CMP CL, 04H 										; LLEGO A LA POSICION 4 DE LA FUNCION?
			JE FIN_VER 											; SI ES ASI ENTONCES TERMINA
			EVALUA_TERM funcion, CL
			CMP byte[tipo_term], 02h 							; ES UN TERMINO CON EXPONENTE?
			JNE VER_CONT
			;--------------------------------
			; VERIFICO SI EXPONENTE NO MAYOR
			;--------------------------------
			GET_EXP funcion, CL
			CMP byte[expo], '2'
			JLE VER_CONT
			MOV byte[ban_grado], 01h
			;--------------------------------
			VER_CONT:
			INC CX
			ADD BX, 09H
			MOV byte[tipo_term], 00h
			JMP VER_LOOP
		FIN_VER:
		;---------
		POP DX
		POP AX 
		POP CX
		POP BX
		RET

	OBTENER_TERMINO: 											; HACE USO DE VARIABLES a,b,c
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH AX
		PUSH SI
		;-------
		MOV byte[tipo_term], 00h 								; REINICIO LA VARIABLE DE TERMINOS
		MOV BX, funcion 										; MUEVO EL PUNTERO HACIA LA FUNCION
		MOV CX, 00H 											; MUEVO EL CONTADOR
		OBT_LOOP:
			CMP CL, 004H 										; LLEGO AL FINAL?
			JE FIN_OBT
			EVALUA_TERM funcion, CL 							; EVALUA LA FUNCION
			CMP byte[tipo_term], 02h 							; SI ES DE 2?
			JE OBT_A
			CMP byte[tipo_term], 01h 							; SI ES DE 1?
			JE OBT_B
			CMP byte[tipo_term], 00h 							; SI ES DE 0?
			JE OBT_C
			JMP AUM
			OBT_A:
				CALL GET_A									; LLAMA A ETIQUETA PARA OBTENER A 
				JMP AUM
			OBT_B:
				CALL GET_B 									; LLAMA A ETIQUETA PARA OBTENER B 
				JMP AUM
			OBT_C:
				CALL GET_C 									; LLAMA A ETIQUETA PARA OBTENER C
				JMP AUM
			AUM:
				ADD BX, 09H
				INC CX
				MOV byte[tipo_term], 00h
				JMP OBT_LOOP
		FIN_OBT:
		;-------
		POP SI 
		POP AX 
		POP DX 
		POP CX
		POP BX
		RET

	GET_A:
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH AX
		PUSH SI
		;--------
		MOV byte[s_a], 00h
		PUSH BX
		PUSH AX
			MOV AL, byte[BX]									; MUEVE EL SIGNO PARA VER QUE ES
			CMP AL, '-'
			JNE N_A
			MOV byte[s_a], 01H									; SI ES NEGATIVO ENTONCES ACTIVARE LA BANDERA DE NEGATIVOS  
		N_A:
		POP AX 
		POP BX 
		CL_STRING coef
		CL_STRING salida
		CL_STRING charArr
		GET_NUM BX, 00H
		COUNT coef, [tam]
		CMP byte[tam], 02h 										; COMPARO EL NUMERO DE DIGITOS QUE TIENE EL COEFICIENTE
		JE CONVI_2
		CONVI_1:
			TO_NUM1 coef, byte[coef_num] 						; SI TIENE SOLO 1 ENTONCES LO CONVIERTO UTILIZANDO EL DE 1 A SU HEXA EQUIVALENTE
			JMP CONT_A
		CONVI_2:
			TO_NUM2 coef, byte[coef_num] 						; SI TIENE SOLO 2 ENTONCES LO CONVIERTO UTILIZANDO EL DE 2 A SU HEXA EQUIVALENTE
			JMP CONT_A
		CONT_A:
		;--------
		IMPRIMECHAR ' '
		IMPRIMECHAR '>'
		IMPRIMECHAR '>'
		IMPRIMECHAR ' '
		IMPRIMECHAR 'A'
		IMPRIMECHAR ':'
		MOV AL, byte[BX]
		IMPRIMECHAR AL
		;IMPRIMECHAR ' '
		MOV AL, byte[coef_num]									; MUEVO A AL EL RESULTADO DEL COEFICIENTE
		MOV byte[a], AL 										; MUEVO EL RESULTADO A a 273779
		NUM_TO_CHAR a, charArr 									; CONVIRTIENDO SOLO PARA VISUALIZAR
		NUM_SALIDA charArr, salida
		PRINTSTRING salida
		IMPRIMECHAR ' '
		;CMP byte[s_a], 001h 	 								; ES NEGATIV0?
		;JNE FIN_A 												; SI NO LO ES.. ME LO SALTO
		;A_NEGATIVO a 											; PASO A NEGATIVO
		FIN_A:
		POP SI
		POP AX
		POP DX
		POP CX
		POP BX 
		RET

	GET_B:
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH AX
		PUSH SI
		;--------
		MOV byte[s_b], 00h
		PUSH BX
		PUSH AX
			MOV AL, byte[BX]									; MUEVE EL SIGNO PARA VER QUE ES
			CMP AL, '-'
			JNE N_B
			MOV byte[s_b], 01H									; SI ES NEGATIVO ENTONCES ACTIVARE LA BANDERA DE NEGATIVOS  
		N_B:
		POP AX 
		POP BX 
		CL_STRING coef
		CL_STRING salida
		CL_STRING charArr
		GET_NUM BX, 000h 										; INDICO EN QUE POSICION NECESITO QUE TOME EL COEFICIENTE
		COUNT coef, [tam] 										; GUARDO EL TAMANIO DEL NUMERO
		CMP byte[tam], 02h 										; SI ES DE DOS DIGITOS?
		JE CONV_B2
		CONV_B1:
			TO_NUM1 coef, byte[coef_num]						; CONVIERTO EN NUMERO HEXA EL COEFICIENTE
			JMP CONT_B
		CONV_B2:
			TO_NUM2 coef, byte[coef_num]
			JMP CONT_B
		CONT_B:
		;--------
		IMPRIMECHAR '|'
		IMPRIMECHAR ' '
		IMPRIMECHAR 'B'
		IMPRIMECHAR ':'
		MOV AL, byte[BX]
		IMPRIMECHAR AL
		;IMPRIMECHAR ' '
		MOV AL, byte[coef_num]
		MOV byte[b], AL
		NUM_TO_CHAR b, charArr 									; CONVIRTIENDO SOLO PARA VISUALIZAR
		NUM_SALIDA charArr, salida
		PRINTSTRING salida
		IMPRIMECHAR ' '
		;CMP byte[s_b], 001h 	 								; ES NEGATIV0?
		;JNE FIN_B 												; SI NO LO ES.. ME LO SALTO
		;A_NEGATIVO b 											; PASO A NEGATIVO
		FIN_B:
		POP SI
		POP AX
		POP DX
		POP CX
		POP BX 
		RET

	GET_C:
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH AX
		PUSH SI
		;------
		MOV byte[s_c], 00h
		PUSH BX
		PUSH AX
			MOV AL, byte[BX]									; MUEVE EL SIGNO PARA VER QUE ES
			CMP AL, '-'
			JNE N_C
			MOV byte[s_c], 01H									; SI ES NEGATIVO ENTONCES ACTIVARE LA BANDERA DE NEGATIVOS  
		N_C:
		POP AX 
		POP BX 
		CL_STRING coef
		CL_STRING salida
		CL_STRING charArr
		GET_NUM BX, 00H 										; INDICO EN QUE POSICION NECESITO EL COEFICIENTE
		COUNT coef, [tam]										; CUENTO EL TAMANIO
		CMP byte[tam], 02h
		JE CONV_C2
		CONV_C1:
			TO_NUM1 coef, byte[coef_num]						; CONVIERTO EN NUMERO HEXA EL COEFICIENTE
			JMP CONT_C
		CONV_C2:
			TO_NUM2 coef, byte[coef_num]
			JMP CONT_C
		CONT_C:
		;------
		IMPRIMECHAR '|'
		IMPRIMECHAR ' '
		IMPRIMECHAR 'C'
		IMPRIMECHAR ':'
		MOV AL, byte[BX]
		IMPRIMECHAR AL
		;IMPRIMECHAR ' '
		MOV AL, byte[coef_num]
		MOV byte[c], AL
		NUM_TO_CHAR c, charArr 									; CONVIRTIENDO SOLO PARA VISUALIZAR
		NUM_SALIDA charArr, salida
		PRINTSTRING salida
		;CMP byte[s_c], 001h 	 								; ES NEGATIV0?
		;JNE FIN_C 												; SI NO LO ES.. ME LO SALTO
		;A_NEGATIVO c 											; PASO A NEGATIVO
		FIN_C:
		POP SI
		POP AX
		POP DX
		POP CX
		POP BX
		RET

	DISCRIMINANTE:
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH AX
		;-------
		CL_STRING salida
		CL_STRING charArr
		POW word[b], 02h, word[pow_resul] 						; HAGO EL ELEVADO DE B
		MOV AX, 04H 											; MUEVO EL 4 A AX PARA HACER LA MULTIPLICACION
		MOV BX, word[a]											; MUEVO A BX LO QUE CONTIENE A
		MOV CX, word[c]											; MUEVO A CX LO QUE CONTIENE C 
		MUL BX 													; 4 * A 
		MUL CX 													; 4 * A * C
		MOV word[aux_resul1], AX 								; MUVO EL RESULTADO
		MOV AX, word[pow_resul]									; MUEVO B^2 A AX
		MOV DX, word[aux_resul1]								; MUEVO 4 * A * C -> DX
		
		POP DX
		POP CX
		POP BX
		RET 

	P_GRADO_RES:
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH AX
		;----------------
		; VALIDO SIGNOS
		CALL VAL_SIGNO
		CL_STRING salida
		CL_STRING charArr
		;----------------
		MOV word[aux_resul1], 00h 								; EL RESULTADO SERA 0 
		CMP word[c], 00h 										; ES C 0?
		JE F_P_GR
		;----------------
		; SI C NO ES 0:
		;----------------
		;A_NEGATIVO c
		MOV AX, word[c]											; MOVER AX LO QUE ESTA EN C
		MOV CX, word[b]											; MUEVO A CX LO QUE ESTA EN B
		DIV CL 													; DIVIDO AX/DX
		XOR DH, DH
		MOV DL, AL  											; MUEVO EL COCIENTE A DL
		MOV word[aux_resul1], DX 								; MUEVO AL RESULTADO
		MOV byte[entero], AH 									; MUEVO EL REMINDER
		;A_NEGATIVO aux_resul1s
		NUM_TO_CHAR aux_resul1, charArr 								; CONVIERTO EL NUMERO A ARREGLO
		NUM_SALIDA charArr, salida 								; CONVIERTO EL ARREGLO EN STRING DE SALIDA
		PRINTSTRING salida
		MOV word[len], 00h
		COUNT2 salida, word[len]
		write_in_file [rep_e_hand], word[len] , salida
		;----------------
		; FLOTANTE:
		CMP byte[entero], 00h
		JE F_P_GR
		XOR AX, AX
		CL_STRING salida
		CL_STRING charArr
		IMPRIMECHAR '.'
		MOV byte[charAux], '.'
		write_in_file [rep_e_hand], 01h, charAux 
		MOV word[aux_resul1], 00h
		MOV AL, byte[entero]
		MOV DL, 0AH
		MUL DL
		MOV DX, word[b]
		DIV DL
		XOR AH, AH
		MOV word[aux_resul1], AX
		NUM_TO_CHAR aux_resul1, charArr 								; CONVIERTO EL NUMERO A ARREGLO
		NUM_SALIDA charArr, salida 								; CONVIERTO EL ARREGLO EN STRING DE SALIDA
		PRINTSTRING salida
		MOV word[len], 00h
		COUNT2 salida, word[len]
		write_in_file [rep_e_hand], word[len] , salida
		;----------------
		F_P_GR:
		POP AX
		POP DX
		POP CX
		POP BX
		RET

	VAL_SIGNO:
		CMP byte[s_b], 01h
		JE VAL_C1
		JMP VAL_C2
		VAL_C1:
		CMP byte[s_c], 00h
		JE VAL_MAS
		JMP VAL_MENOS
		VAL_C2:
		CMP byte[s_c], 00H
		JE VAL_MENOS
		JMP VAL_MAS
		VAL_MENOS:
		IMPRIMECHAR '-'
		MOV byte[charAux], '-'
		write_in_file [rep_e_hand], 01h, charAux 
		JMP VAL_FIN
		VAL_MAS:
		IMPRIMECHAR '+'
		MOV byte[charAux], '+'
		write_in_file [rep_e_hand], 01h, charAux 
		JMP VAL_FIN
		VAL_FIN:
		RET

;*****************************************************************************************************************************************************
;*															SECCION DE REPORTES															             *
;*****************************************************************************************************************************************************

	OP_REP_FUN:
		CALL CLS
		PRINTSTRING menu_rep
		CALL GETCHAR
		CMP AL, '1'												; COMPARO SI ESCOGIO LA OPCION 1
	    JE REP1 												; SALTA A REPORTE 1
		CMP AL, '2'												; COMPARO SI ESCOGIO LA OPCION 2
		JE REP2 												; SALTA A REPORTE 2
		CMP AL, '3'												; SI ES LA TERCERA OPCION
		JE MENU_PRINCIPAL
		JMP OP_REP_FUN

	REP1:
		CALL CLS
		CALL EVL_REP		

	REP2:
		CALL CLS
		PRINTSTRING mes_rep
		CALL SYSPAUSE
		JMP OP_REP_FUN

	REP_EQ:
		;------------------------------------
		; CREAR EL ARCHIVO
		;------------------------------------
		create_file reporte_equ, [rep_e_hand]
		;------------------------------------
		; ESCRIBIR EL ENCAMEZADO DEL REPORTE
		;------------------------------------
		write_in_file [rep_e_hand], 1FH, encabezado_rep
		MOV byte[charAux], ' '
		write_in_file [rep_e_hand], 01h, charAux 
		MOV byte[charAux], '2'
		write_in_file [rep_e_hand], 01h, charAux 
		MOV byte[charAux], 10
		write_in_file [rep_e_hand], 01h, charAux 
		close_file [rep_e_hand]
		RET

	LEE_EQ:
		PUSH AX
		PUSH CX
		PUSH BX
		PUSH DX 
		;---------------------------------------
		; LEER EL ARCHIVO PARA EMPEZAR A ESCIBIR
		;---------------------------------------
		CL_STRING contenido
		open_file reporte_equ, [rep_e_hand]
		read_file [rep_e_hand], contenido, [tam]
		CL_STRING contenido
		;---------------------------------------
		POP DX
		POP BX
		POP CX
		POP AX
		RET

	EVL_REP:
		PUSH CX
		PUSH DX
		PUSH SI
		PUSH DI 
		PUSH BX
		PUSH AX
		CALL RP2
		CALL LIMPIAR_FUN
		CL_STRING contenido 									; LEO EL CONTENIDO DEL ARCHIVO
		CALL READ_MEMORY 										; LEO LA MEMORIA DE LA CALCULADORA
		CALL COUNT_FUN
		MOV CL, 01H
		LOOP_EVL:
			CL_STRING auxiliar
			CMP CL, byte[contador]
			JG FIN_L_EVL
			READ_FUN CL
			ANALIZER auxiliar
			;**************************
			; CUENTO auxiliar y escribo
			PUSH CX
			XOR CX, CX
			write_in_file [rep_evl_handle], 0BH, rep_eq_fun
			COUNT auxiliar, byte[lenght]
			write_in_file [rep_evl_handle], [lenght], auxiliar
			MOV byte[charAux], 10
			write_in_file [rep_evl_handle], 1h, charAux
			POP CX
			
			CALL PUNTOS

			write_in_file [rep_evl_handle], 3BH, separador
			MOV byte[charAux], 10
			write_in_file [rep_evl_handle], 1h, charAux
			INC CL
			JMP LOOP_EVL
		FIN_L_EVL:
		CALL CL_REP2
		PUSH AX
		PUSH BX
		PUSH DI
		PUSH SI
		PUSH DX
		PUSH CX
		PRINTSTRING mes_rep
		CALL SYSPAUSE
		JMP OP_REP_FUN 	

	RP2:
		PUSH BX
		PUSH AX
		PUSH DX
		PUSH CX
		;32
		create_file reporte_evl, [rep_evl_handle]
		write_in_file [rep_evl_handle], 20h, encabezado_rep
		MOV byte[charAux], 10
		write_in_file [rep_evl_handle], 1h, charAux
		write_in_file [rep_evl_handle], 3BH, separador
		MOV byte[charAux], 10
		write_in_file [rep_evl_handle], 1h, charAux
		POP CX
		POP DX
		POP AX
		POP BX
		RET

	CL_REP2:
		PUSH BX
		PUSH AX
		PUSH DX
		PUSH CX
		close_file [rep_evl_handle]
		POP CX
		POP DX
		POP AX
		POP BX
		RET

	PUNTOS:
		PUSH BX
		PUSH SI 
		PUSH DI
		PUSH AX
		PUSH CX
		PUSH DX
		;---------S		
		CL_STRING pruebas
		;MOV SI, -06h
		MOV SI, 001h
		PUNTOS_LOOP:
			CMP SI, 06h
			;CMP SI, word[limite_superior]
			JG FIN_PUNTOS
			;***********************
			; RESETEO RESP
			MOV word[aux_resul2], 00h
			MOV word[aux_resul3], 00h
			CALL EVL_AUX
			;***********************
			; TOMO RESPUESTA
			CL_STRING pruebas
			CL_STRING charArr

			MOV byte[charAux], '*'
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], ' '
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], 'x'
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], ':'
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], ' '
			write_in_file [rep_evl_handle], 1h, charAux

			PUSH CX
			MOV CX, SI
			ADD CL, 030h

			;TEST SI, 0x80
			TEST SI, 0x80
			JZ N_N

			MOV byte[charAux], '-' 
			write_in_file [rep_evl_handle], 1h, charAux

			MOV CX, SI
			NEG CX
			ADD CL, 030H

			N_N:
			MOV byte[charAux], CL 
			write_in_file [rep_evl_handle], 1h, charAux
			POP CX

			PUNTOS_CONT:
			MOV byte[charAux], ','
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], ' '
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], 'y'
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], ':'
			write_in_file [rep_evl_handle], 1h, charAux
			MOV byte[charAux], ' '
			write_in_file [rep_evl_handle], 1h, charAux

			;*****************************************************
			; AQUI VOY A ANALIZAR SI ES NECESARIO COLOCAR EL SIGNO
			;*****************************************************
			MOV AX, word[aux_resul2]
			TEST AX, 0x8000
			JZ POSITIVO
			NEG word[aux_resul2]
			MOV byte[charAux], '-'
			write_in_file [rep_evl_handle], 1h, charAux
			;*****************************************************

			POSITIVO:
			XOR AX, AX
			MOV AX, word[aux_resul2]
			;XOR AH, AH
			MOV word[aux_resul2], AX
			NUM_TO_CHAR aux_resul2, charArr 							; CONVIERTO EL NUMERO A ARREGLO
			NUM_SALIDA charArr, pruebas
			PUSH CX
			COUNT pruebas, byte[lenght]
			write_in_file [rep_evl_handle], [lenght], pruebas
			POP CX
			MOV byte[charAux], 10
			write_in_file [rep_evl_handle], 1h, charAux

			P_TERMINA:
			INC SI
			JMP PUNTOS_LOOP
		FIN_PUNTOS:
		;---------
		POP DX
		POP CX
		POP AX
		POP DI
		POP SI
		POP BX
		RET

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
	
	OBT_VAR:
		CMP byte[BX], '0'
		JL OBT_VAR_FIN
		CMP byte[BX], '9'
		JG OBT_VAR_FIN
		INC BX
		JMP OBT_VAR
		OBT_VAR_FIN:
			MOV AL, byte[BX]
			MOV byte[vari], AL
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
		ADD SI, 09H
		PRINTSTRING SI
		;IMPRIMECHAR 10
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
		ADD SI, 09H
		PRINTSTRING SI
		;IMPRIMECHAR 10
		;------
		POP SI
		POP DI
		POP DX
		POP CX
		POP AX
		POP BX
		RET

	IMPRIME_INTEGRAL:
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH DX
		PUSH DI
		PUSH SI
		;------
		MOV SI, integral
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		ADD SI, 09H
		PRINTSTRING SI
		;IMPRIMECHAR 10
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
	; LA POTENCIA
	;--------------------------------------
	DO_POW:	
		; AQUI INICIA:
		MOV CH, 00H 
		SUB CL, 001h
		POW_LOOP:
			CMP CH, CL 						; EL CONTADOR YA LLEGO A N?
			JE FIN_POW
			MUL BX 							; MULTIPLICO AX POR DL
			;MUL BL
			INC CH 							; INCREMENTO CH
			JMP POW_LOOP 					; VUELVO A COMENZAR
		FIN_POW:
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

	;-----------------------------------------
	; ESCRIBE LA FUNCION, INTEGRAL O DERIVADA
	;----------------------------------------
	ESCRIBE_F:
		COUNT SI, [tam]
		write_in_file [memhandle], [tam], SI
		ADD SI, 09H
		COUNT SI, [tam]
		write_in_file [memhandle], [tam], SI
		ADD SI, 09H
		COUNT SI, [tam]
		write_in_file [memhandle], [tam], SI
		ADD SI, 09H
		COUNT SI, [tam]
		write_in_file [memhandle], [tam], SI
		ADD SI, 09H
		COUNT SI, [tam]
		write_in_file [memhandle], [tam], SI
		ADD SI, 09H
		RET
	
	;--------------------------------------
	; ERROR AL ABRIR UN ACRHIVO
	;--------------------------------------
	ERROR_FILE:
		CALL CLS
		PRINTSTRING errorMSG
		IMPRIMECHAR 10
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL
	
	ERROR_ANALIZAR:
		CALL CLS
		IMPRIMECHAR 10
		PRINTSTRING error_analisis
		IMPRIMECHAR 10
		CALL SYSPAUSE
		JMP MENU_PRINCIPAL

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
	
	;--------------------------------------
	; MODO GRAFICO
	;--------------------------------------
	GRAPHIC_MODE:
		MOV AH, 00H
		MOV AL, 10H
		INT 10H
		RET

	;--------------------------------------
	; PAUSE EN GRAFICO
	;--------------------------------------
	GRAPHIC_PAUSE:
		MOV AH, 08H
		INT 21H
		RET

	;--------------------------------------
	; LOOP PARA DIBUJAR UNA LINEA HORIZONTAL
	;--------------------------------------
	H_LINE:
		MOV SI, 001H
		H_LP:
			CMP SI, word[max]
			JE H_END
			MOV AH, 0CH
			MOV AL, byte[color]
			MOV BH, 00H
			INT 10H
			INC CX
			INC SI
			JMP H_LP
		H_END:
			RET

	;--------------------------------------
	; LOOP PARA DIBUJAR UNA LINEA VERTICAL
	;--------------------------------------
	V_LINE:
		MOV SI, 001H
		V_LP:
			CMP SI, word[max]
			JE V_END
			MOV AH, 0CH
			MOV AL, byte[color]
			MOV BH, 00H
			INT 10H
			INC DX
			INC SI
			JMP V_LP
		V_END:
			RET

	;--------------------------------------
	; SALIDA DEL PROGRAMA
	;--------------------------------------
	EXIT:
		CALL CLS
		PRINTSTRING mensal
		MOV AH, 04CH
		INT 21H
