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
;* File Name: Score.asm
;* Program:   Road Driving Simulator
;*
;* Description: Score Manager
;*  
;* Prepare by:  Nevo Kadan (2018)
;*
;* Notes: link  http://fleder44.net/312/notes/16Files/Index.html
;******************************************************************************


;*******************************************************
;*PROCEDURE: CalcScore
;*DESCRIPTION: This procedure calculate score
;*
;* INPUT:
;* ------
;* [LINES]
;* [z_color]
;* [SCORE]
;* [msg+si]
;*
;* OUTPUT:
;* -------
;* [z_color]
;* [SCORE]
;* [msg+si]
;*
;*******************************************************
proc CalcScore
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov si,[LINES]              ;count each road new line add "1" to LINES
    inc si
    mov [LINES],si              ;store new value in [LINES]
    cmp si,COLOR_LINES          ;compare line counter with 50
    jne next_step               ;if not equall exit the procedure  
    
    mov [LINES],0               ;since LINES reach 50 zero it for next round
    
    mov al,[z_color]            ;each 50 lines change the color
    inc al
    mov [z_color],al
                                ;the SCORE will increment once per 50 lines
    mov si,[SCORE]              ;read current score
    inc si                      ;add one to score
    mov [SCORE],si              ;store new value in [SCORE]
    
    mov [POINTS_ADD],POINT_ROL  ;add amount of POINT_ROL per each point added to SCORE
    
rolling:
    mov si,OFFSET_SCORE_UNITS   ;point in msg to score units (most right digit in the 00000000)
    mov al,[msg+si]             ;read right (start with most right) byte to "al"
    cmp al,DIGIT_9              ;compare if decimal digit is "9"
    je point_upper_digit        ;if yes need handle one digit left 
    inc al                      ;if digit is less then "9"  increment it e.g. 0 us 0x30 will increment to 0x31
    mov [msg+si],al             ;store the new incremented digit
    jmp check_next
    
point_upper_digit:  
    mov [msg+si],DIGIT_0        ;put zero in current digit (change from "9" to "0")
    dec si                      ;move one digit to the left
    cmp si,SCORE_MSD_OFFSET     ;check if we chanage left most zero to "9" can't increase (value of 5 is "overflow" condition)
    je overflow_zero_score      ;in case of overflow zero the score and start again
    mov al,[msg+si]             ;this is not overflow, try to increment the digit
    cmp al,DIGIT_9              ;compare if decimal digit is "9"
    je point_upper_digit        ;handle again the "9" digit
    inc al                      ;this is not a "9" digit increment it
    mov [msg+si],al             ;store the new incremented digit
check_next: 
    mov ax,[POINTS_ADD]         ;get counter
    dec ax                      ;decrement 
    mov [POINTS_ADD],ax
    jz show_score
    jmp rolling

overflow_zero_score:            ;overflow zero all digits
    call ZeroScore
    
show_score: 
    call ShowScore

next_step:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp CalcScore



;*******************************************************
;*PROCEDURE: ShowScore
;*DESCRIPTION: This procedure print text string in graphic mode
;*
;* INPUT:
;* ------
;* msg
;*
;*
;* OUTPUT:
;* -------
;*
;*
;*
;*******************************************************
proc ShowScore
    push ax
    push bx
    push cx
    push dx
    push si
    
    ;https://stackoverflow.com/questions/43435403/i-am-trying-to-print-a-message-in-graphic-mode-in-assembly-but-the-console-d-i?rq=1
    mov si,@data                ;moves to si the location in memory of the data segment

    mov ah,PRINT_GRAPHICS_MODE  ;service to print string in graphic mode
    mov al,0                    ;sub-service 0 all the characters will be in the same color(bl) and cursor position is not updated after the string is written
    mov bh,0                    ;page number=always zero
    mov bl,TEXT_COLOR           ;color of the text (white foreground and black background)
                                ;     0000             1111
                                ;|_ Background _| |_ Foreground _|
                                ;

    mov cx,STRING_LEN_40        ;length of string
                                ;resoultion of the screen is 320x200
    mov dh,0                    ;y coordinate
    mov dl,0                    ;x coordinate
    mov es,si                   ;moves to es the location in memory of the data segment
    mov bp,offset msg           ;mov bp the offset of the string
    int 10h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp ShowScore



