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
;* File Name: Keyboard.asm
;* Program:   Road Driving Simulator
;*
;* Description: Keyboard Manager
;*  
;* Prepare by:  Nevo Kadan (2018)
;*
;******************************************************************************


;*******************************************************
;*PROCEDURE: GetKey
;*DESCRIPTION: This procedure getting the key that was pressed and saving what was pressed 
;*
;* INPUT:
;* ------
;* "in  al,64h"
;*
;*
;* OUTPUT:
;* -------
;* [MoveDirect]
;*
;*
;*******************************************************
proc GetKey     
    push ax
    push bx
    push cx
    push dx
    push si
    in  al,READ_KB_STATUS       ;read keyboard status
    cmp al,DATA_IN_KB_BUFFER    ;data in buffer
    je no_key_i

    ; key was press/release
    in al,GET_KB_DATA           ;get keyboard data
   
    cmp al,LEFT_ON              ;key left press
    je left_press
    jmp n1
left_press:
    mov [MoveDirect],MOVE_LEFT
    jmp sof

n1:
    cmp al, LEFT_OFF            ;key left release
    je left_release 
    jmp n2
left_release:
    mov [MoveDirect],0
    jmp sof 

n2:
    cmp al, RIGHT_ON            ;right key press
    je right_press  
    jmp n3
right_press:
    mov [MoveDirect],MOVE_RIGHT
    jmp sof
    
n3:
    cmp al, RIGHT_OFF           ;right key release
    je right_release
    jmp n4
right_release:
    mov [MoveDirect],0
    jmp sof     

no_key_i:
jmp no_key
    
n4:
    cmp al,UP_ON    
    je up_press 
    jmp n5
up_press:
    mov [MoveDirect],UP
    jmp sof 
        
n5:
    cmp al,UP_OFF
    je up_release
    jmp n6  
up_release:
    mov [MoveDirect],0  
    jmp sof 
    
n6:
    cmp al,DOWN_ON
    je down_press
    jmp n7  
down_press:
    mov [MoveDirect],DOWN
    jmp sof 

n7:
    cmp al,DOWN_OFF
    je down_release 
    jmp n8
down_release:
    mov [MoveDirect],0
    jmp sof
    
n8:
    cmp al,S_ON
    je s_press  
    jmp n9  
s_press:
    mov [MoveDirect],S_KEY
    jmp sof
    
n9:
    cmp al,S_OFF
    je s_release    
    jmp n10
s_release:
    mov [MoveDirect],0
    jmp sof 
    
n10:
    cmp al,R_ON
    je r_press  
    jmp n11
r_press:
    mov [MoveDirect],R_KEY
    jmp sof
    
n11:    
    cmp al,R_OFF
    je r_release        
    jmp n12
r_release:
    mov [MoveDirect],0
    jmp sof

n12:
    cmp al,N_ON
    je n_press  
    jmp n13
n_press:
    mov [MoveDirect],N_KEY
    jmp sof
    
n13:    
    cmp al,N_OFF
    je n_release        
    jmp n14
n_release:
    mov [MoveDirect],0
    jmp sof

n14:    
    cmp al,ESC_ON
    je ESC_press
    jmp n15 
ESC_press:
    mov [MoveDirect],ESC_KEY
    jmp sof

n15:
    cmp al,ESC_OFF
    je ESC_release
    jmp no_key
ESC_release:
    mov [MoveDirect],0
    jmp sof     
   
    
no_key:
    mov [MoveDirect],0
    jmp sof
    
sof:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp GetKey



;*******************************************************
;*PROCEDURE: manage_keys
;*DESCRIPTION: This procedure manage_keys
;*
;* INPUT:
;* ------
;* [MoveDirect]
;* 
;*
;* OUTPUT:
;* -------
;* [player_x]
;* [DELAY]
;*
;*******************************************************
proc manage_keys
    push ax
    push bx
    push cx
    push dx
    push si

    call GetKey                 ;get player keys press/release
    mov ax,[MoveDirect]
    
    cmp ax,MOVE_LEFT            ;left
    je move_left_now
    
    cmp ax,MOVE_RIGHT           ;right
    je move_right_now

    cmp ax,UP                   ;speed up the game speed
    je speed

    cmp ax,DOWN                 ;slow down the game speed
    je slow
 
    cmp ax,N_KEY                ;music on/off
    je togle_music
    
    jmp next                    ;un-configured key pressed or no key pressed (anycase do the delay)

move_left_now:
    mov ax,[player_x]
    dec ax
    mov [player_x],ax
    jmp next

move_right_now:
    mov ax,[player_x]
    inc ax
    mov [player_x],ax
    jmp next
    
speed:
    mov ax,[DELAY]              ;read current delay
    cmp ax,MIN_DELAY            ;compare with minimum delay 0h
    je next                     ;if the delay is smallest, do not reduce it (keep it as is)
    sub ax,DELY_STEP            ;if the delay bigger than 20h substact 10h from it (so the game will run faster)
    mov [DELAY],ax              ;keep the new decreased delay in DELAY variable 
    jmp next
        
slow:
    mov ax,[DELAY]              ;read current delay
    cmp ax,MAX_DELAY            ;if delay is big (equall 600h) do not add to it
    je next         
    add ax,DELY_STEP            ;if the delay is less then 600h, add 10h to it
    mov [DELAY],ax              ;keep the new increased delay in DELAY variable 
    jmp next

togle_music:
    mov ax,[ToggleSound]        ;for each new car toggle between play sound(0) or no sound(1), until the next car draw
    cmp ax,0 
    je  stop_snd
    mov ax,0                     ;play sound
    mov [ToggleSound],ax
    jmp next
   
stop_snd:
    mov ax,1
    mov [ToggleSound],ax
    jmp next  
    
next:
    ; perform the delay
    call DoDelay
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp manage_keys
