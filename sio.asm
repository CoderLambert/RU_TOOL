.model small
.586
public display_SIO
extrn  asstohex:far,clear_screen:far,space_8:far,space:far,first_screen:far,huiche:far,assc:far    
.data   
        cont_0ch    db 0
        ACT         db 0 
        cr30        db 0                   ;control device status 
        crf0        db 0                   ;clock rate 
        cr70        db 0                   ;IRQ 
        off_set     db  0
        device_num  db 0
        register_num db 0
		
        base_address_60   db 0          ;io base_address
        base_address_61   db 0 
        base_address_62   db 0 
        base_address_63   db 0
        
        ;no_active   db '--',0dh,0ah,'$'
        active      db 'active',0dh,0ah,'$'
        mesg_sio_title  db 'device    ACT   base_address         IRQ      clock rate',0ah,0dh,'$'
.code 
.startup 
display_SIO:
    include MACRO_zifu.mac 
 
  
  ;--------------------Enter the extended function mode 
begain: 
        PUSHA 
        mov bh,0 
        mov dh,0    
        mov dl,0   
        mov ah,02h	  
        int 10h
        POPA            ;START POINT 
   ;set  device_num
        mov device_num,0 
   
        mov cont_0ch,0ch 
        call clear_screen
        msg mesg_sio_title
 ;--------------------------------INIT 



 
cheak_active_again:
   
        call  enter_exten_func     ;write 87 to 2eh twice 
	
   ;--------------------Configuration logical device No. Configuration  register  CR..	  
        mov dx,2eh 
        mov al,07h
        out dx,al           ;point to Logical Device Number Reg
   
   ;--------------------

       mov dx,2fh             
       mov al,device_num   ;03h  no active     
       out dx,al 	        ;select Logical Device 
   ;-----------------------------------------------------------
	
	
	
;---------------------------------	;read data  all 
       mov off_set,30h                 
       call read_offset            ;active status
       mov cr30,al 
	
;--------------------------------	
       mov off_set,63h 
       call read_offset
       mov base_address_63,al
;-------------------------------
       mov off_set,62h 
       call read_offset
       mov base_address_62,al 
;-------------------------------	;IO BASE ADDRESS 
       mov off_set,61h 
       call read_offset
       mov base_address_61,al 
;-------------------------------    
      mov off_set,60h 
      call read_offset
      mov base_address_60,al 	
;-------------------------------- 
      MOV off_set,70h               ;	IRQ 
      call read_offset
      mov cr70,al 
;--------------------------------
      mov off_set,0f0h             ; CLOCK RATE 
      call read_offset
      mov crf0,al

	
;---------------------------------	
	
;---------------------------    Cheack  active 
      mov al,cr30
      cmp al,0ffh 
      jz cheak_device_active         ;if (al == 0ff)    cheak_device_active (if all data 0ffh   no_active  else  active )    
      test al,01h                    ;else    test bit0    1:active     0:no active 
      jnz display_resouce            ;if active,show resouce    else next device  
      jmp device_no_active

cheak_device_active:  

cmp_63h:
    cmp base_address_63,0ffh
    jz  cmp_62h 
    jmp display_resouce

cmp_62h:	
    cmp base_address_62,0ffh
    jz cmp_61h   
    jmp display_resouce
cmp_61h: 
    cmp base_address_61,0ffh
    jz cmp_60h 
    jmp display_resouce
cmp_60h: 
     cmp base_address_60,0ffh
     jz  cmp_CR70
     jmp display_resouce
cmp_CR70: 
     mov al,cr70
     cmp al,0ffh  
     jz  cmp_crf0 
     jmp display_resouce
      ;---------------------------
cmp_crf0:	
      mov al,crf0  
      cmp al,0ffh  
      jz  device_no_active                      ;if cr70,crf0,cr60_63  all 0ff      no_active   
      jmp display_resouce                ;else display resouce 
  ;-----------------------------------
    device_no_active:   
      mov al,device_num
      call assc
      call space_8 
	
      mov  al,cr30
      call assc
      call huiche
	;msg no_active

      jmp stop_check
	
display_resouce:
    
      mov al,device_num
      call assc	
      call space_8 
	 
      mov al,cr30
      call assc
;msg active
	
      call space 
      call space 
      call space
      mov al,base_address_60
      call space 
      call space 
      call assc
      mov al,base_address_61
      call assc
      call space
	;-----------------
      mov al,base_address_62
      call assc
      mov al,base_address_63
      call assc
      call space_8  
	call space 
	call space 
	call space 
	mov al,cr70
	call assc
	call space_8 
	mov al,crf0
	call assc
	call huiche 
stop_check:
	 call exit_exten_func
     inc  device_num
     
     dec cont_0ch
     cmp cont_0ch,0	 
 	 jnz cheak_active_again
	
	
	
				
NO_INPUT_ISA:
		;**********************************************
       mov ah,0
       int 16h        ;

       cmp ah,01h     
       JZ  first_screen
       cmp al,'1'
       jz  change_active 
                
       JMP NO_INPUT_ISA
;------------------------------
 change_active:  
   
       mov cx,3
       mov device_num,01h
cheak_active1_3:
       call  enter_exten_func
	
	 
   ;--------------------Configuration logical device No. Configuration  register  CR..	  
      mov dx,2eh 
      mov al,07h
      out dx,al           ;point to Logical Device Number Reg
   
   ;--------------------

      mov dx,2fh             
      mov al,device_num        
      out dx,al 	        ;select Logical Device 
   ;-----------------------------------------------------------
	
	
	
;---------------------------------	
	                    ;read data  all 
	call out_offset
	inc device_num
	call exit_exten_func
	loop cheak_active1_3
	jmp begain			
				
;------------------------------				
	
	
.exit 

   read_offset   proc 
    push dx 
    mov dx,2eh
	mov al,off_set          ;select CR_    cheak_active    
    out dx,al 
	
    mov dx,2fh         
    in al,dx
    pop dx 	;  
    ret
   read_offset  endp 

   out_offset   proc 
    push dx 
    mov dx,2eh
	mov al,30h          ;select CR_30    cheak_active    
    out dx,al 
	
    mov dx,2fh         
    in al,dx
	xor al,01h           ;change bit0 status  control active or not active   
	out dx,al  
    pop dx 	;  
    ret
   out_offset  endp    



    enter_exten_func  proc far public  
     push ax 
     push dx 	 
  	 mov dx,2eh 
	 mov al,87h
	 out dx,al 
	 out dx,al 
	 pop dx 
	 pop ax 
	 ret 
	enter_exten_func   endp 
	
	exit_exten_func proc far public    
    push ax 
	push dx 
	mov dx,2eh 
	mov al,0aah
    out dx,al 	
    pop dx 
    pop ax 
    ret 
    exit_exten_func  endp 
			   
        

 
	
end 