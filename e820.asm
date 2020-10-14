
          e820 struc       ;Address Range Descriptor Structure
	      base_addr_low   dd ?
	      base_addr_high  dd ?
		  length_low      dd ?
		  length_high     dd ?
		  type_b          db ?
	      e820 ends	
.model small 
.586 
public display_E820
extrn  first_screen:far,QUIT:far,clear_screen:far,
       locate_X_Y:far,locate_DH_DY:far,hex:far,
      clear_screen:far,first_screen_h:byte,space:far,assc:far,display_eax:far,
	  first_screen:far,D_H:BYTE,D_L:BYTE,D_H_CHANGE:byte,back_ground_color:word  
.data 
  cow_e820 db 0
  buffer   e820 < >      
  mesg_err   db 'interrupt command is not effect','$'
  mesg_available  db    '   Available','$'
  mesg_reserved db   '   Reserved ','$'
  mesg_ACPI     db   '   ACPI  Reclaim   ','$'
  mesg_NVS      db   '   ACPI  NVS','$'
  mesg_other	db   '   Other    ','$'
  mesg_title    db   'Range   Start Address     End Address       Length            Tupe','$' 
  MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$'
  .code 

display_E820:
    include MACRO_zifu.MAC 
        call clear_screen
         mov D_H, 1
	     MOV D_L, 2 
	     call  locate_DH_DY			
		  msg mesg_title
          
		  mov ah,2
		  mov dl,0ah
		  int 21h
		  mov ah,2
		  mov dl,0dh
		  int 21h 
		    
            
        
 input_init:
		
		mov cow_e820,0
		mov ebx,0		;buffer pointer
 input: 
        mov dx,seg  buffer         
        mov es,dx                        
                                        ;es:di 
		mov  di, offset buffer
        mov  ecx,20                     ;buffer size  20 bytes
        mov  edx,'SMAP'                 ;signature
		mov eax,0e820h
     	int 15h 
	

 output: 
        ; jc  err         ;Non-Carry-Indicates No Error
        ; cmp eax,'SMAP'   ;'SMAP' Signature to verify correct BIOS revision  
        ; jnz err 
		  call space 
		  mov al,cow_e820 
		  call assc
		  call space 
		  call space 
		  call space 
		  
		  inc cow_e820 
		  
		   mov eax,buffer.base_addr_high    
		   call display_eax	                   
           mov eax,buffer.base_addr_low       
           call display_eax
		   call space                            ;display start address
;********************************************
		                                
		   mov eax,buffer.base_addr_low
		   add eax,buffer.length_low
		   mov edx,eax 
		   mov eax,buffer.base_addr_high
		   adc eax,buffer.length_high
		 
		  sub edx,1
		  sbb eax,0
			call display_eax                     ;display  end address 
		   
         
			mov eax,edx
          call display_eax		   
		  call space 
		  
		  
;************************************************		   
		   mov eax,buffer.length_high
		   call display_eax
		   mov eax,buffer.length_low
		   call display_eax                     ;display length
		   call space 
		   
		   xor  eax,eax 
		   mov al,buffer.type_b
		   cmp eax,1
		   jz  msg_mesg_available
		   cmp eax,2
		   jz  msg_mesg_reserved
		   cmp eax,3
		   jz  msg_mesg_ACPI
		   CMP eax,4
		   jz  msg_mesg_NVS 
		   msg mesg_other
		   jmp next_type
msg_mesg_available:
          msg   mesg_available
		  jmp next_type
msg_mesg_reserved:
          msg mesg_reserved	
		   jmp next_type
msg_mesg_ACPI:
           msg mesg_ACPI
		    jmp next_type
msg_mesg_NVS: 
           msg mesg_NVS		   
		   
		  
	next_type: 	  
		  mov ah,2
		  mov dl,0ah
		  int 21h
		  mov ah,2
		  mov dl,0dh
		  int 21h 
		 ;jmp $
		 
		 cmp ebx,0 
		 jnz input 
		 
 ;err: 
    ;  msg  mesg_err
wait_here_e820:
			 MOV AH,11H    
		 	 INT 16H         ;cheack key press 
             jz   wait_here_e820
			 mov ah,0
			 int 16h            ;读键盘输入一个字符，不回显
			

			 cmp ah,01h
			 jz first_screen
			 jmp wait_here_e820
			 
			 END 