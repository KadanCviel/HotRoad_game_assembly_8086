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
;* File Name: Hot_Road.asm
;* Program:     Road Driving Simulator
;*
;* Description: Player need to use right/left arrow keys to avoid crashing 
;*              with other cars or with road margins.
;*              Player can speed up with arrow up(or slow down with arrow down).
;*              Player can exit the game by pressing "Esc" key.
;*              Player start the game by pressing "S" key.
;*              After game ends player can press "R" 
;*              to see top 5 game records (from start game running). 
;*              Each game score & name added to "Records.txt" text file
;*              in the game folder (can be view with notepad).  
;*              "N" key stop/start play tones during the game
;*
;* Prepare by:  Nevo Kadan (2018)
;*
;******************************************************************************
IDEAL
MODEL small
STACK 100h

;------------------------------------------------
DATASEG
;------------------------------------------------  
include 'Vars.asm'


;------------------------------------------------
CODESEG
;------------------------------------------------
include 'BitMap.asm'
include 'Random.asm'
include 'Score.asm'
include 'Keyboard.asm'
include 'Utils.asm'



;*******************************************************
;* MAIN
;*DESCRIPTION: Start & Run the Game
;*
;*
;*
;*******************************************************
start:
    mov ax, @data
    mov ds, ax

    ;Initilazation Graphic mode to 320x200x256 [Width*Height*Color] called "CGA 256" colors
    mov ax,CGA_256_COLOR_MODE   ; for 320x200x256 "CGA 256" colors (13h)
    mov bh,0h                   ;bh=0 page number always 0 for 320x200x256 CGA-256
    int 10h
    
s_loop:
    ; Process Bit Map file
    call show_bitmap
    
    mov [colision],LIFE_FACTOR  ;at startup give 22 colision to the player, each color crash reduce colision by one
    mov si,OFFSET_LIVES_IN_MSG  ;point to right in msg offset of fisrt byte after "Lives:"
    mov al,max_lives            ;start with 9 lives (ascii of digit "9" is 39h)
    mov [msg+si],al             ;update lives value in the msg string
    
    mov [DELAY],INIT_DELAY      ;set delay (speeed) to default (300h)
    
    ;Game openning screen: check if player press "S" to start or "Esc" to exit or "R" to see the record 
next_key:
   
    call DoDelay
    call GetKey                 ;get player keys "S"/"Esc"/"R"
    mov ax,[MoveDirect]         ;take the key press into "ax"

    call DoDelay
    cmp ax,S_KEY                ;"S" pressed then start the game
    je start_game

    call DoDelay
    cmp ax,ESC_KEY              ;"Esc" key press then exit the game
    je zz_exit
    
    call DoDelay
    cmp ax,R_KEY                ;"R" pressed then show records (toggle)
    je show_records
    
    jmp next_key

show_records:
    mov ax,[R_Flag]             ;R_Flag is togle flag;  if (R_Flag==0) show records else show bitmap          
    cmp ax,0
    je Print_Records            ;if (R_Flag==0) show records

; in this case we are printing the bitmap    
    call show_bitmap            ;if (R_Flag==1) show bitmap
    mov [R_Flag],0
    call DoDelay
    jmp next_key
    
; in this case we are showing the records and not printing the bitmap    
Print_Records:
    call display_records
    mov [R_Flag],1
    call DoDelay
    jmp next_key

start_game:
    mov ax,[one_shot]
	cmp ax,1
;	je Initilazation            ;workaround fix, player name entered, does not work for second time. 
                                ;only the first time it works. it is an INT 21 (interrupt) problem. 
                                ;open this jump, skip asking the name after at runtime game end ("Lives:0").
                                ;since some machines can't handle the second CAPTURE STRING FROM KEYBOARD (0Ah) int21,
                                ;and got stuck, by this jump we continue to use the name first entered when
                                ;the game just starded for the new game (the player can start with "S")
	
    mov si,14
