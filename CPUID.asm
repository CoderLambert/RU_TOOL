.model  small 
.586
public display_CPUID
extrn clear_screen:far,space:far,back_ground_color:word ,first_screen:far 
.data
 
        veder_word   dd 0
        d_eax dd 0 
        d_ebx dd 0 
        d_ecx dd 0 
        d_edx dd 0
        func  dd 0	
        font_color       db 0 
        processor_type db 0
        family         db 0
        model          db 0 
        stepping_id    db 0 
        extended_flag   db 0
        extended_model_id db 0 		
        mesg_veder      db'Vender ID String: ','$'
        mesg_barand     db'Brand string: $'
        mesg_processor  db'  Processor type:0x','$'
        mesg_familay    db'  family:0x','$'
        mesg_model      db'  model:0x','$'	
        mesg_step       db'stepping id:0x','$'
        mesg_suport     db'this computer suport serial number','$'
        mesg_not_support_brand_string  db'processor brand string not supported','$'
        MESG_not_suport_brand          db'    not support brand string function','$' 
.code 
.startup
display_CPUID:
      include  MACRO_zifu.MAC 
        mov al,3
        mov ah,0
        int 10h
        mov back_ground_color,21h
        CALL clear_screen
        mov func, 80000002h
;-----------------------------------------------------	  
        msg mesg_veder                               ;diaplay vender id
        call display_vender
;--------------------------------------------------------
        msg mesg_barand             
        call dispaly_brand                           ;dispaly_brand 
        call change_line
;-----------------------------------------------------
        call display_extended_information
wait_here_cpuid:
        MOV AH,11H    
        INT 16H         ;cheack key press 
        jz   wait_here_cpuid
        mov ah,0
        int 16h            
       
        cmp ah,01h 
        jz first_screen
        jmp wait_here_cpuid
            
;dispaly_extended_information		 
 display_extended_information   proc  far  public 
        pusha    
        mov eax,80000000h                            ;cheack    Check whether support extended information funct
        cpuid 
        and eax,80000000h 
        jz not_suport_extended
        jmp suport_extended
not_suport_extended:
        mov extended_flag,0                         ;not suport 
suport_extended:                             
        mov extended_flag,1                         ;suport  falg=1                      
        mov eax,1 
        cpuid                                          
      
  
        mov stepping_id,al 
        and stepping_id,0fh
        
        
	  
        mov model,al 
        and model,0f0h 
        shr model,4 	  
      
        mov family,ah 
        and family,0fh 
      
        mov processor_type,ah 
        and processor_type,30h
        
        shr eax,16 
        mov extended_model_id,al 
        and extended_model_id,0fh 
        
        msg mesg_step
        mov al,stepping_id
        call asscc_high_low 
        call space
        ;--------------------------------------------
        cmp extended_flag,0                   ;if suport extended information   show extend_mode 
        jz dispaly_mode                       ;else  not show 
        msg mesg_model
        mov al,extended_model_id
        call asscc_high_low
        dispaly_mode: 
        mov al,model
        call asscc_high_low 
        call space 
        
        msg mesg_familay
        mov al,family
        call asscc_high_low
        call space 
        
        msg mesg_processor
        mov al,processor_type
        call asscc_high_low
        call space
        jmp wait_here_cpuid 	  
 
        popa 
        ret 
        display_extended_information  endp  
                
        asscc_high_low proc far                      ;hex to asscii from al 
        pusha                                        ;reserve al_high            
        add al,30h             
        cmp al,'9'             
        jLE  next11
          
        add al,7
next11:
                               
        mov font_color,24h
        call change_font_color
        mov ah,2	
        mov dl,al 		  
        int 21h
        
                
        popa
        
        ret
        asscc_high_low endp		 
;************************
;display vender id 
   display_vender  proc 
       pusha 
       mov EAX,0               ;get vender id string 
       cpuid                   ;ecx ebx ebx
       mov d_ebx,ebx 
       mov d_ecx,ecx 
       mov d_edx,edx           ;copy string 
        
       mov  eax,d_ebx 
       call display_word       ;display vender 
       mov eax,d_edx
       call  display_word
       mov eax,d_ecx
       call display_word
       call change_line
       popa 
       ret
display_vender endp
   
  ;***************************
  ;purpose: dipaly barand  string
  ;input: func   
  ;output:eax,ebx,ecx,edx 
    
  dispaly_brand  proc 
       mov eax,80000000h
       cpuid
       test eax,80000000h
       jz not_suport_brand

       cmp eax,80000004h
       jae  support_brand      
         
not_suport_brand:
       
       msg MESG_not_suport_brand
       jmp  brand_end     
       
       
 
 
 support_brand:
       mov cx,3
barand_string_gain:
       push cx	  
       mov eax,func                 
       cpuid 
       mov d_eax,eax 
       mov d_ebx,ebx 
       mov d_ecx,ecx 
       mov d_edx,edx 
       
       mov eax,d_eax 
       call display_word
       mov eax,d_ebx
       call display_word
       mov eax,d_ecx 
       call display_word
       mov eax,d_edx
       call display_word
       add func,1 
       pop cx
       loop barand_string_gain
brand_end:     
       ret 
dispaly_brand  endp   

asscc proc far               ;hex to asscii from al 
			   PUSHA
			
            
			                ;reserve al_high
			  ;               
			 add al,30h             ;
			 cmp al,'9'             ;
			 jLE  next11
			 add al,7
	 next11:
	         mov ah,09               ;调用DOS功能显示高四位对应的数字
	          
			 mov bh,0 
			 
			 mov bl,24h
			 mov cx,1
			 int 10h
             mov ah,2	
             mov dl,al 		  
		     int 21h
			
                
			   popa
			
			  ret
			asscc endp
;***********************************************************************************************

 assc_cpuid proc far               ;hex to asscii from al 
			   PUSHA
			    mov ah,09 
			    mov bh,0 
			    mov bl,024h
			    mov cx,1
			    int 10h
                mov  Dl,al 
			    mov ah,2
			    int 21h 
			
                
			    popa
			
			   ret
			assc_cpuid endp
			
			
;************change_font_color*******************
             ;set font  color 
             ;input font_color 
             ;output : NO 			
change_font_color  proc far 
             mov ah,09               
	         mov bh,0 
			 mov bl,font_color
			 mov cx,1
			 int 10h
             ret
change_font_color  endp 				
;**************************************************
;display eax (asscii)	
;input:vender_word 
;**************************************************
display_word  proc far
        pusha
		;mov eax,veder_word	
        mov cx,4
        	
display_al: 
         
        call assc_cpuid
		shr eax,8 		
        loop display_al 
        popa
        ret 
			  
        display_word  endp 

		
		change_line  proc far 
        push ax
        push dx
        mov ah,2
        mov dl,0dH
        int 21H
        mov ah,2
        mov dl,0aH
        int 21H
        pop dx 
        pop ax 
        ret 
        change_line endp
end 