@ primos.s 
@ Imprimir los primeros 100 primos

@ registros

@ r1 apunta al primo
@ r3 numero que estamos checkeando
@ r4 cuenta los primos
@ r5 divisores que estamos checkeando	
@ r6 indice para los divisores primos que checkeamos
@ r7 sostiene lo que sobra
@ r8 sostiene los resultados de las divisiones
@ r9 numeros primos que buscamos

.section	.bss
.comm prime, 400	@ reservar el espacio (4 bytes para cada uno)

.section	.data
spc:			@ espaciado para que se vea bien
	.ascii "  "
len = . - spc
nl: 			@ salto de linea
	.ascii "\n"
limit:			@ indice del ultimo primo que necesitamos
	.long 100 

.section .text
.globl	_start
_start:

P1:			
ldr r1, =prime		@ r1 apunta al primo
mov r0, $2		@ primer primo es 2
str r0, [r1]		@ Guarda el numero en prime
ldr r0, =limit
ldr r9, [r0]		@ r2 tiene los numeros primos que utlizaremos
mov r3, $3		@ inicializa r3 en 3
mov r4, $1		@ inicializa r4 en 1

P2:			@ si encuentra un primo(true)
add r4, r4, $1		@ incrementa r4
str r3, [r1, #4]!	@ guarda r3 en prime

P3:			@check
cmp r4, r9		@ revisar si son todos los primos o no
bge P9			@ si es cierto va a p9

P4:
add r3, r3, $2		@ añadir dos a r3

P5:			@ empieza a fijarse para ver si son primos mediante divisiones
ldr r6, =prime		@ cargar el registro de prime
ldr r5, [r6]		@ carga el primer divisor
mov r7, r3		@ copia r3 en r7
mov r8, $0		@ inicializa r8

P6:
cmp r7, r5		@ if r7 >= divisor(r5)
subge r7, r7, r5 	@ substraer el divisor de r7
addge r8, r8, $1	@ Incrementa r8
bge P6			@ repetir p6
cmp r7, $0		@ if R == 0
beq P4			@ el r3 en p4 no es primo entonces sigue con el siguiente guardado en r3

P7:
cmp r8, r5		@ compara r8 con el divisor(r5)
ble P2			@ if Q <= divisor N es primo

P8:
mov r7, r3		@ resetea r7 a r3
mov r8, $0		@ resetea r8
ldr r5, [r6, #4]!	@ obtiene el siguiente divisor(r5)
bal P6			@ empieza a dividir otra vez

P9:
mov r0, $1		@ choose stdout
mov r4, $0		@ r4 contador temporal(cuenta hasta 10 para los saltos de linea)
mov r5, $0		@ r5 cuenta el total de primos imprimidos
ldr r6, =prime		@ apunta a prime
ldr r3, [r6]		@ carga el primer primo

printLoop:
bl print_num		@ llama a la funcion que imprime los numeros
add r4, $1		@ añade uno al contador temporal
add r5, $1		@ añade uno al contador
cmp r5, r9 		@ checkea si estamos listos
bge exit		@ si es cierto sale
cmp r4, $9		@ checkea que haya 10 numeros(primos)
bgt newline		@ salto de linea para mantener el order
ble space		@ añade espacios

space:                  @ metodo para imprimir espacios
mov r0, $1               
ldr r1, =spc		
ldr r2, =len	
mov r7, $4
svc $0
ldr r3, [r6, #4]!	@ carga el siguiente primo despues del espacio
bal printLoop           @ sigue imprimiendo

newline:                @ metodo para imprimir saltos de linea
mov r0, $1              
ldr r1, =nl             
mov r2, $1
mov r7, $4
svc $0
ldr r3, [r6, #4]!       @ carga el siguiente primo despues del salto de linea
mov r4, $0              @ resetea el contador temporal para que empieze a contar de nuevo
bal printLoop		@ sigue imprimiendo



@ print_num function

print_num:
	stmfd sp!, {r0-r9, lr}	@ push registros a la pila
	mov r4, $0 		@ settea el contador de la division a 0
	mov r5, $1		@ settea el contador de char a 1

loop:				@ loop de rutina para imprimir
	cmp r3, $9		
	ble stackPush		@ if r3 <= 9 pushee en la pila
	sub r3, r3, $10		@ else substraiga 10 de r3
	add r4, r4, $1		@ añadir uno al contador de division
	bal loop		@ repita

stackPush:			@pushea en la pila
	add r5, r5, $1		@ incrementa el contador de char
	orr r0, r3, $0x30	@ OR - añade 48 para obtener el codigo ascii
	stmfd	sp!, {r0}	@ pushea en el stack
	cmp r4, $0		@ if r4==0
	beq printChars		@ imprima
	mov r3, r4		@ else cargue contador de division(r4) en r3
	mov r4, $0		@ resetear el contador de division(r4)
	bal loop		@ vuelva a ejecutar el ciclo

printChars:
	mov r1, sp		@ usa el ascii para proveer el codigo ascii
	mov r0, $1		@ descriptor 1
	mov r2, $1		@ largo para imprimir es 1
	mov r7, $4		@ escribe la llamada al sistema
	svc $0			@ despierta al kernel
	subs r5, r5, $1		@ decrementa el contador de string y settea la bandera
	ble return		@ return si esta listo
	ldmfd sp!, {r0}		@ jala el siguiente char del stack 
	bal printChars		@ obtiene el siguiente char
return:
	ldmfd sp!, {r0-r9, pc}	@ restorea los registros

exit:
mov r0, $1			@ imprime una nueva linea
ldr r1, =nl
mov r2, $1
mov r7, $4
svc $0
mov r7, $1			@ sale
svc $0

.end