;*******************************************************
;*PROCEDURE: ZeroScore
;*DESCRIPTION: This procedure zero score
;*
;* INPUT:
;* ------
;*[msg]
;*
;*
;* OUTPUT:
;* -------
;*[msg]
;*
;*
;*******************************************************
proc ZeroScore
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov [msg],   'S'            ;rewrite  to "Score:"   
    mov [msg+1], 'c'
    mov [msg+2], 'o'
    mov [msg+3], 'r'
    mov [msg+4], 'e'
    mov [msg+5], ':'
    mov [msg+6], DIGIT_0        ;replace previous digit with "0"
    mov [msg+7], DIGIT_0        ;replace previous digit with "0"
    mov [msg+8], DIGIT_0        ;replace previous digit with "0"
    mov [msg+9], DIGIT_0        ;replace previous digit with "0"
    mov [msg+10],DIGIT_0        ;replace previous digit with "0"
    mov [msg+11],DIGIT_0        ;replace previous digit with "0"    
    mov [msg+12],DIGIT_0        ;replace previous digit with "0"
    mov [msg+13],DIGIT_0        ;replace previous digit with "0"
    

    mov [msg+33],'L'            ;rewrite  "Lives:9" 
    mov [msg+34],'i'
    mov [msg+35],'v'
    mov [msg+36],'e'
    mov [msg+37],'s'
    mov [msg+38],':'
    mov [msg+39],'9'    
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp ZeroScore



;*******************************************************
;*PROCEDURE: add_last_game_score_and_name
;*DESCRIPTION: This procedure add last game score and name
;*             into the proper place from 1 to 5 names
;*             if end game SCORE is bigger then score_1 swap them
;*             if SCORE is bigger then then score_2 swap them
;*             if SCORE is bigger then then score_3 swap them
;*             if SCORE is bigger then then score_4 swap them
;*             if SCORE is bigger then then score_5 swap them
;*
;* INPUT:
;* ------
;* [SCORE]
;* 
;*
;* OUTPUT:
;* -------
;* [score_01] [name_01]
;* [score_02] [name_02]
;* [score_03] [name_03]
;* [score_04] [name_04]
;* [score_05] [name_05]
;*
;*
;*******************************************************
proc add_last_game_score_and_name
    push ax
    push bx
    push cx
    push dx
    push si

    mov si,0
t_swap:                   ;make a copy of msg, so keep the original msg untouched.
    mov al,[msg+si]
    mov [t_msg +si],al
    inc si
    cmp si,REC_LENGTH
    jnz t_swap	
	
	
compare_place_1:    
    mov ax,[SCORE]              ;get end game SCORE
    sub ax,[score_01]           ;if end game SCORE bigger then score_01, swap between them.
    jge swap_1

compare_place_2:
    mov ax,[SCORE]              ;get end game SCORE
    sub ax,[score_02]           ;if end game SCORE bigger then score_02, swap between them.
    jge swap_2

compare_place_3:
    mov ax,[SCORE]              ;get end game SCORE
    sub ax,[score_03]           ;if end game SCORE bigger then score_03, swap between them.
    jge swap_3_

compare_place_4:
    mov ax,[SCORE]              ;get end game SCORE
    sub ax,[score_04]           ;if end game SCORE bigger then score_04, swap between them.
    jge swap_4_

compare_place_5:
    mov ax,[SCORE]              ;get end game SCORE
    sub ax,[score_05]           ;if end game SCORE bigger then score_05, swap between them.
    jge swap_5_ 
    
    jmp end_r

;*************************
;* SWAP 1 
;*************************
swap_1:
    mov ax,[SCORE] 
    mov [tmp_score],ax          ;tmp_score=SCORE

    mov ax,[score_01]   
    mov [SCORE],ax              ;SCORE=score_1

    mov ax, [tmp_score]
    mov [score_01],ax           ;score_1=tmp_score

    
    mov si,0