init_name:  
    mov [msg+si],20h            ;replace previous name leter with space
    inc si                      ;point to next posible name letter in msg
    cmp si,MAX_OFFSET           ;MAX_OFFSET = 33, max name length is 18 letters (33-14-1=18)
    jnz init_name
    
    ; show to user to enter name
    call ShowInputName
    
    ; get from keyboard the user name
    ; AH = 0Ch - FLUSH BUFFER AND READ STANDARD INPUT
    ;mov al,01h                 ;function to call after FLUSH performed (01h=keyboard input with echo) lose the first letter the user typed
    mov al,00h                  ;do not lose the first letter the user typed
    mov ah,CLEAR_KB_DATA        ;clear Keyboard and do Function
    int 21h
        
    ;CAPTURE STRING FROM KEYBOARD.  
    ;see  https://stackoverflow.com/questions/29504516/getting-string-input-and-displaying-input-with-dos-interrupts-masm
    mov ah,GET_STRING_FROM_KB  ;SERVICE TO CAPTURE STRING FROM KEYBOARD. (0Ah)
    mov dx, offset buff
    int 21h   
    
    ;reurn buff format is:  http://stanislavs.org/helppc/int_21-a.html
    ;| max | count |  BUFFER (N bytes)
    ;   |     |     `------ input buffer
    ;   |     `------------ number of characters returned (byte)
    ;   `-------------- maximum number of characters to read (byte)
    
    mov al, [buff+1]            ;number of return characters
    sub al,MAX_PLAYER_NAME      ; check if al is bigger then 17
    jg fix_len                  ; if yes (greater then 17) then take only first 17 letters
    mov al, [buff+1]            ; if NO less then 18 letters, take again the length into al
    jmp start_cpy

zz_exit:
    jmp exit    
    
fix_len:
    mov al,MAX_PLAYER_NAME      ;fix name to the first 17 letters

start_cpy:  
    mov si,OFFSET_FIRST_IN_CHAR ;offset of first input char 

name_loop:  
    mov bl, [buff+si]           ;copy char from input buff to reg bl
    mov di , si                 
    add di,OFFSET_PRINT_NAME    ;point to output offset (after "Score:0000000")
    mov [msg+di], bl            ;copy the character to the output string
    
    inc si
    dec al
    jnz name_loop
    
Initilazation:
    mov [one_shot],1
    mov [LINE_COUNT],LINE_CAR   ;per how many road lines add a new car
    mov [player_x],INIT_PLAYER_X;player vehical X position
     
    mov [RANGE],Z_RANGE         ;for road hop Z_RANGE is  108
    mov [BASE],Z_BASE           ;for road hop Z_BASE is 80
    call Seed_Random            ;create new value for random
    call MakeRandomNumber       ;make random number between BASE and BASE+RANGE
    mov ax,[R_RND]              ;get random result into AX
    mov [Hop],ax                ;store AX in "Hop" equall to random  number in range[80,188] for zig length 
    
    mov ax,[RandomNumber]       ;take lower byte from random 
    mov [z_color],al            ;to be the next line boarder color

    call MakeRoad               ;draw the first three road "zigs" always at the same place
    
    call ShowScore              ; show initial Score:00000000 player_name & Lives:9
    
    ;For Main body we need to continue the road - (since at start of the game the road is already drawn) 
    mov [Xcord],START_X         ;X start with top line left road pixel 
    mov [Direction],RIGHT       ;RIGHT => 1 = adding (+1) to the Xcord (always starting with adding) 
                                ;Note: 0 => substact (-1) to the Xcord                                
Main_Game_Loop:
    call calculate_new_x_cord_for_road_add_line

    call DrawTopLine            ;draw road new upper line
    
    call RandomCar              ;draw a new random car every(40-71)lines (default 40 line)
                                
    ;move the screen one line down (copy line 198->199, 197->198, 196->197, ...  9->10). 
    ;and set all pixels in line 9 to black
    call ScreenMovement         ;move the screen one line down

    call CalcScore              ;every 50 lines add "125" to score and change background color

    call CheckIfCrashed         ;chaeck if player crashed (after screen is scroll down one line, detect any pixel overlap on player vehical)
    
    cmp [Crash_Detect],CRASH_DETECTED      ;if car crashed reduce lives
    je Temp_start               ;"Temp_start" reduce [lives] and check if it reaches zero   
    jmp Game_continue

    ; handle crashes    
Temp_start:
    mov [Crash_Detect],0h       ;handle the crash, clean the crash indicator 
    mov bx,[colision]           ;read current lives value
    dec bx                      ;decrement lives value by one
    mov [colision],bx
    cmp bx,0                    ;if reaches 0 then no more lives
    je game_reduce_live
 
Game_continue:
    
    call manage_keys            ;handle player keys
    
    call DrawPlayer             ;there was no colosions at all, so draw the player
    
    mov ax,[MoveDirect]
    cmp ax,ESC_KEY              ;ESC key exit the game
    je exit

    jmp Main_Game_Loop          ;repeat the  MAIN GAME LOOP 

game_reduce_live:   
    ;if live is not "0", reduce it by one, and show it
    mov [colision],LIFE_FACTOR  ;22 lines overlap means "colisions"
    mov si,OFFSET_LIVES_IN_MSG  ;point to right byte in msg of lives (at offset 39 bytes from start)
    mov al,[msg+si]             ;read msg most right byte (contains "Lives" value) to "al"
    dec al
    mov [msg+si],al             ;store the new decremented digit    
    cmp al,DIGIT_0              ;if "lives" counter reach zero "0x30" goto restart the game
    je game_restart
    call ShowScore              ;update score and lives in screen header
    jmp Game_continue   
    
game_restart:
    
    
    ; close the speaker - stop sound   
    in  al,61h    
    and al,11111100b  
    out 61h,al  
       
    ;write records
    call OpenRecordsFile
    call WriteRecordsFile ;msg
    call CloseRecordsFile      
    
    call add_last_game_score_and_name
    
    mov [DELAY],INIT_DELAY      ;set delay (speeed) to default (300h)
    mov si,OFFSET_LIVES_IN_MSG  ;point to right (start with most right) byte in msg 
    mov al,max_lives            ;start with 9 lives (ascii of digit "9" = 39h)
    mov [msg+si],al             ;write to right most of "msg" lives a "9"
    call ZeroScore
    jmp s_loop  
    
exit: 
    ; close the speaker - stop sound   
    in  al,61h    
    and al,11111100b  
    out 61h,al  

    mov ax,CHANGE_TO_TEXT_MODE  ;change to TEXT MODE (text 80 x 25 16 color)
    mov bh,0h                   ;bh=0 page number always 0 for 320x200x256 CGA-256
    int 10h
    mov ax, EXIT_PROGRAM        ;exit from the program to command prompt
    int 21h
END start