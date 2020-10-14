.model small
.586
PUBLIC display_OPTION
extrn first_screen:far,space:far,assc:far,clear_screen:far,start_point:far,display_ax:far,  
      start_cow:byte,start_row:byte   
.data
        es_seg_option dw 0b000h  
		bx_seg_option dd 0 
		
		first_address_seg dd 0
		address_seg  dw 0 
		first_address_offseg dd 0 
		address_offseg dw 0 
		
		length_option   dw 0 
		size_option     db 0 
        number_512 		dw 512 
		MESG_TITLE      DB 'first adress     size      length      end address  ',0dh,0ah,'$'
        deline          db ':','$'
	    MESG_RETURN DB 'Quit: Q  ','$'
		.code 
.startup
display_OPTION:
        call clear_screen
        include MACRO_zifu.MAC
        mov start_cow,2
		mov start_row,23 
		call start_point
		msg MESG_RETURN		
		PUSHA 
	    mov bh,0 
        mov dh,0    
        mov dl,0   
        mov ah,02h	  
        int 10h
		POPA
		
        mov ax,es_seg_option
	    mov es,ax 
	    mov si,0 
        mov cx,2 
	    msg MESG_TITLE
		
add_es_optin:  
	    mov ax,es                  ;es:0c000h----0e000h
	    add ax,1000h 
	    mov es,ax  
cheak_option:
        push cx
        mov cx,65536
cheak_55h:	  
        mov al,es:[bx+si]
        cmp al,55h
	    JZ cheak_2
        jmp next_char_option	
	;-----------------------
cheak_2:
     
        inc si
     	  
	    mov al,es:[bx+si]
	    cmp al,0AAH 
	    jz cheak_3
	    dec si
        jmp next_char_option 	  
	 
cheak_3:
        pusha 
	    xor eax,eax 
        mov first_address_seg,es 
	    mov ax,si
	    sub eax,1 
        add eax,ebx   	 
        mov first_address_offseg,eax 
	    popa 
	 	
   	    inc si 
	 
	    mov al,es:[bx+si]
        mov  size_option,al 	
	 ;-------------------------   size 
	 ;mov length_option, al 
	 ;--------------------        size*512  
	    mul  number_512 
	                               
	    mov  length_option,ax        ;length
     	 
	
	 
	 

  next_char_option:
        inc si 
	    loop cheak_55H 
	    pop cx 
        loop  add_es_optin
	
	;------------------------------------- ;first_address_seg
	    mov eax,first_address_seg
	    mov address_seg,ax 
	    rol eax,16 
	 
        call display_ax	
	
	    msg deline 
	 ;------------------------------------ ;first_address_offseg
	    mov eax,first_address_offseg
	    mov address_offseg,ax 
	    rol eax,16 
	    pusha 
	 	  
	  
        call display_ax
	 ;------------------------------- ;size
	 
	    mov al,size_option
	
        call space_8
	    call assc
	  
	    call  space_8 
	    mov eax,dword ptr length_option
	    rol eax,16 
	    call display_ax
	    call space_8
	  ;------------------------------  ;end adress   
	    xor eax,eax 
	    mov eax,first_address_seg
	  ;;;
	    rol eax,16 
	    mov address_seg,ax 
	    mov ax,address_seg
        call display_ax
	    msg deline
	  
	    mov eax,dword ptr length_option
	    and eax,0000ffffh 
	   
	    add ax,address_offseg
	    sub ax,1 
	    rol eax,16 
	  
	  call display_ax
	 
     	  
      cheack_option:

	
        mov ah,11h    
        int 16h      ;检测按键是有否按下
       
       
        jz   cheack_option
		
		mov ah,8
		int 21h
        cmp al,'q'     
        jz  first_screen
		cmp al,'Q'     ;若为Q 键则退出
        jz  first_screen
	;**********************************************
         		 
        jmp cheack_option 
.exit 

 


 


   
	   
display_eax_option  proc far
	   pusha
	   mov cx,4 
	   
 display_al:        
    		
       rol eax,8 
	   call assc		
      cmp cx,3 
       jnz  continue_al
	   
 continue_al:	  
       loop display_al
      	  
       popa
       ret 
 display_eax_option   endp

 
     space_8  proc far 
	  mov cx,8
space_gain:  
      call space 
      loop space_gain
	  ret 
	  space_8 endp
 
end 