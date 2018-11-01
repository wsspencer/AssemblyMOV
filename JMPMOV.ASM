;------------------------------------
;Program:  JmpMov
;
;Function: x='0'
;          cycle: read y
;             if (y=='+') x=x+1
;             if (y=='+') print x
;             if (y=='+') goto  cycle
;          print y
;          exit
;
;Owner:    Dana Lasher
;
;Notes:    You only need to check if an instruction is the target of a jmp if
;            the instruction has a label ... thus making it a potential target.
;
;Version:  Date    Reason
;          042217  Original code
;
;
;------------------------------------
         .model    small            ;4 64KB segments
         .8086                      ;only 8086 instructions
         .stack    256              ;256 byte stack
;------------------------------------


;------------------------------------
         .data                      ;data
;------------------------------------
                                    ;
onoff    db        0                ;execution flag 0=on 1=off
dum_onof db        0                ;dummy variable
         db        0                ;dummy execution
                                    ;
target   db        0                ;current branch target address
dum_targ db        0                ;dummy variable
         db        0                ;dummy execution
                                    ;
x        db        0                ;variable x
dum_x    db        0                ;dummy variable
         db        0                ;dummy execution
                                    ;
y        db        0                ;variable y
dum_y    db        0                ;dummy variable
         db        0                ;dummy execution

doscode  db        0                ;dos interrupt code
dum_dos  db        0                ;dummy variable
                                    ;
                                    ;-----------------------
                                                           ;
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


msg      db        'This program outputs sequential digits (1234...)',13,10
         db        '- As long and the input is a + sign             ',13,10
         db        '- Any other character terminates the program    ',13,10,13,10
         db        'Enter characters:','$'

;-----------------------------------------------------------


;------------------------------------
         .fardata                   ;256 bytes of work memory for selection code
;------------------------------------
         db        256 dup(0)       ;byte vars need 256 bytes of work memory
;------------------------------------


;------------------------------------
         .code                      ;Program
;------------------------------------


;------------------------------------
; Initialize ds and es registers.
; The bx and cx registers will be used as pointers, so set to 0.
;
; Every time the code executes a jump, it will start again
; at start. The execution flag will be off until we reach the
; jump target instruction. So the real value of x will only be
; set to '0' the first time this code is executed.
;------------------------------------
start:   mov       ax,@data         ;initialize
         mov       ds,ax            ; the ds register
         mov       ax,@fardata      ;initialize
         mov       es,ax            ; the es register
                                    ;
         mov       bx,0             ;clear bx as a pointer to zero
         mov       cx,0             ;clear cx as a pointer to zero
    ;-------------------------------;
    ;Bx holds the execution flag 0=on 1=off.
    ;It should be 0 the first time and 1 all other times.
    ;Su we only initialize x once.
    ;So we only print the welcome message once.
    ;--------------------------------
         mov       bl,onoff         ;bx holds the execution flag 0=on 1=off
         mov       [x + bx],'0'     ;x or dummy x = '0'

         mov       bl,onoff         ;bx = the execution flag 0=on 1=off
         mov       [doscode],0bh    ;assume null operation
         mov       [doscode + bx],09;set to write if execution is on
         mov       ah,[doscode]     ;ah = write code or null
         mov       dx, offset msg   ;write y
         int       21h              ;write or null interrupt
;------------------------------------


;------------------------------------
; If cycle is the target of a jump
;  then turn normal execution on again.
;
; If execution is on the read a new value of y.
;------------------------------------
cycle:                              ;
     ;-------------------------------
     ;If target = offset_cycle turn exec on.
     ;-------------------------------
         mov       bx,offset cycle  ;bx pts to es memory addr=value_of_cycle
         mov  byte ptr es:[bx],1    ;es memory at addr=value_of_cycle set to 1
         mov       bl,[target]      ;bx pts to es memory addr=value_of_target
         mov  byte ptr es:[bx],0    ;es memory at addr=value_of_y set to 0
         mov       bx,offset cycle  ;bx pts to es memory addr=value_of_cycle
         mov       bl,es:[bx]       ;bx=0 if target == offset cycle
         mov  word ptr[onoff + bx],0;onoff or dummy onoff = 0
     ;-------------------------------
     ;Read a character.
     ;Store in y if execution is on.
     ;-------------------------------
         mov       ah,8             ;DOS read code
         int       21h              ;issue read interrupt
         mov       bl,onoff         ;bx = the execution flag 0=on 1=off
         mov       [y + bx ],al     ;y or dummy y = character read
;------------------------------------


;------------------------------------
; if (y == '+') x = x + 1
;------------------------------------
     ;-------------------------------
     ; If (y=='+') al=x+1
     ;-------------------------------
         mov      bl,[x]            ;bx contains the value of x
         mov  al,[inctbl + bx + 1]  ;set al to be the value x + 1
                                    ;
         mov       bl,'+'           ;bx pts to es memory addr=value_of_+
         mov  byte ptr es:[bx],1    ;es memory at addr=value_of_+ set to 1
         mov       bl,[y]           ;bx pts to es memory addr=value_of_y
         mov  byte ptr es:[bx],0    ;es memory at addr=value_of_y set to 0
         mov       bl,'+'           ;bx pts to es memory addr=value_of_+
         mov       bl,es:[bx]       ;bx=0 if (y==+)  bx=1 if (y!=+)
     ;-------------------------------
     ; If both execution is on and y=='+
     ;   then update x with x+1.
     ;-------------------------------
         mov       cl,onoff         ;cx = execution flag ... then move it to di
         mov       di,cx            ;di==0 exec on  di==1 execoff
         mov       [x + bx + di],al ;x or dum_x = x + 1
;------------------------------------



;------------------------------------
; if (y == '+') Output x
;------------------------------------
         mov       cl,onoff         ;cx = execution flag ... then move it to di
         mov       di,cx            ;di==0 exec on  di==1 execoff
         mov       [doscode],0bh    ;assume null operation
                                    ;bx still set bx=0 if (y==+) bx=1 if (y!=+)
         mov  [doscode + bx + di],02;set to write if execution is on and y==+
         mov       ah,[doscode]     ;DOS write code or null
         mov       dl,[x]           ;write x
         int       21h              ;either write x or execute null operations
;------------------------------------


;------------------------------------
; if (y == '+') goto cycle
;------------------------------------
         mov      ax, offset cycle  ;ax has the target address
                                    ;bx still set bx=0 if (y==+) bx=1 if (y!=+)
         mov   [target + bx + di],al;set target if y==+ and execution is on
         mov   [onoff  + bx + di],1 ;turn off execution if y==+ and exec is on
;------------------------------------


;------------------------------------
; Output y
;------------------------------------
         mov       bl,onoff         ;bx = the execution flag 0=on 1=off
         mov       [doscode],0bh    ;assume null operation
         mov       [doscode + bx],02;set to write if execution is on
         mov       ah,[doscode]     ;ah = write code or null
         mov       dl,[y]           ;write y
         int       21h              ;write or null interrupt
;------------------------------------


;------------------------------------
; Exit program if execution is on
;   which means we are not looking for
;   a jump target.
;------------------------------------
         mov       bl,onoff         ;bx = the execution flag 0=on 1=off
         mov   [doscode],0bh        ;assume null operation
         mov   [doscode + bx],4ch   ;set to exit if execution is on
         mov       ah,[doscode]     ;ah = terminate code or null
         int       21h              ;terminate or null
                                    ;
         jmp       start            ;jump to the start of the program
         end       start            ;end program
;------------------------------------