swap_1_loop1:                   ;tmp_name=t_t_msg
    mov al,[t_msg+si]
    mov [tmp_name +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_1_loop1

    mov si,0
swap_1_loop2:                   ;msg=name_01
    mov al,[name_01+si]
    mov [t_msg +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_1_loop2
    
    mov si,0
swap_1_loop3:                   ;name_01=tmp_name
    mov al,[tmp_name+si]
    mov [name_01+si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_1_loop3    
    jmp compare_place_2

swap_4_:
    jmp swap_4  
    
swap_3_:
    jmp swap_3  
    
swap_5_:
    jmp swap_5  
    
;*************************
;* SWAP 2 
;*************************  
swap_2:
    mov ax,[SCORE] 
    mov [tmp_score],ax          ;tmp_score=SCORE

    mov ax,[score_02]   
    mov [SCORE],ax              ;SCORE=score_2

    mov ax, [tmp_score]
    mov [score_02],ax           ;score_2=tmp_score

    mov si,0
swap_2_loop1:                   ;tmp_name=t_msg
    mov al,[t_msg+si]
    mov [tmp_name +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_2_loop1

    mov si,0
swap_2_loop2:                   ;t_msg=name_02
    mov al,[name_02+si]
    mov [t_msg +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_2_loop2
    
    mov si,0
swap_2_loop3:                   ;name_02=tmp_name
    mov al,[tmp_name+si]
    mov [name_02+si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_2_loop3    
    jmp compare_place_3
    
;*************************
;* SWAP 3 
;*************************  
swap_3:
    mov ax,[SCORE] 
    mov [tmp_score],ax          ;tmp_score=SCORE

    mov ax,[score_03]   
    mov [SCORE],ax              ;SCORE=score_3

    mov ax, [tmp_score]
    mov [score_03],ax           ;score_3=tmp_score
    
    mov si,0
swap_3_loop1:                   ;tmp_name=t_msg
    mov al,[t_msg+si]
    mov [tmp_name +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_3_loop1

    mov si,0
swap_3_loop2:                   ;t_msg=name_03
    mov al,[name_03+si]
    mov [t_msg +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_3_loop2
    
    mov si,0
swap_3_loop3:                   ;name_03=tmp_name
    mov al,[tmp_name+si]
    mov [name_03+si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_3_loop3    
    jmp compare_place_4

;*************************
;* SWAP 4
;*************************  
swap_4:
    mov ax,[SCORE] 
    mov [tmp_score],ax          ;tmp_score=SCORE

    mov ax,[score_04]   
    mov [SCORE],ax              ;SCORE=score_4

    mov ax, [tmp_score]
    mov [score_04],ax           ;score_4=tmp_score

    mov si,0
swap_4_loop1:                   ;tmp_name=t_msg
    mov al,[t_msg+si]
    mov [tmp_name +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_4_loop1

    mov si,0
swap_4_loop2:                   ;t_msg=name_04
    mov al,[name_04+si]
    mov [t_msg +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_4_loop2
    
    mov si,0
swap_4_loop3:                   ;name_04=tmp_name
    mov al,[tmp_name+si]
    mov [name_04+si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_4_loop3    
    jmp compare_place_5
    
;*************************
;* SWAP 5 
;*************************  
swap_5:
    mov ax,[SCORE] 
    mov [tmp_score],ax          ;tmp_score=SCORE

    mov ax,[score_05]   
    mov [SCORE],ax              ;SCORE=score_5

    mov ax, [tmp_score]
    mov [score_05],ax           ;score_5=tmp_score
    
    mov si,0
swap_5_loop1:                   ;tmp_name=t_msg
    mov al,[t_msg+si]
    mov [tmp_name +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_5_loop1

    mov si,0
swap_5_loop2:                   ;t_msg=name_05
    mov al,[name_05+si]
    mov [t_msg +si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_5_loop2
    
    mov si,0
swap_5_loop3:                   ;name_05=tmp_name
    mov al,[tmp_name+si]
    mov [name_05+si],al
    inc si
    cmp si,REC_LENGTH
    jnz swap_5_loop3
 
end_r:  
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp add_last_game_score_and_name



;*******************************************************
;*PROCEDURE: display_records
;*DESCRIPTION: This procedure print the 5 top records
;*
;* INPUT:
;* ------
;* 
;* 
;*
;* OUTPUT:
;* -------
;* 
;*
;*
;*******************************************************
proc display_records
    push ax
    push bx
    push cx
    push dx
    push si

    ;https://stackoverflow.com/questions/43435403/i-am-trying-to-print-a-message-in-graphic-mode-in-assembly-but-the-console-d-i?rq=1
    mov si,@data                ;moves to si the location in memory of the data segment

    mov ah,PRINT_GRAPHICS_MODE  ;service to print string in graphic mode
    mov al,0                    ;sub-service 0 all the characters will be in the same color(bl) and cursor position is not updated after the string is written
    mov bh,0                    ;page number=always zero
    mov bl,TEXT_COLOR           ;color of the text (white foreground and black background)
                                ;     0000             1111
                                ;|_ Background _| |_ Foreground _|
                                ;

    mov cx,STRING_LEN_34        ;length of string
                                ;resoultion of the screen is 320x200
    mov dl,COMMON_LINE_X        ;x coordinate
    mov es,si                   ;moves to es the location in memory of the data segment

    mov dh,LINE_1_Y             ;y coordinate
    mov bp,offset name_01       ;mov bp the offset of the string
    int 10h
    
    mov dh,LINE_2_Y             ;y coordinate
    mov bp,offset name_02       ;mov bp the offset of the string
    int 10h 
    
    mov dh,LINE_3_Y             ;y coordinate
    mov bp,offset name_03       ;mov bp the offset of the string
    int 10h

    mov dh,LINE_4_Y             ;y coordinate
    mov bp,offset name_04       ;mov bp the offset of the string
    int 10h

    mov dh,LINE_5_Y             ;y coordinate
    mov bp,offset name_05       ;mov bp the offset of the string
    int 10h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp display_records



;*******************************************************
;*PROCEDURE: OpenRecordsFile
;*DESCRIPTION: This procedure Open Records File
;*
;* INPUT:
;* ------
;* records_filename
;* 
;*
;* OUTPUT:
;* -------
;* [records_filehandle]
;*
;*
;*******************************************************
proc OpenRecordsFile
    mov ah, 3Dh                        ;Open an existing file
    mov al, 01h                        ;1 = open for writing
    mov dx, offset records_filename    ;copy address to DX
    int 21h                            ;open the file
    jc RecordOpenError
    mov [records_filehandle], ax 
    ret
    
RecordOpenError:
    mov dx, offset ErrorRecordsMsg
    mov ah, 9h
    int 21h
    ret
endp OpenRecordsFile



;*******************************************************
;*PROCEDURE: WriteRecordsFile
;*DESCRIPTION: This procedure Write Records File
;*
;* INPUT:
;* ------
;* [records_filehandle]
;* msg
;*
;* OUTPUT:
;* -------
;* 
;*
;*
;*******************************************************
proc WriteRecordsFile
    
    mov ah, 42h                        ;move file ptr 
    mov bx, [records_filehandle]       ;copy handle into BX
    xor cx, cx                         ;clear CX
    xor dx, dx                         ;0 bytes to move
    mov al, 2                          ;relative to end
    int 21h                            ;move pointer to end. DX:AX = file size
    jc move_error                      ;error if CF = 1
    
    mov ah,40h                         ;write file 
    mov bx, [records_filehandle]       ;copy handle into BX
    mov cx,33                          ;set count to write
    mov dx,offset msg
    int 21h
    jc  write_error                    ;jump if error   
    
    mov ah,40h                         ;write file 
    mov bx, [records_filehandle]       ;copy handle into BX
    mov cx,2                           ;set count to write
    mov dx,offset end_of_line
    int 21h
    jc  write_error                    ;jump if error       
    ret

write_error:    
    mov dx, offset ErrorRecordsMsg
    mov ah, 9h
    int 21h
    ret 

move_error:     
    mov dx, offset ErrorRecordsMsg
    mov ah, 9h
    int 21h
    ret 
endp WriteRecordsFile



;*******************************************************
;*PROCEDURE: CloseRecordsFile
;*DESCRIPTION: This procedure Close Records File
;*
;* INPUT:
;* ------
;* records_filehandle
;* 
;*
;* OUTPUT:
;* -------
;* 
;*
;*
;*******************************************************
proc CloseRecordsFile
    mov ah,3eh
    mov bx, [records_filehandle]
    int 21h
    ret
endp CloseRecordsFile
