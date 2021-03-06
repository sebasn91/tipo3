; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; definicion de rutinas de atencion de interrupciones

%include "imprimir.mac"

BITS 32

sched_tarea_offset:     dd 0x00
sched_tarea_selector:   dw 0x00

;; PIC
extern fin_intr_pic1

;; Sched
extern sched_proximo_indice
;; Game
extern game_mover
extern game_misil
extern game_minar


extern sel_tarea
extern mostrar_int
extern mostrar_num
global _isr32
global _isr33
global _isr52
;;
;; Definición de MACROS
;; -------------------------------------------------------------------------- ;;

%macro ISR 1
global _isr%1

_isr%1:
    mov EAX, %1
    PUSH EAX
    CALL mostrar_int
    ADD ESP, 4
.fin:
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $
;    iret
%endmacro

;;
;; Datos
;; -------------------------------------------------------------------------- ;;
; Scheduler
isrnumero:           dd 0x00000000
isrClock:            db '|/-\'

;;
;; Rutina de atención de las EXCEPCIONES
;; -------------------------------------------------------------------------- ;;
ISR 0
ISR 1
ISR 2
ISR 3
ISR 4
ISR 5
ISR 6
ISR 7
ISR 8
ISR 9
ISR 10
ISR 11
ISR 12
ISR 13
ISR 14
ISR 15
ISR 16
ISR 17
ISR 18
ISR 19

;;
;; Rutina de atención del RELOJ
;; -------------------------------------------------------------------------- ;;
_isr32:
    CLI
    PUSHAD
    CALL fin_intr_pic1
    ; CODIGO DE LA INTR

    CALL proximo_reloj
;    xchg bx, bx
    CALL sched_proximo_indice
    mov [sched_tarea_selector], ax
    xchg bx, bx
    jmp far [sched_tarea_offset]
  ;  jmp 15*(0x8):0x0
    POPAD
    STI
    IRET

;;
;; Rutina de atención del TECLADO
;; -------------------------------------------------------------------------- ;;
_isr33:
	CLI
	PUSHA
	CALL fin_intr_pic1
    XOR EAX, EAX
	IN AL, 0x60
	;xchg bx, bx
	PUSH EAX
	CALL mostrar_num
	POP EAX
	POPA
	IRET
 
;;
;; Ruta de atencion de 0x52
;; -------------------------------------------------------------------------- ;;

_isr52:
    CLI
    PUSHA

    MOV EAX, 0x42
    ;xchg bx, bx
    POPA
 ;   STI
    IRET

;;
;; Rutinas de atención de las SYSCALLS
;; -------------------------------------------------------------------------- ;;
%define SYS_MOVER     0x83D
%define SYS_MISIL     0x911
%define SYS_MINAR     0x355



;; Funciones Auxiliares
;; -------------------------------------------------------------------------- ;;
proximo_reloj:
        pushad
        inc DWORD [isrnumero]
        mov ebx, [isrnumero]
        cmp ebx, 0x4
        jl .ok
                mov DWORD [isrnumero], 0x0
                mov ebx, 0
        .ok:
                add ebx, isrClock
                imprimir_texto_mp ebx, 1, 0x07, 49, 79
                popad
        ret
        
        
