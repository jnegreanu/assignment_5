INCLUDE Irvine32.inc

.386
.model flat, stdcall
.stack 4096; SS register
ExitProcess proto, dwExitCode:dword

; Author(s) : Joshua Negreanu and Warner Greenbaum
; Course / Project ID : CS 271 Assignment 4		Date : 2 / 28 / 23
; Description: This program asks the user for the number of composite numbers to display and displays that amount in order

;------------------------------------------------------------;

; min and max bounds of the user input(list size)
MIN = 10
MAX = 200

; lower and upper limits of the numbers to be randomly generated
LO  = 100
HI = 999

.data; DS register;
    ; the string for the program name
    pname           BYTE    "Sorting Random Numbers (Assignment 5) written by Josh Negreanu.", 0

    ; program info string
    info            BYTE    "This program generates random numbers in the range [100 .. 999], displays the original list, sorts the list, and calculates the median value.Finally, it displays the list sorted in descending order.", 0

    ; prompt for the user to input the length of the randomly generated list
    prompt1         BYTE    "How many numbers should be generated? [10 .. 200]: ", 0
    list_size       DWORD   ?

    ; error message if the user inputs a number outside the range
    error           BYTE    "Out of range. Try again.", 0

    ; list variable
    list    DWORD   MAX   DUP(?)

    ; spacer string
    spacer          BYTE    "   ", 0

    ; string prompts for displaying the unsorted list, median, and sorted list
    prompt2         BYTE    "The unsorted random numbers:", 0
    prompt3         BYTE    "The median is: ", 0
    prompt4         BYTE    "The sorted list:", 0

    ; certification string
    certify         BYTE    "Results certified by Josh Negreanu.", 0

    ; custom goodbye
    goodbye         BYTE    "Goodbye", 0

;------------------------------------------------------------;

.code; CS register

introduction proc
    push EDX

    mov EDX, OFFSET pname
    call WriteString
    call Crlf

    mov EDX, OFFSET info
    call WriteSTring
    call Crlf

    pop EDX
    ret
introduction endp

getData proc
    push EAX
    push EDX

    prompt_user:
    mov EDX, OFFSET prompt1
    call WriteString
    call ReadInt

    cmp EAX, MIN
    jl error_input

    cmp EAX, MAX
    jg error_input

    jmp no_error

    error_input:
    mov EDX, OFFSET error
    call WriteString
    call Crlf
    jmp prompt_user

    no_error:
    mov list_size, EAX
    
    pop EDX
    pop EAX
    ret
getData endp

fillArray proc
    push EBP
    push EDI
    push ECX
    push EAX

    mov EBP, ESP
    mov EDI, [EBP + 24]
    mov ECX, [EBP + 20]

    loop_top:
        mov EAX, HI
        sub EAX, LO
        add EAX, 1
        call RandomRange
        add EAX, LO

        mov [EDI], EAX
        add EDI, 4
    loop loop_top

    pop EAX
    pop ECX
    pop EDI
    pop EBP
    ret 8
fillArray endp

displayList proc
    push EBP
    push EDI
    push ECX
    push EAX

    mov EBP, ESP
    mov EDI, [EBP + 24]
    mov ECX, [EBP + 20]

    loop_top:
        mov EAX, [EDI]
        call WriteDec
        call Crlf
        add EDI, 4
    loop loop_top

    pop EAX
    pop ECX
    pop EDI
    pop EBP
    ret 8
displayList endp

displayMedian proc
    push EBP
    push EDI
    push EDX
    push ECX
    push EAX

    mov EBP, ESP
    mov EDI, [EBP + 28]
    mov EAX, [EBP + 24]

    mov EDX, 0
    mov ECX, 2
    div ECX

    cmp EDX, 0
    je avg_median

    mov ECX, 4
    mul ECX
    mov EAX, [EDI + EAX]
    mov EDX, OFFSET prompt3
    call WriteString
    call WriteDec
    call Crlf
    jmp median

    avg_median:
    mov EBX, EAX
    sub EBX, 1

    mov ECX, 4
    mul ECX
    mov ECX, EAX
    mov EAX, EBX
    mov EBX, ECX
    mov ECX, 4
    mul ECX

    mov EAX, [EDI + EAX]
    mov EBX, [EDI + EBX]
    add EAX, EBX
    mov ECX, 2
    mov EDX, 0
    div ECX

    cmp EDX, 0
    je no_add_one

    add EAX, 1

    no_add_one:

    mov EDX, OFFSET prompt3
    call WriteString
    call WriteDec
    call Crlf

    median:

    pop EAX
    pop ECX
    pop EDX
    pop EDI
    pop EBP
    ret 8
displayMedian endp

sortList proc
    push EBP
    push EDI
    push EDX
    push ECX
    push EBX
    push EAX

    mov EBP, ESP
    mov EDI, [EBP + 32]
    mov EDX, [EBP + 28]

    mov EAX, -1

    selection_sort_top:
        add EAX, 1

        mov EBX, EAX
        mov ECX, EAX

        inner_loop_top:
            add ECX, 1
            
            push EAX

            mov EAX, EBX
            push EDX
            mov EDX, 4
            mul EDX
            pop EDX
            mov EAX, [EDI + EAX]
            push EBX
            mov EBX, EAX

            mov EAX, ECX
            push EDX
            mov EDX, 4
            mul EDX
            pop EDX
            mov EAX, [EDI + EAX]
            push ECX
            mov ECX, EAX
            
            cmp EBX, ECX
            jg no_update

            pop ECX
            pop EBX
            mov EBX, ECX

            jmp updated

            no_update:

            pop ECX
            pop EBX

            updated:
            pop EAX

        cmp ECX, EDX
        jl inner_loop_top

        ;EXCHANGE (IDK HOW IN THE WORLD TO DO THIS)

        push EBP

        mov EDX, EAX
        push EDX
        mov EDX, 4
        mul EDX
        pop EDX
        mov ECX, [EDI + EAX]
        mov EBP, EDI
        add EBP, EAX
        mov EAX, EDX

        push EAX
        mov EAX, EBX
        push EBX
        push EDX
        mov EDX, 4
        mul EDX
        mov EDX, [EDI + EAX]
        mov EBX, EDI
        add EBX, EAX

        mov [EBP], EDX
        mov [EBX], ECX

        pop EDX
        pop EBX
        pop EAX

        pop EBP

    cmp EAX, EDX
    jl selection_sort_top

    pop EAX
    pop EBX
    pop ECX
    pop EDX
    pop EDI
    pop EBP
    ret 8
sortList endp

;------------------------------------------------------------;

main proc
    
    call Randomize
    
    call introduction
    call getData

    push OFFSET list
    push list_size
    call fillArray

    mov EDX, OFFSET prompt2
    call WriteString
    call Crlf
    push OFFSET list
    push list_size
    call displayList

    push OFFSET list
    push list_size
    call displayMedian

    push OFFSET list
    push list_size
    call sortList

    mov EDX, OFFSET prompt4
    call WriteString
    call Crlf
    push OFFSET list
    push list_size
    call displayList

invoke ExitProcess, 0
main endp
end main