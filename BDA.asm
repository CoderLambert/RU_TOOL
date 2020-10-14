;*********************************
;purpose:display BDA informaition


;tap: 1AH   tail:1CH   
;video  model: 49H  (word)  COW:4AH  ROW: 84H
;COM_0:00H   COM_1:02H  COM_3:04H   COM_4:06H
;LPT_0:08H  0AH  0CH 
;KEY status_1  17H    
;insert_down 80h   else 00h    
; test al,80h 
; jnz display_insert_down   
; display_insert_off  
; test al,40h 
; jnz capslock_down 
;KEY status_2  18H 
;ALT           19H 
;EBDA ADDRESS  0EH  0FH   

.model small 
.586 
public display_BDA
extrn  assc:far,clear_screen:far,space:far,space_5:far,display_eax:far,back_ground_color:byte,
       first_screen:far   
.data
     MESG_COM_ADDRESS           db 'Serial Port Adress:','$'
     MESG_Parallel_Port_Address db 'Parallel Port Address:','$'
     MESG_KEPORT_STATUS         db 'Keyboard Status:','$'
     MESG_keyboard_buffer       db 'keyboard buffer:','$'
     MESG_VIDIEO_MODE           db 'Video Mode:','$'
     MESG_MAX_COW               db 'MAX_COW = ','$'
     MESG_MAX_ROW               db 'MAX_ROW = ','$'
     MESG_CURRENT_TIME          db 'Current Time: ','$'
     MESG_HOUR                  db ' Hour  : ','$'
     MESG_MIN                   db ' Min : ','$'
     MESG_SECOND                db ' Second : ','$'
     MESG_FREQUENCY             db 'FREQUENCY : ','$'
     MESG_MHZ                   db 'MHZ','$'
   
     MESG_SECONDS               db '    Seconds: ','$'
     
     crlf db 13,10,'$'
     
 ;----------------------------   
     MESG_COM1        db ' COM1 = ','$'
     MESG_COM2        db ' COM2 = ','$'
     MESG_COM3        db ' COM3 = ','$'
     MESG_COM4        db ' COM4 = ','$'
     
 ;----------------------------     
     MESG_LPT1        db ' LPT1 = ','$'
     MESG_LPT2        db 'LPT2 = ','$'
     MESG_LPT3        db 'LPT3 = ','$'
     MESG_EBDA_ADDRESS        db 'EBDA_SEG_ADDRESS = ','$'
 ;----------------------------     
     INSERT      db 'Insert = ','$'
     CapLock     db 'CapsLock = ','$'
     NumLock     db 'NumLock = ','$'
     ScrollLock  db 'ScrollLock = ','$'
     LeftShift   db '    LeftShift = ','$'
     RightShift  db ' RightShift = ','$'
     ALT         db 'Alt = ','$'
     Ctrl        db '        Ctrl = ','$'
     Ctrl_break  db 'Ctrl+Break = ','$'
  ;----------------------------   
     ON          db 'ON ','$'
     OFF         db 'OFF','$' 
     UP          db 'UP  ','$'
     DOWN        db 'Down','$'  

  ;---------------------------- 
     header      db 'header = ','$'
     tail        db 'tail = ','$'
     deline      db ':','$'
     buffer_adderss dw 1eh 
     ax_data     dw 0
     buf         db 5 dup(?)
  ;-----------------------------  
  
     eax_data        dd 0
	 edx_data        dd 0 
	 
     eax_data_total  dd 0
	 edx_data_total  dd 0 
     array           db 4 dup(?)
     number_1000000  dd 1000000
     number_55000    dd 55000
     number_1000     dw 0
     number_3600     dw 3600
     number_60       dw 60
     frequz_data     dd 0
     consult         dd 0
     remainder       dd 0
   
     .code 
.startup
display_BDA:
   include MACRO_zifu.mac 
   call clear_screen
         
     mov BH,0 
     MOV DH,1     
     MOV DL,0     
     mov AH,02h	  
     INT 10H;
	 
	 mov  ax,0040h 
     mov  es,ax 
     msg MESG_EBDA_ADDRESS  
     mov  si,0EH 
     call  read_word 
     
     mov BH,0 
     MOV DH,3    
     MOV DL,0     
     mov AH,02h	  
     INT 10H;
 ;---------------------------
 ;    COM  
     msg MESG_COM_ADDRESS
     
              
     
;--------------------------
     msg MESG_COM1
     mov  si,0
     call  read_word
     
     msg MESG_COM2
     mov si,02h 
     call read_word
     
      msg MESG_COM3
     mov si,04h 
     call read_word
     
     msg MESG_COM4
     mov si,06h 
     call read_word

  ;----------------------------------
  ;     Parrallel port 
     mov BH,0 
     MOV DH,5   
     MOV DL,0     
     mov AH,02h	  
     INT 10H;
     
     msg MESG_Parallel_Port_Address
     msg MESG_LPT1
     mov  si,08H 
     call  read_word 

     msg MESG_LPT2
     mov  si,0AH 
     call  read_word

     msg MESG_LPT3
     mov  si,0CH 
     call  read_word     
 
       
