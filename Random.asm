;*
;* Copyright (c) 2018, Kadan. All rights reserved.
;*
;* Redistribution and use in source and binary forms, with or without
;* modification, are permitted provided that the following conditions
;* are met:
;*
;*   - Redistributions of source code must retain the above copyright
;*     notice, this list of conditions and the following disclaimer.
;*
;*   - Redistributions in binary form must reproduce the above copyright
;*     notice, this list of conditions and the following disclaimer in the
;*     documentation and/or other materials provided with the distribution.
;*
;*   - Neither the name of Kadan or the names of its
;*     contributors may be used to endorse or promote products derived
;*     from this software without specific prior written permission.
;*
;* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;* IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;* 



;******************************************************************************
;* File Name: Random.asm
;* Program:   Road Driving Simulator
;*
;* Description: Ramdom Number Generator
;*  
;* Prepare by:  Nevo Kadan (2018)
;*
;******************************************************************************

;*******************************************************
;*PROCEDURE: Randomize
;*DESCRIPTION: This procedure regenerates a random number, is store in [RandomNumber]
;*
;* INPUT:
;* ------
;* --[RandomSeed]
;* --[RandomCounter]
;* --[RandomMax]
;* --[RandomMin]
;* [PRIMITIVE_ROOT] 
;*
;* OUTPUT:
;* -------
;* [RandomNumber]
;*
;*
;*******************************************************
proc Randomize
    push ax
    push bx
    push cx
    push dx
    push si
    jmp zx81_rnd               ;the below random stack when player points reach 70-80 so it replace by ZX81 algorithem
    
    mov ah,GET_SYSTEM_TIME      ;Get System Time (by INT 21)
    int 21h                     ;Return: CH = hour CL = minute DH = second DL = 1/100 seconds
    mov al,dl                   ;1/100 of Seconds (we use dl since it change allot one every call)
    mul [RandomSeed]            ;ax = al * RandomSeed (init on startup "RandomSeed" = 17h [1 byte])
    mul [RandomCounter]         ;ax = al * RandomCounter (init on startup "RandomCounter" =1 [1 byte])
    mov bl,[RandomMax]          ;RandomMax  = 100 [1 byte]
    sub bl,[RandomMin]          ;RandomMin  = 1 [1 byte]
    div bl                      ;ax=ax/bl (remider in "dx")
    add ah,[RandomMin]          ;ah=ah+1
    mov [RandomNumber],ax       ;output in "RandomNumber" = ax (a word value)
    inc [RandomCounter]   

zx81_rnd:
    ;see in link   http://zxnext.narod.ru/manuals/ZX81_Manual.pdf   
    ; last page of chapter 5 - RND Function
    mov ax,[RandomNumber]      ;get the previous pseudo random number 
    inc ax                     ;add one to previous pseudo random number 
    mul [PRIMITIVE_ROOT]       ;multiply it with PRIMITIVE_ROOT (75)
    dec ax                     ;substract one from the multiply 
    mov [RandomNumber],ax      ;store the result as new pseudo random
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
ENDP Randomize



;*******************************************************
;*PROCEDURE: Seed_Random
;*DESCRIPTION: This procedure seed random number from sytem time seconds and 1/100 of seconds 
;*
;* INPUT:
;* ------
;* GET_SYSTEM_TIME
;* 
;* 
;* 
;*
;* OUTPUT:
;* -------
;* [RandomNumber]
;*
;*
;*******************************************************
proc Seed_Random
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah,GET_SYSTEM_TIME      ;Get System Time (by INT 21)
    int 21h                     ;Return: CH = hour CL = minute DH = second DL = 1/100 seconds
    mov [RandomNumber],dx       ;store new seed from time lower bits 
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
ENDP Seed_Random
    


;*******************************************************
;*PROCEDURE: MakeRandomNumber
;*DESCRIPTION: This procedure makes a random number in a specific range
;* 
;*   +---------------------------------------------------+
;*   |                        [RandomNumber]             |
;*   | [R_RND] = [BASE] +  (  -------------- * [RANGE] ) |
;*   |                             [MAX]                 |
;*   +---------------------------------------------------+
;*
;*   Note: For e.g. we want "Hop" to be random number in range[80,188]
;*         From "Randomize" we got "RandomNumber" into "AL" low byte in "AL" is in range [1,255] so 0<("AL"/255)<1
;*         we will calculate(("AL"/255)*108)+80 but for computer we alter the order tobe ("AL"*108/255)+80
;* INPUT:
;* ------
;* [RandomNumber]
;* [RANGE]
;* [MAX]
;* [BASE]
;*
;* OUTPUT:
;* -------
;* [R_RND]
;*
;*
;*******************************************************
proc MakeRandomNumber
    push ax
    push bx
    push cx
    push dx
    push si

    call Randomize
    mov ax,0
    mov ax,[RandomNumber]
    mov ah,0
    mul [RANGE]                 ;ax=al*RANGE 
    div [MAX]                   ;ax=ax/MAX 
    add ax,[BASE]               ;ax=ax+BASE
    mov ah,0
    mov [R_RND],ax 
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp MakeRandomNumber