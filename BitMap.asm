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
;* File Name: BitMap.asm
;* Program:   Road Driving Simulator
;*
;* Description: Manage bitmap file
;*  
;* Prepare by:  Nevo Kadan (2018)
;*
;******************************************************************************



;*******************************************************
;*PROCEDURE: show_bitmap
;*DESCRIPTION: This procedure show bitmap
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
proc show_bitmap
    push ax
    push bx
    push cx
    push dx
    push si

    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap 
    call CloseFile

    ; Clean the to top most line by set all the top line pixels to black  
    mov ax,0
    mov [TOP_Y],ax
    call CleanTopLine    
    
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
endp show_bitmap



;*******************************************************
;*PROCEDURE: OpenFile
;*DESCRIPTION: This procedure Open File
;*
;* INPUT:
;* ------
;* filename
;* 
;*
;* OUTPUT:
;* -------
;* [filehandle]
;*
;*
;*******************************************************
proc OpenFile
    mov ah, 3Dh
    xor al, al
    mov dx, offset filename
    int 21h
    jc openerror
    mov [filehandle], ax 
    ret
    
openerror:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h
    ret
endp OpenFile



;*******************************************************
;*PROCEDURE: ReadHeader
;*DESCRIPTION: This procedure Read BMP file header, 54 bytes
;*
;* INPUT:
;* ------
;* [filehandle]
;* 
;*
;* OUTPUT:
;* -------
;* Header
;*
;*
;*******************************************************
proc ReadHeader
    mov ah,3fh
    mov bx, [filehandle]
    mov cx,54
    mov dx,offset Header
    int 21h
    ret
endp ReadHeader



;*******************************************************
;*PROCEDURE: ReadPalette
;*DESCRIPTION: This procedure Read BMP file color palette, 256 colors * 4 bytes (400h)
;*
;* INPUT:
;* ------
;*
;*
;*
;* OUTPUT:
;* -------
;* Palette
;*
;*
;*******************************************************
proc ReadPalette
    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h
    ret
endp ReadPalette 



;*******************************************************
;*PROCEDURE: CopyPal
;*DESCRIPTION: This procedure Copy the colors palette to the video memory
;*             The number of the first color should be sent to port 3C8h
;*             The palette is sent to port 3C9h
;* INPUT:
;* ------
;* Palette
;* 
;*
;* OUTPUT:
;* -------
;* Video-Memory 
;*
;*
;*******************************************************
proc CopyPal
    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0
    ; Copy starting color to port 3C8h
    out dx,al
    ; Copy palette itself to port 3C9h
    inc dx
PalLoop:
    ; Note: Colors in a BMP file are saved as BGR values rather than RGB.
    mov al,[si+2] ; Get red value.
    shr al,1 ; Max. is 255, but video palette maximal
    shr al,1 ; Max. is 255, but video palette maximal
    ; value is 63. Therefore dividing by 4.
    out dx,al ; Send it.
    mov al,[si+1] ; Get green value.
 
    shr al,1
    shr al,1
    out dx,al ; Send it.
    mov al,[si] ; Get blue value.

    shr al,1
    shr al,1
    out dx,al ; Send it.
    add si,4 ; Point to next color.
    ; (There is a null chr. after every color.)

    loop PalLoop
    ret
endp CopyPal



;*******************************************************
;*PROCEDURE: CopyBitmap
;*DESCRIPTION: This procedure Copy Bitmap, BMP graphics are saved upside-down.
;*             Read the graphic line by line (200 lines in VGA format),
;*             displaying the lines from bottom to top.
;*
;* INPUT:
;* ------
;* ScrLine
;* 
;*
;* OUTPUT:
;* -------
;* Video-Memory 
;*
;*
;*******************************************************
proc CopyBitmap
    mov ax, 0A000h
    mov es, ax
    mov cx,200
PrintBMPLoop:
    push cx
    ; di = cx*320, point to the correct screen line
    mov di,cx
    
    ;shift left cx - 6 bits
    shl cx,1
    shl cx,1
    shl cx,1
    shl cx,1
    shl cx,1
    shl cx,1

    ;shift left di - 8 bits
    shl di,1
    shl di,1
    shl di,1
    shl di,1
    shl di,1
    shl di,1
    shl di,1
    shl di,1

    add di,cx
    ; Read one line
    mov ah,3fh
    mov cx,320
    mov dx,offset ScrLine
    int 21h
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,320
    mov si,offset ScrLine 

    rep movsb ; Copy line to the screen
    ;rep movsb is same as the following code:
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0
    pop cx
    loop PrintBMPLoop
    ret
endp CopyBitmap



;*******************************************************
;*PROCEDURE: CloseFile
;*DESCRIPTION: This procedure Close File
;*
;* INPUT:
;* ------
;* [filehandle]
;* 
;*
;* OUTPUT:
;* -------
;* 
;*
;*
;*******************************************************
proc CloseFile
    mov ah,3eh
    mov bx, [filehandle]
    int 21h
    ret
endp CloseFile