;--------------------------
;    key_status  
;    17h   18h 
NO_INPUT_BDA:
     mov BH,0  
     MOV DH,7    
     MOV DL,0     
     mov AH,02h	  
     INT 10H;
    
     msg MESG_KEPORT_STATUS
     mov si,17h 
     call check_status
;-------------------------------
;     VIDEO    MODE 
   
       mov bh,0  
       mov dh,11   
       mov dl,0h
       mov ah,02h	  
       int 10h; 
     
       msg MESG_VIDIEO_MODE
       mov si,49h 
       mov ax,es:[si]
        
       and ax,0ffh 
       call display_ax_dec
       call space 
       msg MESG_MAX_ROW
       mov si,84h 
       mov ax,es:[si]
       inc ax 
       and ax,0ffh 
       call display_ax_dec
       call space
       msg MESG_MAX_ROW       
       mov si,4ah 
       mov ax,es:[si]
                                   ;read byte   display dec form 
       and ax,0ffh 
       call display_ax_dec
       call space
;------------------------------------
;      Current time     
       mov bh,0  
       mov dh,13   
       mov dl,0h
       mov ah,02h	  
       int 10h;
       
       msg  MESG_FREQUENCY
       call frequz  
       msg  MESG_MHZ
       msg  crlf
       msg  crlf 
       
       msg  MESG_CURRENT_TIME
	   
       call current_time
       
        mov ah,11H    
        int 16H      ;check_key 
        jz NO_INPUT_BDA
       
    
        mov ah,0
        int 16h
        cmp ah,01h     ;QUIIT:ESC
        jz  first_screen
        jmp NO_INPUT_BDA
 
.exit 
   
 frequz  proc  far 
  pusha 
  mov  ax,0040h 
  mov  es,ax
  mov  bx,0  
  mov  si,6ch  
  
  mov al,es:[si]

wait_start_0:
  cmp al,es:[bx+si]
  jz wait_start_0
  
  rdtsc 
  mov eax_data,eax 
  mov edx_data,edx 
  

    
  
  mov al,es:[bx+si]
wait_55ms:  
  cmp al,es:[bx+si]
  jz wait_55ms
 
  
  rdtsc
  
  sub eax,eax_data
  sbb edx,edx_data
  
  mov eax_data,eax
  mov edx_data,edx 
   
  xor edx,edx
 
  div number_55000
 
  mov frequz_data,eax 
  call display_ax_dec    ;display cpu frequz
  
 
  
  popa 
  ret 
  frequz endp 
  ;-----------------------------------
  ;  get current time 
  current_time proc far 
  pusha
  rdtsc
  
   mov eax_data_total,eax
   mov edx_data_total,edx   
   mov eax,edx 
  ;-------------------------    tck 
  ; msg MESG_TCK   
  ;call display_eax
  ;call space
  ; mov eax,eax_data
  ; call display_eax
    
  ; msg crlf
  ;-------------------------    frequz
   ;msg MESG_FREQUENCY
   ;mov eax,frequz_data
   ;call display_eax
   ;msg crlf
  ;------------------------------------
  ; msg MESG_MHZ_NUMBER
   mov eax,eax_data_total
   mov edx,edx_data_total
   div number_1000000
   ;--------------------------------  MHZ number 
   mov consult,eax 
  ; call display_eax        
   
  ; msg crlf 
  ;--------------------------------   total second 
   msg MESG_SECONDS 
   xor edx,edx                         
   mov eax,consult 
   ;MOV frequz_data,2500
   div frequz_data 
   
  ;---------------------------------   
   call display_ax_dec
  ; msg crlf
   call space 
   call space
   xor edx,edx    
   div number_3600 
   mov remainder,edx
   msg  MESG_HOUR
   call display_ax_dec
   call space 
   
   mov eax,remainder
   xor edx,edx 
   div number_60
   msg MESG_MIN
   call display_ax_dec
   call space 
   msg MESG_SECOND
   mov eax,edx 
   call display_ax_dec
       
  
  
  popa 
  ret 
  current_time endp 
  
  
  
;------------------------------------
;       input: si,es 
;       output:ax_data 
        read_word proc far 
        pusha 
        mov al,es:[si]
        mov ah,0 
        mov ax_data,ax 
        shl ax_data,8 
     
        inc si 
        mov al,es:[si]
        mov ah,0
        add ax_data,ax 
          
    
        mov ax,ax_data     
        call display_ax_bda
        inc si 
        call space 
        call space 
        popa 
        ret 
        read_word endp 
        
