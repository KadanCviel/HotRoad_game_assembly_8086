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
;* File Name: Utils.asm
;* Program:   Road Driving Simulator
;*
;* Description: Utils Manager (drawing elements, delay, etc`)
;*  
;* Prepare by:  Nevo Kadan (2018)
;*
;******************************************************************************



;*******************************************************
;*PROCEDURE: MakeRoad
;*DESCRIPTION: This procedure draw initial road
;*
;* INPUT:
;* ------
;* [XL]
;* [YL]
;* [x_color]
;* [x_width]
;*
;* OUTPUT:
;* -------
;* \          \
;*  \          \
;*  /          /
;* /          /
;* \          \
;*  \          \
;*******************************************************
proc MakeRoad
    push ax
    push bx
    push cx
    push dx
    push si
    ;move to graphic mode - (it clean the bitmap)
    mov al,CGA_256_COLOR_MODE  ;320x200x256 "CGA-256"
    mov ah,0
    int 10h
    
start_road: 
    mov [Xcord],START_X         ;X-init
    mov [Ycord],Y_TOP           ;Y-init
    mov cx,[Xcord]              ;set X
    mov dx,[Ycord]              ;set Y
    
    ;Draw screen top upper Zig line Road boarders
LoopDrawUpperZig:
    ; Draw the LEFT road side
    mov [XL],cx                 ;set X
    mov [YL],dx                 ;set Y
    mov [x_color],YELLOW        ;set color for "Draw_Horizontal_Line" procedure
    mov [x_width],LINE_WIDTH    ;left road margin, set line width  for "Draw_Horizontal_Line" procedure
    call Draw_Horizontal_Line   ;Left margin Drawline from (X,Y) to (X+LINE_WIDTH,Y)        
    ;Draw the RIGHT road side
    add cx,ROAD_WIDTH           ;add to road start (XL) thw road width, to set the right road side
    mov [XL],cx                 ;set X
    mov [x_color],YELLOW        ;set color for "Draw_Horizontal_Line" procedure
    mov [x_width],LINE_WIDTH    ;left road margin, set line width  for "Draw_Horizontal_Line" procedure
    call Draw_Horizontal_Line   ;Right margin Drawline from (X+ROAD_WIDTH,Y) to (X+ROAD_WIDTH+LINE_WIDTH,Y)     
                                ;Prepare the next X of upper Zig
    sub cx,ROAD_WIDTH
    inc cx                      ;inc for next X
    mov [XL],cx 
                                ;Prepare next Y of Upper Zig
    inc dx                      ;inc for next Y 
    cmp dx,ZIG1_LEN             ;stop when Y (dx) reaches ZIG_LEN(60) value
    je EndUpperzig  
    jmp LoopDrawUpperZig
EndUpperzig: 

    ;draw Midle upper Zig
LoopDrawMiddleZig:
    ; - LEFT road side
    mov [XL],cx                 ;set X
    mov [YL],dx                 ;set Y
    mov [x_color],YELLOW        ;set color for "Draw_Horizontal_Line" procedure
    mov [x_width],LINE_WIDTH    ;left road margin, set line width  for "Draw_Horizontal_Line" procedure 
    call Draw_Horizontal_Line   ;Left margin Drawline from (X,Y) to (X+LINE_WIDTH,Y)        
                                ;- RIGHT road side
    add cx,ROAD_WIDTH           ;add ROAD_WIDTH to set the right road side
    mov [XL],cx                 ;set X
    mov [x_color],YELLOW        ;set color for "Draw_Horizontal_Line" procedure
    mov [x_width],LINE_WIDTH    ;left road margin, set line width  for "Draw_Horizontal_Line" procedure 
    call Draw_Horizontal_Line   ;Right margin Drawline from (X+ROAD_WIDTH,Y) to (X+ROAD_WIDTH+LINE_WIDTH,Y)
    sub cx,ROAD_WIDTH   
    ;---- prepare the next X
    dec cx                      ;for next X 
    ;--- prepare next Y
    inc dx                      ;for next Y 
    cmp dx,ZIG2_LEN             ;stop when Y==ZIG2_LEN(120)
    je EndDrawMiddleZig 
    jmp LoopDrawMiddleZig   
EndDrawMiddleZig: 

    ;draw  lower Road
LoopDrawLowerZig:
    ; - LEFT road side
    mov [XL],cx                 ;set X
    mov [YL],dx                 ;set Y
    mov [x_color],YELLOW        ;set color for "Draw_Horizontal_Line" procedure
    mov [x_width],LINE_WIDTH    ;left road margin, set line width  for "Draw_Horizontal_Line" procedure
    call Draw_Horizontal_Line    ;Left margin Drawline from (X,Y) to (X+LINE_WIDTH,Y)
    ; - RIGHT road side
    add cx,ROAD_WIDTH           ;add ROAD_WIDTH to set the right road side
    mov [XL],cx                 ;set X
    mov [x_color],YELLOW        ;set color for "Draw_Horizontal_Line" procedure
    mov [x_width],LINE_WIDTH    ;left road margin, set line width  for "Draw_Horizontal_Line" procedure
    call Draw_Horizontal_Line   ;Right margin Drawline from (X+ROAD_WIDTH,Y) to (X+ROAD_WIDTH+LINE_WIDTH,Y) 
    sub cx,ROAD_WIDTH
    ;---- prepare the next X
    inc cx  ; for next X    
    ;--- prepare next Y
    inc dx     ; for next Y
    cmp dx,ZIG3_LEN             ;stop when Y==ZIG3_LEN(180)
    je EndDrawLowerZig
    jmp LoopDrawLowerZig 
EndDrawLowerZig: 
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp MakeRoad



;*******************************************************
;*PROCEDURE: Draw_Horizontal_Line
;*DESCRIPTION: This procedure adds a margin to the road 
;*             each call use to draw left margin (or right margin) 
;*             usw [XL] as start pixel position and end after x_width pixel on same [YL]
;*             summary: Drawline from (XL,YL) to (XL+x_width,YL)
;*
;* INPUT:
;* ------
;* [YL]
;* [XL]
;* [x_color]
;* [x_width]
;*
;* OUTPUT:
;* -------
;*
;*
;*
;*******************************************************
proc Draw_Horizontal_Line
    push ax
    push bx
    push cx
    push dx
    push si
    mov dx,[YL]                 ;Y
    mov cx,[XL]                 ;X
    mov bx,0                    ;need to set bh=0h for page number always 0 for 320x200x256 CGA-256 
    mov si,0                    ;set counter of line width to zero
LoopDrawMargin:
    mov ah,SET_PIXEL_COLOR      ;for pixel drawing    
    mov al,[x_color]            ;color 
    int 10h
    inc cx                      ;X=X+1
    inc si                      ;inc counter of line width
    cmp si,[x_width]
    je ExitDrawMargin
    jmp LoopDrawMargin          ;loop through all x points  
ExitDrawMargin:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp Draw_Horizontal_Line



;*******************************************************
;*PROCEDURE: ScreenMovement
;*DESCRIPTION: This procedure shifts the screen one line down
;*             it start to work on pixels below the SCORE name & LIVES: (with Y>9)
;*
;* INPUT:
;* ------
;*VIDEO_MEM_STRT
;*OFFSET_LAST_LN
;*
;* OUTPUT:
;* -------
;*
;*
;*
;*******************************************************
proc ScreenMovement
    push ax
    push bx
    push cx
    push dx
    push si
    mov ax,VIDEO_MEM_STRT       ;start video memory segment address 0A000h
    mov es,ax
    mov di,OFFSET_LAST_LN       ;point to the start of line above last line at buttom of display (199-1)*320 = 64000-320
loop_shft: 
    mov al,[es:di]              ;get color of the pixel
    mov si,di                   ;copy the position from were to copy "orig'"
    add si,PIXELS_IN_LINE       ;"taget offset" si is now point one line below the "di" orig offset
    mov [es:si], al             ;change color of "taget" pixel same as "orig" pixel one line above
    dec di                      ;move one pixel back, go from last pixel button to fist pixel of display
    cmp di,LINE_9_OFFSET        ;320*9=2880 stop at Y cord = 9
    jnz loop_shft
    
    ; Clean the to top most line by set all the top line pixels to black 
    mov ax,Y_TOP
    mov [TOP_Y],ax    
    call CleanTopLine
    
EndLine:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp ScreenMovement



;*******************************************************
;*PROCEDURE: CleanTopLine
;*DESCRIPTION: This procedure clear pixel from (0,0) to (319,0) top line
;*            
;*
;* INPUT:
;* ------
;*VIDEO_MEM_STRT
;*OFFSET_LAST_LN
;*
;* OUTPUT:
;* -------
;*
;*
;*
;*******************************************************
proc CleanTopLine
    push ax
    push bx
    push cx
    push dx
    push si

    ; Clean the to top most line by set all the top line pixels to black
    mov ah,SET_PIXEL_COLOR      ;for pixel set
    mov al,0                    ;color 0 is black (to erase all pixels in the line)
    mov bx,0                    ;need to set bh=0h for page number always 0 for 320x200x256 CGA-256 
    mov dx,[TOP_Y]              ;usually set Y=9 from "ScreenMovement"  (or set Y to 0 form "show_bitmap") 
    mov di,0                    ;pixel X position counter 
LoopClsTop:
    mov cx,di                   ;set X
    int 10h                     ;draw(X, Y) CLS the pixel
    inc di                      ;add 1 to X 
    cmp di,MAX_X                ;stop when X==319 (since we start from 0 offset)
    je EndClean
    jmp LoopClsTop 

EndClean:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp CleanTopLine



;*******************************************************
;*PROCEDURE: RandomCar
;*DESCRIPTION: This procedure "create" a car after 30-61 pixel lines drawings
;*
;* INPUT:
;* ------
;* [LINE_COUNT]
;* [Xcord]
;* [CarX]
;* [CarColor]
;* RndCar
;*
;* OUTPUT:
;* -------
;*
;*
;*
;*******************************************************
proc RandomCar
    push ax
    push bx
    push cx
    push dx
    push si 
    
    mov bx,[LINE_COUNT]         ;every(30-61)lines add new car (default 40 line) 
    dec bx                      ;dec LINE_COUNT by one
    cmp bx,0                    ;if counter is zero jump to CreateCar
    je CreateCar                ;
    mov [LINE_COUNT],bx         ;store new reduced counter
    jmp ExitRandomCar           ;exit the procedure

CreateCar:    
    mov ax,[ToggleSound]        ;for each new car if [ToggleSound]==0 play sound (if [ToggleSound]==1 close the speaker)
    cmp ax,0                    ;if [ToggleSound] is "0" play  sound 
    je Play_Sound   

Stop_Sound:                      ;when [ToggleSound] is 1 so stop the sound  
    ; close the speaker - stop sound   
    in  al,61h    
    and al,11111100b  
    out 61h,al   
    jmp ShowCar
    
Play_Sound: 
    ;open speaker  - start sound  
    in  al, 61h    
    or  al, 00000011b  
    out 61h,al              
    mov al,0B6h                 ;send control word to change frequency 
    out 43h,al      
    call Randomize              ; call radomize rsult in [RandomNumber]
    mov ax, [RandomNumber]
;    and ax,03FFFh              ; 3fffh=16383 ## 1,193,180/16,383= 72[Hz] 
    and ax,01FFFh               ; 1fffh=8191  ## 1,193,180/8191= 145[Hz] 
;   add ax,77h                  ;77h=119      ## 1,193,180/119=10K[Hz]
;   add ax,44h                  ;77h=68       ## 1,193,180/68=17.5K[Hz]
;   add ax,95h                  ;95h=149      ## 1,193,180/149=8K[Hz]
;   add ax,0C6h                 ;0C6h=198     ## 1,193,180/98=6K[Hz] 
;   add ax,012Ah                ;012Ah=298    ## 1,193,180/298=4K[Hz] 
    add ax,0254h                ;0254h=596    ## 1,193,180/596=2K[Hz]    
    out 42h,al                  ;Sending lower byte  
    mov al,ah 
    out 42h,al                  ;Sending upper byte 

    
ShowCar:    n
   ;random use to line separate between the cars
    mov [RANGE],CAR_SEP_RANGE   ;for RANGE is 31
    mov [BASE],CAR_SEP_BASE     ;for BASE is 30
    call MakeRandomNumber       ;make rnadom number between BASE and BASE+RANGE
    mov ax,[R_RND]              ;random use to line separate between the cars, number in range (30,61)
    mov [LINE_COUNT],ax         ;starting count again for the next car to be show  
    mov [CarY],Y_TOP            ;loop from 9 to 30 (total 21 lines) to draw the car
    mov [CarColor],0            ;hold the pixel color to  from car color arry "RndCar" random cars computer add

    ; want random car X cord start in between 40 to 130 (130-40=90) offset 90 + base 40 
    mov [RANGE],CAR_POS_RANGE   ;we want value more in center - use 90.
    mov [BASE],CAR_POS_BASE     ;we want value more in center - use 40.
    call MakeRandomNumber       ;make random number between BASE and BASE+RANGE
    mov ax,[R_RND]              ;random car X cord start , number in range (30,61)  
    mov [MID_ROAD],ax           ;offset to random middle of road    
    
loopYCar:
    mov bx,[CarY]               ;get last Y value
    inc bx                      ;inc Y (first Y will be line 1 (Y=1)
    mov [CarY],bx               ;store Y in "CarY"
    cmp [CarY],CAR_HEIGHT       ;if we reach 30 then exit car draw
    je ExitRandomCar
    mov dx,[CarY]               ;Set Y - cord
    mov [CarX],0                ;init the X-cord offset
    mov bh,0h                   ;bh=0 page number always 0 for 320x200x256 CGA-256
    mov si,0                    ;X=0
loopXCar:
    mov si,[Xcord]              ;get left postion
    add si,[MID_ROAD]            ;add offset to middle of road      
    add si,[CarX]               ;add ofset from start of car
    mov cx,si                   ;set X - Cord for drawing pixel
    mov ah,SET_PIXEL_COLOR      ;for pixel set
    mov si,[CarColor]           ;get car color offset from start of car color arry "RndCar"
    inc si                      ;move to the next offset (+1)
    mov [CarColor],si           ;store the next offset 
    mov si,offset RndCar        ;move to "si" the start of color arry "RndCar"
    add si,[CarColor]           ;add to "si" the offset from where to take the color
    mov al,[si]                 ;set Color into al
    int 10h                     ;Draw(X,Y,C)
    mov si,[Carx]               ;get current "x" offset (0-20) to "si"
    inc si                      ;inc si from x to x+1
    mov [CarX],si               ;store "si" in "CarX" for next pixel
    cmp [Carx],CAR_WIDTH        ;if we reach 20 the need to nove to next car line
    je loopYCar                 ;move to next line "Y"
    jmp loopXCar                ;stay in the same "X" line, draw the next car pixel
ExitRandomCar:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
endp RandomCar



;*******************************************************
;*PROCEDURE: DrawPlayer
;*DESCRIPTION: This procedure draw the player vehical
;*
;* INPUT:
;* ------
;* [player_x]
;* [CarX]
;* [CarColor]
;*
;* OUTPUT:
;* -------
;*
;*
;*
;*******************************************************
proc DrawPlayer
    push ax
    push bx
    push cx
    push dx
    push si
    mov [CarY],0                ;loop from 0 to 20 for all lines
    mov [CarColor],0            ;will hold the pixel color to from car color arry "CarColor" player vehical 
loopY_Player:
    mov bx,[CarY]               ;get last Y value
    inc bx                      ;inc Y (first Y will be line 1 (Y=1)
    mov [CarY],bx               ;store Y in "CarY"
    cmp [CarY],PLAYER_HEIGHT    ;if we reach 23 then exit car draw
    je ExitDrawPlayer
    mov dx,[CarY]               ;Set Y - cord
    add dx,PLAYER_Y             ;Add Player Y offset Cord to "dx"
    mov [CarX],0                ;init the X-cord offset
    mov bh,0h                   ;bh=0 page number always 0 for 320x200x256 CGA-256
    mov si,0                    ;player X position
loopX_Player:
    mov si,[player_x]           ;get left postion
    add si,[CarX]
    mov cx,si                   ;set X - Cord for drawing pixel
    mov ah,SET_PIXEL_COLOR      ;for pixel set
    mov si,[CarColor]           ;get player car color offset from start of car color arry "player"
    inc si                      ;inc si from x to x+1
    mov [CarColor],si           ;store "si" in "CarX" for next pixel
    mov si,offset player        ;move to "si" the start of player color arry "player"
    add si,[CarColor]           ;add to "si" the offset from where to take the color
    mov al,[si]                 ;set Color into al 
    int 10h                     ;Draw(X,Y,C)
    mov si,[CarX]               ;get current "x" offset (1-22) to "si"
    inc si                      ;inc si from x to x+1
    mov [CarX],si               ;store "si" in "CarX" for next pixel
    cmp [Carx],PLAYER_WIDTH     ;if we reach 12 the need to nove to next car line
    je loopY_Player             ;move to next line "Y"
    jmp loopX_Player            ;stay in the same "X" line, draw the next car pixel
ExitDrawPlayer:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp DrawPlayer



;*******************************************************
;*PROCEDURE: CheckIfCrashed
;*DESCRIPTION: This procedure check if the player crashed
;*
;* INPUT:
;* ------
;* [player_x]
;* [CarX]
;*
;* OUTPUT:
;* -------
;* [Crash_Detect]
;*
;*
;*******************************************************
proc CheckIfCrashed
    push ax
    push bx
    push cx
    push dx
    push si
    
    ;check if any of the "black" pixels surownded the player car are not black, if yes we got a "crash"
    ;first look at the pixels above the car "top" to see if after scroll down some pixels are not black
    ;for example if random computer car scroll down into the player vehicle area
    ;or road border after the scroll down enter to "top" line of player vehicle
    ;NOTE: in porpose we set all pixels edge surownding the player car to be black so it will be easy
    ;       to check if any of them change color from black to something else
    mov dx,PLAYER_Y             ;set player upper left Y position into "dx"
    mov [CarX],0                ;set "CarX" offset to 0
    mov bh,0h                   ;bh=0 page number always 0 for 320x200x256 CGA-256
    mov si,0                    ;player X position
    
loopXcord_Player:
    mov si,[player_x]           ;get left position "player_x" as base to start from
    add si,[CarX]               ;add "CarX" offset to Base "player_x" to get X cord in display
    mov cx,si                   ;set X-Cord into "cx"
    mov ah,GET_PIXEL_COLOR      ;get pixel color
    int 10h                     ;get color from (X,Y)
    mov [CheckColor],al         ;store "al" in "CheckColor" the color from (X,Y)"          
    cmp [CheckColor],0          ;comapre the color to back (0)
    jne GotCrashed              ;if color is not black, then we have "crash"
    mov si,[CarX]               ;read the current offset again 
    inc si                      ;move to next X offset position (X+1)
    mov [CarX],si               ;store the next X offset position into "Carx"
    cmp [Carx],PLAYER_WIDTH     ;if "CarX" reached 12, it mean we did not find a crash in the "player" top line
    je CheckPlayerSides
    jmp loopXcord_Player

    ;we will check player left & right side to see if color chnage and we go a crash
CheckPlayerSides:
    mov si,PLAYER_Y             ;take current player Y cord
    add si,MAX_PLAYER_HEIGHT    ;add 18 to get max Y cord of player (for comparing)
    mov dx,PLAYER_Y             ;set player upper left Y position into "dx"
    mov cx,[player_x]           ;get left position "player_x" as base to start from
    dec cx
player_left_side_crash: 
    inc dx                      ;check (Y+1) position ("cx" from previous step)
    mov ah,GET_PIXEL_COLOR      ;get pixel color
    int 10h                     ;get color from (X,Y)
    mov [CheckColor],al         ;store "al" in "CheckColor" the color from (X,Y)"          
    cmp [CheckColor],0          ;comapre the color to back (0)
    jne GotCrashed              ;if color is not black, then we have "crash"
    cmp dx,si                   ;if "Y" added 23, it mean we did not find a crash in the "player" left side
    je CheckPlayerRightSide
    jmp player_left_side_crash

CheckPlayerRightSide:
    mov dx,PLAYER_Y             ;set player upper left Y position into "dx"
    inc dx
    mov si,dx                   ;take current player Y cord
    add si,MAX_PLAYER_HEIGHT    ;add 18 to get max Y cord of player
    mov cx,[player_x]           ;get X left position "player_x" as base to start from
    add cx,MAX_PLAYER_WIDTH     ;add "CarX" width add to "player_x" to get X cord in display of right side
    inc cx
player_right_side_crash:    
    inc dx                      ;check (Y+1) position ("cx" from previous step)
    mov ah,GET_PIXEL_COLOR      ;get pixel color
    int 10h                     ;get color from (X,Y)
    mov [CheckColor],al         ;store "al" in "CheckColor" the color from (X,Y)"          
    cmp [CheckColor],0          ;comapre the color to back (0)
    jne GotCrashed              ;if color is not black, then we have "crash"
    cmp dx,si                   ;if "Y" added 23, it mean we did not find a crash in the "player" right side
    je ExitDrawCrash
    jmp player_right_side_crash

GotCrashed:
    mov [Crash_Detect],CRASH_DETECTED ;set "Crash_Detect" to 1
    
ExitDrawCrash:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp CheckIfCrashed



;*******************************************************
;*PROCEDURE: ShowInputName
;*DESCRIPTION: This procedure show text message in graphics mode
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
proc ShowInputName
    push ax
    push bx
    push cx
    push dx
    push si
    
    ;https://stackoverflow.com/questions/43435403/i-am-trying-to-print-a-message-in-graphic-mode-in-assembly-but-the-console-d-i?rq=1
    mov si,@data                ;moves to si the location in memory of the data segment

    mov ah,PRINT_GRAPHICS_MODE  ;service to print string in graphic mode 13h
    mov al,0                    ;sub-service 0 all the characters will be in the same color(bl) and cursor position is not updated after the string is written
    mov bh,0                    ;page number=always zero
    mov bl,TEXT_COLOR           ;color of the text (white foreground and black background)
                                ;     0000             1111
                                ;|_ Background _| |_ Foreground _|
                                ;

    mov cx,STRING_LEN_42        ;length of string
                                ;resoultion of the screen is 320x200
    mov dh,0                    ;y coordinate
    mov dl,0                    ;x coordinate
    mov es,si                   ;moves to es the location in memory of the data segment
    mov bp,offset enter_name    ;mov bp the offset of the string
    int 10h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp ShowInputName



;*******************************************************
;*PROCEDURE: DrawTopLine
;*DESCRIPTION: This procedure add to the road at top
;*             a new line with varing backgroup color
;*
;* INPUT:
;* ------
;* [z_color]
;* [Xcord]
;*
;* OUTPUT:
;* -------
;* 
;*
;*
;*******************************************************
proc DrawTopLine
    push ax
    push bx
    push cx
    push dx
    push si
    
    ;background left side of the road, from screen start(x=0) to left road margin(XL)
    mov ah,SET_PIXEL_COLOR      ;for drawing
    mov al,[z_color]            ;change color (occured every 50 lines)
    mov [x_color],al
    mov bx,[Xcord]              ;set Xcord to new value incremented of the left point
    mov [x_width],bx            ;bx=Xcord has the start of the road margin X-cord - which is the width for left boarder
    mov [XL],0                  ;set X
    mov dx,Y_TOP                ;set Y to 9
    mov [YL],dx                 ;set Y
    call Draw_Horizontal_Line   ;Draw_Horizontal_Line from (XL,YL) to (XL+x_width,YL)
    
    ; draw left road margin pixels
    mov [x_color],YELLOW        ;color is yello
    mov [x_width],LINE_WIDTH    ;line width of road margin is 10
    mov dx,Y_TOP                ;set Y to 9
    mov [XL],bx                 ;set XL=Xcord to new value incremented of the left point
    call Draw_Horizontal_Line   ;Draw_Horizontal_Line from (X,Y) to (X+LINE_WIDTH,Y)
    
    ; draw the right road margin pixels
    mov [x_color],YELLOW        ;color is yello
    mov [x_width],LINE_WIDTH    ;line width of road margin is 10
    mov bx,[XL]
    add bx,ROAD_WIDTH           ;bx=Xcord+ROAD_WIDTH , point to the left point (to reach to the right point)
                                ;set Xcord with new value of the right point
    mov [XL],bx                 ;set XL = Xcord+ROAD_WIDTH
    call Draw_Horizontal_Line   ;Draw_Horizontal_Line from (X,Y) to (X+LINE_WIDTH,Y)    

    mov al,[z_color]            ;change color (occured every 50 lines)
    mov [x_color],al
    mov cx,[XL]                 ;set Xcord to new value incremented of the left point
    add cx, LINE_WIDTH          ;cx =  Xcord+ROAD_WIDTH+LINE_WIDTH
    mov [XL],cx                 ;set XL
    mov bx,MAX_X                ;put 319 max x cord into bx
    sub bx,cx                   ;bx = (bx - cx) = MAX_X-(Xcord+ROAD_WIDTH+LINE_WIDTH)=319-Xcord-172-10=137-Xcord
    mov [x_width],bx            ;bx has the right boarder width
    call Draw_Horizontal_Line   ;Draw_Horizontal_Line from (X,Y) to (X+LINE_WIDTH,Y)
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp DrawTopLine



;*******************************************************
;*PROCEDURE: DoDelay
;*DESCRIPTION: This procedure perform the delay
;*
;* INPUT:
;* ------
;* [DELAY]
;*
;*
;* OUTPUT:
;* -------
;*
;*
;*
;*******************************************************
proc DoDelay
    push ax
    push bx
    push cx
    push dx
    push si
 

    mov bx, [DELAY]
dly_b:  
    mov ax,[DELAY]
dly_a:
    dec ax
    nop
    nop
    nop
    cmp ax,0
    jg dly_a
    dec bx
    jg dly_b


    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp DoDelay



;*******************************************************
;*PROCEDURE: calculate_new_x_cord_for_road_add_line
;*DESCRIPTION: This procedure calculate the left side for new road line X cord
;*
;* INPUT:
;* ------
;* [Direction]
;* [Xcord]
;* [Hop]
;*
;* OUTPUT:
;* -------
;* [Direction]
;* [Hop]
;*
;*******************************************************
proc calculate_new_x_cord_for_road_add_line
    push ax
    push bx
    push cx
    push dx
    push si

    mov ax,[Direction]
    cmp ax,RIGHT                ;check adding state
    jz Adding
    
    ;***************************
    ; SUBSTRACT STATE
    ;***************************
    
    mov ax,[Xcord]
    cmp ax,MIN_X_CORD           ;minimum of left road boarder , if reached need to change direction 
    jz SwitchToAdding
    
    ; decrease the randum numer "Hop", if it reached zero need to change direction
    mov ax,[Hop]
    dec ax                      ;dec the randum
    mov [Hop],ax                ;to change the hop to actually be random
    cmp ax,0                    ;if it reached to zero, switch direction
    je SwitchToAdding

    mov ax,[Xcord]
    dec ax                      ;substract one to the left  road boarder
    mov [Xcord],ax              ;store the new boarder in Xcord of later use
    jmp exit_proc
     
SwitchToAdding:
    ; generate new random
    mov [RANGE],Z_RANGE         ;for road hop Z_RANGE is  108
    mov [BASE],Z_BASE           ;for road hop Z_BASE is 80
    call MakeRandomNumber       ;make rnadom number between BASE and BASE+RANGE
    mov ax,[R_RND]              ;get random result into AX
    mov [Hop],ax                ;store AX in "Hop"
    mov [Direction], RIGHT      ;we were in susstact(0) we change direction to adding(RIGHT=1) 
    jmp exit_proc   
    

Adding:  
    ;***************************
    ; ADDING STATE
    ;***************************
    ; decrease the random numer, if it reached zero, need to change direction

    mov ax,[Xcord]              ;check if we reach maximum right limit
    cmp ax,MAX_X_CORD           ;maximum of right road boarder, define when we need to change direction 
    jz  SwitchToSubstract

    mov ax,[Hop]
    dec ax                      ;dec the randum
    mov [Hop],ax                ;store decrement random for next round
    cmp ax,0                    ;if it reached zero, switch direction
    jz SwitchToSubstract
    
    mov ax,[Xcord] 
    inc ax                      ;add one to the left  road boarder
    mov [Xcord],ax              ;store the new boarder in Xcord of later use
    jmp exit_proc   


SwitchToSubstract:
    ; generate new random
    mov [RANGE],Z_RANGE         ;for road hop Z_RANGE is  108
    mov [BASE],Z_BASE           ;for road hop Z_BASE is 80
    call MakeRandomNumber       ;make rnadom number between BASE and BASE+RANGE
    mov ax,[R_RND]              ;get random result into AX
    mov [Hop],ax                ;store AX in "Hop"
    mov [Direction], LEFT       ;we were in adding(1) we change direction to substarct(0)

exit_proc:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp calculate_new_x_cord_for_road_add_line