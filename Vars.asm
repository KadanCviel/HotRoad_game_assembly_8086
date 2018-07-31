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
;* File Name: Vars.asm
;* Program:   Road Driving Simulator
;*
;* Description: Variables & Constants
;*  
;* Prepare by:  Nevo Kadan (2018)
;*
;******************************************************************************

 
CarX                       dw  0                  ;use in bit array as car offset from its starting X cord (for player 0 to 12/ for computer 0 to 20)
CarColor                   dw  0                  ;use in bit array as car color
CheckColor                 db  0                  ;store  in "CheckColor" the color from (X,Y)"
CarY                       dw  0                  ;Y value to draw the car
Xcord                      dw  0                  ;X value start at top line left road pixel location
Ycord                      dw  0                  ;Y value where to start shift one line down scroll (always 9)
Color                      db  0                  ;use in bit array as car color
XL                         dw  0                  ;draw a line: start X pixel position 
YL                         dw  0                  ;draw a line: Y pixel position
LINE_COUNT                 dw  40                 ;value to init counter for the next car to be show (40)
DELAY                      dw  300h               ;current DELAY value
INIT_DELAY                 equ 300h               ;DELAY initial value
DELY_STEP                  equ 10h                ;DELAY steps
MIN_DELAY                  equ 0h                 ;DELAY minimum value
MAX_DELAY                  equ 600h               ;DELAY maximum value
;note                       dw  2394h             ;1193180 / 131 -> (hex) 
Direction                  dw  0                  ;ROAD X: toggle add/sub (1=RIGHT add one road start)/(0=LEFT dec one road start)
RIGHT                      equ 1                  ;ROAD X: (1=RIGHT add one road start)
LEFT                       equ 0                  ;ROAD X:(0=LEFT dec one road start)
START_X                    equ 11                 ;X start with top line left road pixel 
LINE_WIDTH                 equ 10                 ;left(and right) sides road margin line width
ROAD_WIDTH                 equ 172                ;road width, size of the black area between the two orange road margins
ZIG1_LEN                   equ 60                 ;ROAD INIT - first  zig length
ZIG2_LEN                   equ 120                ;ROAD INIT - second zig length
ZIG3_LEN                   equ 180                ;ROAD INIT - third  zig length
MID_ROAD                   dw  86                 ;offset to middle of road
UP_ON                      equ 048h               ;KEYS: arrow up press
UP_OFF                     equ 0c8h               ;KEYS: arrow up release
DOWN_ON                    equ 050h               ;KEYS: arrow down press
DOWN_OFF                   equ 0d0h               ;KEYS: arrow down release
LEFT_ON                    equ 04Bh               ;KEYS: arrow left press
LEFT_OFF                   equ 0cBh               ;KEYS: arrow left release
RIGHT_ON                   equ 004Dh              ;KEYS: arrow right press
RIGHT_OFF                  equ 0cDh               ;KEYS: arrow right release
S_ON                       equ 001fh              ;KEYS: "S" key press
S_OFF                      equ 009fh              ;KEYS: "S" key elease
ESC_ON                     equ 001h               ;KEYS: "Esc" key press
ESC_OFF                    equ 081h               ;KEYS: "Esc" key release
R_ON                       equ 013h               ;KEYS: "R" key press
R_OFF                      equ 093h               ;KEYS: "R" key release
N_ON                       equ 031h               ;KEYS: "N" key press
N_OFF                      equ 0B1h               ;KEYS: "N" key release
MOVE_LEFT                  equ 1                  ;KEYS MANAGER: player move to the left
MOVE_RIGHT                 equ 2                  ;KEYS MANAGER: player move to the right
UP                         equ 3                  ;KEYS MANAGER: player speed up 
DOWN                       equ 4                  ;KEYS MANAGER: player speed down 
S_KEY                      equ 5                  ;KEYS MANAGER: player request to start the game
ESC_KEY                    equ 6                  ;KEYS MANAGER: player request to exit the game
R_KEY                      equ 7                  ;KEYS MANAGER: player request to see Records of high score
N_KEY                      equ 8                  ;KEYS MANAGER: player request to toggle music on/off
R_Flag                     dw  0                  ;this variable is a flag so the system will know if to show the records or not
MoveDirect                 dw  0                  ;KEYS MANAGER: store the current player key pressed
player_x                   dw  0                  ;PLAYER VEHICAL X position
RandomNumber               dw  75                 ;RANDOM: number (OUTPUT)
RandomCounter              db  1                  ;RANDOM: orig algorithm
RandomMax                  db  100                ;RANDOM: orig algorithm
RandomMin                  db  1                  ;RANDOM: orig algorithm
RandomSeed                 db  17h                ;RANDOM: orig algorithm
PRIMITIVE_ROOT             dw  75                 ;RANDOM: ZX81 RND 75 is a primitive root modulo 65537
RANGE                      dw  108                ;RANDOM: range value to define the next zig length (108) ((Rnd*108)/255)+80
Z_RANGE                    equ 108                ;RANDOM initial RANGE value
BASE                       dw  80                 ;RANDOM: base value to  define the next zig length (80)  ((Rnd*108)/255)+80
Z_BASE                     equ 80                 ;RANDOM initial BASE value
MAX                        dw  255                ;RANDOM: max value to  define the next zig length (255)  ((Rnd*108)/255)+80
Z_MAX                      equ 255                ;RANDOM initial MAX value
Hop                        dw  0                  ;new zig length - equall to random  number in range[80,188]
R_RND                      dw  0                  ;RANDOM between (BASE) and (BASE+RANGE)
PLAYER_Y                   equ 160                ;player upper left Y position
YELLOW                     equ 14                 ;color for the road margins
LIFE_FACTOR                equ 22                 ;amount of max color colisions allowed per a single crash
Crash_Detect               dw  0                  ;CRASH: on crash set "Crash_Detect" to 1 
SCORE                      dw  0                  ;PLAYER score (OUTPUT)
LINES                      dw  0                  ;BACGROUND: counter every (50) road small lines, change the background color
filename                   db  'open.bmp',0       ;BMP
filehandle                 dw  0                  ;BMP
Header                     db  54 dup (0)         ;BMP
Palette                    db  256*4 dup (0)      ;BMP
ScrLine                    db  320 dup (0)        ;BMP
ErrorMsg                   db  'Error: Bitmap open fail', 13, 10,'$';BMP
x_width                    dw  10                 ;road width  ("MakeRoad (OUTPUT)","Draw_Horizontal_Line(INPUT)")
x_color                    db  0                  ;line color for Draw_Horizontal_Line(INPUT)
z_color                    db  0                  ;BACGROUND: new color (each 50 lines change the color)
colision                   dw  22                 ;on each "color" crash reduce "live" by one, if reachs 0 update "Live:n" in string
max_lives                  equ 39h                ;max lives per new game
Y_TOP                      equ 9                  ;Y init on most upper pixel line drawing                
TOP_Y                      dw  9                  ;Y on line drawing in "CleanTopLine" procedure
REC_LENGTH                 equ 33                 ;max copy length include "Score:00000000 player_name  "
CAR_HEIGHT                 equ 30                 ;computer random car heiht is 30 pixels
CAR_WIDTH                  equ 20                 ;computer random car width is 20 pixels
PLAYER_HEIGHT              equ 23                 ;player vehical height is 23 pixels
PLAYER_WIDTH               equ 12                 ;player vehical width is 12 pixels
DIGIT_0                    equ 30h                ;ASC char "0" is 30h
DIGIT_9                    equ 39h                ;ASC char "9" is 39h
MAX_X                      equ 319                ;maximum x cordinate
tmp_score                  dw  0                  ;for Top records
score_01                   dw  0                  ;for Top records 1 place
score_02                   dw  0                  ;for Top records 2 place
score_03                   dw  0                  ;for Top records 3 place
score_04                   dw  0                  ;for Top records 4 place
score_05                   dw  0                  ;for Top records 5 place
COLOR_LINES                equ 50                 ;lines per single color
INIT_PLAYER_X              equ 130                ;init plyer x cord at start of the game
VIDEO_MEM_STRT             equ 0A000h             ;start address for video memory in ram
OFFSET_LAST_LN             equ 63360              ;offset to the first pixel in one line above last line
PIXELS_IN_LINE             equ 320                ;pixels per line in cga is 320
LINE_9_OFFSET              equ 2880               ;offset to the pixel at line 9 below the print in graphic mode first line
CAR_SEP_RANGE              equ 31                 ;random computer car separation in lines - range 
CAR_SEP_BASE               equ 30                 ;random computer car separation in lines - base
CAR_POS_RANGE              equ 90                 ;random computer car x pos in pixel from road left side - range
CAR_POS_BASE               equ 40                 ;random computer car x pos in pixel from road left side - base     
READ_KB_STATUS             equ 64h                ;read keyboard status with interrupt
GET_KB_DATA                equ 60h                ;get keyboard data with interrupt
GET_PIXEL_COLOR            equ 0dh                ;get pixel color with interrupt
SET_PIXEL_COLOR            equ 0ch                ;set pixel color with interrupt
CGA_256_COLOR_MODE         equ 13h                ;320x200x256 "CGA-256"
PRINT_GRAPHICS_MODE        equ 13h                ;print string in graphics mode with interrupt
GET_SYSTEM_TIME            equ 2Ch                ;get system time with interrupt
CLEAR_KB_DATA              equ 0Ch                ;clear Keyboard and do Function with interrupt
CHANGE_TO_TEXT_MODE        equ 03h                ;change to TEXT MODE (text 80 x 25 16 color) with interrupt
DATA_IN_KB_BUFFER          equ 10h                ;data in buffer return from interrupt
EXIT_PROGRAM               equ 4c00h              ;exit from the program to command prompt work with interrupt
GET_STRING_FROM_KB         equ 0Ah                ;SERVICE TO CAPTURE STRING FROM KEYBOARD.
MAX_PLAYER_HEIGHT          equ 18                 ;add 18 to get max Y cord of player (for comparing)
MAX_PLAYER_WIDTH           equ 11                 ;width add to "player_x" to get X cord in display of right side
CRASH_DETECTED             equ 01h                ;set "Crash_Detect" to 1
OFFSET_SCORE_UNITS         equ 13                 ;point in msg to score units (most right digit in the 00000000)
SCORE_MSD_OFFSET           equ 5                  ;Score Most significent digit offset after "Score:" it  position 6 so 5 is overflow
TEXT_COLOR                 equ 00001111b          ;color of the text (white foreground and black background)
STRING_LEN_34              equ 34                 ;length of string
STRING_LEN_40              equ 40                 ;length of string
STRING_LEN_42              equ 42                 ;length of string
MIN_X_CORD                 equ 2                  ;minimum of left road boarder , if reached need to change direction
MAX_X_CORD                 equ 133                ;maximum of right road boarder, define when we need to change direction 
MAX_PLAYER_NAME            equ 17                 ;fix name to the first 17 letters
OFFSET_PRINT_NAME          equ 14                 ;point to output offset (after "Score:0000000")
LINE_CAR                   equ 40                 ;per how many road lines add a new car
OFFSET_LIVES_IN_MSG        equ 39                 ;point to right byte in msg of lives (at offset 39 bytes from start)
OFFSET_FIRST_IN_CHAR       equ 2                  ;offset of first input char 
MAX_OFFSET                 equ 33                 ;MAX_OFFSET = 33
LINE_1_Y                   equ 8                  ;Y-CORD of first line of record
LINE_2_Y                   equ 9                  ;Y-CORD of second line of record
LINE_3_Y                   equ 10                 ;Y-CORD of third line of record
LINE_4_Y                   equ 11                 ;Y-CORD of forth line of record
LINE_5_Y                   equ 12                 ;Y-CORD of fifth line of record
COMMON_LINE_X              equ 3                  ;x coordinate
POINTS_ADD                 dw  0                  ;counter for adding point
POINT_ROL                  equ 125                ;add amount of POINT_ROL per each point added to SCORE            
records_filename           db  'records.txt',0    ;RECORDS
records_filehandle         dw  0                  ;RECORDS
ErrorRecordsMsg            db  'Error: Records open fail', 13, 10,'$' ;RECORDS
RecordsBuffer              db  2048 dup (0)       ;RECORDS
RecordsLine                db  40 dup (0)         ;RECORDS
end_of_line                db  13, 10             ;RECORDS <CR><LF>
one_shot                   dw  0                  ;get name only once on game start
ToggleSound                dw  1                  ;Toggle between play ot stop sound for each new RandomCar 0=play sound, 1=stop speaker


