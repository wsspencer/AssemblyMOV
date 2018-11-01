;----------------------------------
;Program:  IfThen
;
;Function: Read and echo two ASCII characters x and y
;          Using only the mov instruction, calculate:
;             z = 'N'
;             if (x == y) then z = 'Y'
;          Output z
;          Terminate
;
;Notes:    All variables must be byte size
;          Variables z and dummy z must be contiguous in memory
;          Other than mov, the only other instruction used is int 21h
;            to read and write data and terminate
;
;Owner:    Dana Lasher
;
;Version:  Date    Reason
;          040917  Original code
;
;
;----------------------------------
         .model    small          ;4 64KB segments
         .8086                    ;only 8086 instructions
         .stack    256            ;256 byte stack
;----------------------------------


;----------------------------------
         .data                    ;data
;----------------------------------
x        db        0              ;variable x
y        db        0              ;variable y
                                  ;
z        db        0              ;variable z
dum_z    db        0              ;dummy variable z at memory offset z + 1
;----------------------------------


;----------------------------------
         .fardata                 ;256 bytes of work memory for selection code
;----------------------------------
         db        256 dup(0)     ;byte vars need 256 bytes of work memory
;----------------------------------


;----------------------------------
         .code                    ;Program
;----------------------------------
; Establish addressability to data and extra segment
; Clear bx, to be used as a word pointer.
;----------------------------------
start:   mov       ax,@data       ;initialize
         mov       ds,ax          ; the ds register
         mov       ax,@fardata    ;initialize
         mov       es,ax          ; the es register
         mov       bx,0           ;clear bx as pointer register
;----------------------------------
; Read and echo x
;----------------------------------
         mov       ah,8           ;read code
         int       21h            ;read interrupt
         mov       [x],al         ;save x
         mov       dl,al          ;ready to echo x
         mov       ah,2           ;write code
         int       21h            ;write interrupt
;----------------------------------
; Read and echo y
;----------------------------------
         mov       ah,8           ;read code
         int       21h            ;read interrupt
         mov       [y],al         ;save y
         mov       dl,al          ;ready to echo y
         mov       ah,2           ;write code
         int       21h            ;write interrupt
;----------------------------------


;----------------------------------
; The only instruction in this block is mov
;
; z='N'
; if (x==y) then z='Y'
;-----------------------------------
         mov       [z],'N'         ;z = 'N'
                                   ;
         mov       bl,[x]          ;bx pts to es memory addr=value_of_x
         mov  byte ptr es:[bx],1   ;es memory at memory addr=value_of_x set to 1
                                   ;
         mov       bl,[y]          ;bx pts to es memory addr=value_of_y
         mov  byte ptr es:[bx],0   ;es memory at memory addr=value_of_y set to 0
                                   ;
         mov       bl,[x]          ;bx pts to es memory addr=value_of_x
         mov       bl,es:[bx]      ;bx=0 if (x==y)  bx=1 if (x!=y)
                                   ;
         mov  byte ptr[z+bx],'Y'   ;z='Y' if (x==y)  dum_z='Y' if (x!=y)
;-----------------------------------


;----------------------------------
; Output z
;----------------------------------
         mov       ah,2           ;write code
         mov       dl,[z]         ;write z
         int       21h            ;write interrupt
;----------------------------------
; Terminate
;----------------------------------
         mov       ax,4c00h       ;get the termination code
         int       21h            ;terminate
                                  ;
         end       start          ;end program
;----------------------------------


