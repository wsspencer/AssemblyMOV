;---------------------------------------------------------------------
; CSC236 MOV
;
; This is the MOV program.  It reads and echos 3 keyboard inputs from the user
; and reports back a value once all 3 have been read.
; We refer to the 3 inputs as "x," "y," and "z."  If the input for "z" is any
; ascii character other than '+' then we report back the value stored in "x."
; If the input for "z" is the ascii character '+' then we set our "x" variable
; equal to "x + y" and report back the result.
; The catch for this program is using lookup tables and pointers to our data
; segment in order to perform the above tasks ONLY using the "mov" instruction.
;
;
;
;
; Owner:	  W Scott Spencer
;
;
;
; Updated     Reason
; ----------------------------
; 04/18/2018  Finished 
; 04/18/2018  Original version
;
;---------------------------------------------------------------------


;---------------------------------------
         .model    small               ;4 segments of 64KB
         .8086                         ;only  8086 instructions
         .stack    256                 ;stack size is 256 bytes
;---------------------------------------

;---------------------------------------
; Data for the main program
;
;---------------------------------------
         .data                         ;
x        	db		0h
dummy_x		db		0h
y			db		0h
z			db		0h

; then; create lookup table for converting ASCII to 0h-9h to build output string dynamically
; it will stop when it builds a value greater than 9 since converting single digit value to ascii is easy (you just add hex 30)
asciicon	db		0h
			db		1h
			db		2h
			db		3h
			db		4h
			db		5h
			db		6h
			db		7h
			db		8h
			db		9h


; then; create lookup table to perform the addition x + y (Just copy lookup table inctbl from JmpMov.asm)
inctbl   db        000,001,002,003,004,005,006,007,008,009 ;
         db        010,011,012,013,014,015,016,017,018,019 ;
         db        020,021,022,023,024,025,026,027,028,029 ;
         db        030,031,032,033,034,035,036,037,038,039 ;
         db        040,041,042,043,044,045,046,047,048,049 ;
         db        050,051,052,053,054,055,056,057,058,059 ;
         db        060,061,062,063,064,065,066,067,068,069 ;
         db        070,071,072,073,074,075,076,077,078,079 ;
         db        080,081,082,083,084,085,086,087,088,089 ;
         db        090,091,092,093,094,095,096,097,098,099 ;
         db        100,101,102,103,104,105,106,107,108,109 ;
         db        110,111,112,113,114,115,116,117,118,119 ;
         db        120,121,122,123,124,125,126,127,128     ;

; then; create an extra segment (Just use extra segment definition from IFThen.)
;----------------------------------
         .fardata                 ;256 bytes of work memory for selection code
;----------------------------------
         db        256 dup(0)     ;byte vars need 256 bytes of work memory
;----------------------------------sm)

;---------------------------------------
         .code                         ;
;---------------------------------------
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
; Read and echo z
;----------------------------------
        mov       ah,8           ;read code
        int       21h            ;read interrupt
        mov       [z],al         ;save y
        mov       dl,al          ;ready to echo y
        mov       ah,2           ;write code
        int       21h            ;write interrupt
;----------------------------------

; convert the ascii value of y '0' to '9' into a hex 0 to 9
		
		mov			bl,[y]						;mov y val into bl
		mov			al,[asciicon + bx - 30h]	;sub 30h since ascii digits begin at hex 30
		mov			[y],al						;mov al into y variable
		
; calculate x + y in the al register
		mov			bl,[x]						;move x val into bl register
		mov			si,bx						;mov bx val into si
		mov			bl,[y]						;mov y val into bl register
		mov			al,[inctbl + si + bx]		;mov inctbl + x + (y-30h) into al
		
; if (z=='+') then x = x + y  ('+' is dec 43, hex 2B)

		mov			bl,[z]
        mov  		byte ptr es:[bx],1   		;es memory at memory addr=value_of_x set to 1

        mov       	bl,'+'          			;bx pts to es memory addr='+'?
        mov  		byte ptr es:[bx],0   		;es memory at memory addr=value_of_z set to 0

        mov       	bl,[z]          			;bx pts to es memory addr=value_of_z
        mov       	bl,es:[bx]      			;bx=0 if (z=='+')  bx=1 if (z!='+')

        mov  		byte ptr[x+bx],al   		;x=al (x+y) if (z=='+')  dummy_X=al if (x!='+') 
												; because dummy_x + bx is x if bx=0, z+bx = dummy_x if bx=1

; output x
		mov			dl, [x]							; mov x variable into dl register
		mov			ah,2							; echo dl register
		int			21h								; call interrupt handler

;---------------------------------------
; Terminate the program
;---------------------------------------
movend:                                 ;
         mov       ax,4c00h            ;set DOS termination code
         int       21h                 ;terminate
;---------------------------------------

         end       start