;-----------------------------
;purpose:  display ax with form dec 
;input:ax         
        display_ax_dec  proc far 
        pusha 
        
init_to_dec:
               
        
        mov bx,10 
        mov si,4 
     
to_dec: 
         
        mov dx,0 
        div bx 
        mov [buf+si],dl 
        dec si 
        cmp ax,0 
        ja to_dec
       
output:  
        inc si 
        mov dl,[buf+si]
        add dl,30h 
        mov ah,2 
        int 21H
        cmp si,4 
        jb output 
       
      ;  call assc_dec
        
        call space 
        call space 
        call space 
        popa 
        ret 
        display_ax_dec endp
        
;------------------------------------
;       input: si,es 
;       output:ax_data  
        check_status proc far 
        pusha 
        mov al,es:[si]
       
          
        call space 
        call space 
        test al,80h 
        jnz insert_on
        key_status  INSERT ,OFF
        jmp  capslock_status 
insert_on: 
        key_status  INSERT,ON 
 ;--------------------------------             
capslock_status:    
        call space_5
        test al,40h 
        jnz capslock_on
        key_status  CapLock ,OFF
        jmp  NumLock_status 
capslock_on: 
        key_status  CapLock,ON 
 ;--------------------------------
NumLock_status: 
        call space_5
        test al,20h 
        jnz NumLock_on
        key_status  NumLock ,OFF
        jmp  ScrollLock_status 
NumLock_on: 
        key_status  NumLock,ON
;------------------------------        
ScrollLock_status: 
       mov BH,0  
       MOV DH,8   
       MOV DL,9     
       mov AH,02h	  
       INT 10H; 
       
       call space_5
       test al,10h 
       jnz ScrollLock_on
       key_status  ScrollLock ,OFF
       jmp  LeftShift_status  
ScrollLock_on: 
       key_status  ScrollLock,ON

LeftShift_status: 
       ;call space_5
       test al,02h 
       jnz LeftShift_UP 
       key_status  LeftShift ,UP
       jmp  RightShift_status
LeftShift_UP: 
       key_status LeftShift,DOWN  
RightShift_status:             
      
       test al,01h 
       jnz RightShift_UP 
       key_status  RightShift ,UP
       jmp  ALT_status
RightShift_UP: 
       key_status RightShift,DOWN 
ALT_status: 
       mov BH,0  
       MOV DH,9   
       MOV DL,15H

       
       mov AH,02h	  
       INT 10H; 
       test al,08h 
       jnz ALT_UP 
       key_status  ALT ,UP
       jmp  Ctrl_status
ALT_UP: 
       key_status ALT,DOWN  

Ctrl_status:   
       test al,04h 
       jnz Ctrl_DOWN  
       key_status  Ctrl ,UP
       jmp  Ctrl_status_UP
Ctrl_DOWN: 
       key_status Ctrl,DOWN  
Ctrl_status_UP:       
        popa 
        ret 
        check_status endp 


        
        



display_ax_bda  proc far               ;hex to asscii from al 
			   PUSHA
			    
               
			   mov bl,al              ;reserve al_high
			   shr al,4               
			   add al,30h             
			   cmp al,'9'             ;
			   jLE  next11_ax
			   add al,7
	 next11_ax:
			   mov dl,al
			   mov ah,2               ;high 
			   int 21h
			   and bl,0fh
			   mov dl,bl
			   add dl,30h
			   cmp Dl,'9'             ;low 
			   jLE  next22_ax
			   add Dl,7
	   next22_ax:
			   mov ah,2
			   int 21h 
	;------------------------------------		   
                mov ax,ax_data
                mov al,ah 
                mov bl,al             ;reserve al_high
			    shr al,4               
			    add al,30h             
			    cmp al,'9'             ;
			    jLE  next111
			    add al,7
	 next111:
			    mov dl,al
			    mov ah,2               ;high 
			    int 21h
			    and bl,0fh
			    mov dl,bl
			    add dl,30h
			    cmp Dl,'9'             ;low 
			    jLE  next222
			    add Dl,7
	    next222:
			    mov ah,2
			    int 21h 
               
                
			    popa
			
			    ret
			display_ax_bda endp



            
assc_dec proc far               ;hex to asscii from al 
			   ;mov al_data,al
               
      pusha
      
      
      
output:      
      inc si
      mov dl,[buf+si]
      add dl,30h            ;转为ascii
      mov ah,2
      int 21h
      cmp si,4
      jb output
      mov ah,1
      int 21h
	  popa
      ret
assc_dec endp            
            
            
display_al_low proc far               ;hex to asscii from al 
			   PUSHA
			   
               ;and al,0fh                
			   add al,30h             
			   cmp al,'9'             ;
			   jLE  nex
			   add al,7
	 nex:
			   mov dl,al
			   mov ah,2               
			   int 21H
			
                
			   popa
			
			   ret
			display_al_low endp            
            


end 