msg                        db  'Score:00000000                   Lives:9' ;string use to print player Score points and Lives
tmp_msg                    db  '                                        '
t_msg                      db  '                                        '
enter_name                 db  13,10,'Enter Name (max length 17) & Press ENTER'
;https://stackoverflow.com/questions/29504516/getting-string-input-and-displaying-input-with-dos-interrupts-masm
buff                       db  33           ;MAX NUMBER OF CHARACTERS ALLOWED (but we will use only the first 18 letters...)
                           db  ?            ;NUMBER OF CHARACTERS ENTERED BY USER.
                           db  40 dup(0)    ;CHARACTERS ENTERED BY USER.
tmp_name                   db  '                                        ' ;last games score & names
name_01                    db  '                                        ' ;for Top records 1 place 
name_02                    db  '                                        ' ;for Top records 2 place
name_03                    db  '                                        ' ;for Top records 3 place
name_04                    db  '                                        ' ;for Top records 4 place
name_05                    db  '                                        ' ;for Top records 5 place



;The bit array for computer added car(s) (which the player need to avoid crashing with them)
RndCar                     db 0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0,0,0
                           db 0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,0,0,0,0
                           db 0,0,0,7,7,7,1,1,1,1,1,1,1,1,7,7,7,0,0,0
                           db 0,0,7,7,7,7,7,1,1,1,1,1,1,7,7,7,7,7,0,0
                           db 0,0,7,7,7,7,7,1,1,1,1,1,1,7,7,7,7,7,0,0
                           db 0,0,0,7,7,7,1,1,1,1,1,1,1,0,7,7,7,0,0,0
                           db 0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
                           db 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
                           db 0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
                           db 0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0
                           db 0,0,0,7,7,7,0,1,1,1,1,1,1,0,7,7,7,0,0,0
                           db 0,0,7,7,7,7,7,1,1,1,1,1,1,7,7,7,7,7,0,0
                           db 0,0,7,7,7,7,7,1,1,1,1,1,1,7,7,7,7,7,0,0
                           db 0,0,0,7,7,7,0,1,1,1,1,1,1,0,7,7,7,0,0,0
                           db 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
                           db 0,0,0,0,0,12,12,12,12,12,12,12,12,12,12,0,0,0,0,0
        
;The player car vehical
Player                     db 0,0,0,0,0,0,0,0,0,0,0,0
                           db 0,0,0,0,0,7,7,0,0,0,0,0
                           db 0,0,0,0,7,4,4,7,0,0,0,0
                           db 0,0,0,0,7,7,7,7,0,0,0,0
                           db 0,0,0,0,7,7,7,7,0,0,0,0
                           db 0,0,8,8,8,8,8,8,8,8,0,0
                           db 0,0,8,4,4,4,4,4,4,8,0,0
                           db 0,0,0,0,4,4,4,4,0,0,0,0
                           db 0,0,0,0,4,4,4,4,0,0,0,0
                           db 0,0,0,0,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,0,0,0,0
                           db 0,0,0,0,1,1,1,1,0,0,0,0
                           db 0,0,0,0,0,7,7,0,0,0,0,0
                           db 0,0,0,0,7,4,4,7,0,0,0,0
                           db 0,0,0,0,7,7,7,7,0,0,0,0
                           db 0,0,0,0,7,7,7,7,0,0,0,0
                           db 0,0,0,0,7,4,4,7,0,0,0,0
                           db 0,0,0,0,0,7,7,0,0,0,0,0
                           db 0,0,0,0,0,0,0,0,0,0,0,0
                           db 0,0,0,0,0,0,0,0,0,0,0,0
        


