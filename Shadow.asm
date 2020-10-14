.model small
.586
public display_Shandow
extrn assc:far,clear_screen:far,display_eax:far,first_screen:far  
.data
 es_seg  dw 0c000H 
 bx_seg  dd 0H 
 not_find db 'not find string ','$'
 address  db 'find string [_SM_],  and have use string [_MS_] replace it',0dh,0ah,'   address is:','$' 
 mesg_recover db 'you can chose 1 to recover String [_SM_]','$'
 
 fuhao    db ':','$'
 help_text_shadow   DB 'QUIT: Q','$'
 si_string db '_SM_','$'
 di_string db '_MS_','$'
.code
.startup
display_Shandow:
init: 
        include MACRO_zifu.MAC 
	    call clear_screen
	    PUSHA 
	    mov bh,0 
        mov dh,23    ;放入行号
        mov dl,3    ;放入列号
        mov ah,02h	  
        int 10h
		POPA
		msg help_text_shadow
	 

  	  MOV AX,es_seg
      mov es,AX
	  
	  mov bx,word ptr bx_seg
	  mov si,0 
	  mov di,0 
      ;mov cx,256
	  mov cx,3 
add_es:  
	   mov ax,es 
	   add ax,1000h 
	   mov es,ax  
cheak_sm:
      push cx
      mov cx,65536
cheak_S:	  
      mov al,es:[bx+si]
      cmp al,si_string[di]
	  JZ cheak_2
      jmp next_char	
	;-----------------------
cheak_2:
     ; mov 
      inc si
      inc di 	  
	  mov al,es:[bx+si]
	  cmp al,si_string[di]
	  jz cheak_3
	  ;JZ display_address
      dec si
      dec di
      jmp next_char	  
	 
cheak_3:  
   	 inc si 
	 inc di 
	 mov al,es:[bx+si]
	 cmp al,si_string[di]
	 jz cheak_4
	 dec si
     ;dec si 
     dec di 	 
	 dec di
     jmp next_char
cheak_4:  
     inc si 
     inc di 
     mov al,es:[bx+si]
     cmp al,si_string[di]
     jz display_address
     dec si 
     dec di 
     dec di 
     dec di 	 
	 ;	  cheak_M
  next_char:
      INC SI 
	  loop cheak_S
	  pop cx 
   loop  add_es
PUSHA 
	  mov bh,0 
        mov dh,3    ;放入行号
        mov dl,3    ;放入列号
        mov ah,02h	  
        int 10h
		POPA   
	  msg not_find
	  jmp  stop 
display_address:
      dec si 
	  PUSHA 
	  mov bh,0 
        mov dh,3    ;放入行号
        mov dl,3    ;放入列号
        mov ah,02h	  
        int 10h
		POPA
      msg address
      pusha 
      mov ax,si
      add bx,ax  
      mov bx_seg,ebx  
      popa 	 
      xor eax,eax 	  
      mov eax,es 
      shl eax,16 
	  
	  add eax, bx_seg 
	  sub eax,2 
	  
	  call display_eax_s
	  
	 call write_enable
	  
	  
	  mov bx,word ptr bx_seg
	  sub bx,2
	  mov si,0 
	  mov di,0 
	  mov cx,4 
write_again:	  
	  mov al,di_string[di]
	  mov  es:[bx+si],al
      inc si 
      inc di 	  
      loop write_again  	  
	  
stop:
     NO_INPUT_SHADOW: 
       
     
	       
        mov ah,11H    
        int 16H      ;检测按键是有否按下，有则判断按键是否是ESC,否则继续刷新
        jz NO_INPUT_SHADOW
        mov ah,0
        int 16h  
        cmp al,'q'     ;若为Q\q 键则退出
        jz  first_screen	 
        cmp al,'Q'     ;若为Q\q 键则退出
        jz  first_screen
        jmp NO_INPUT_SHADOW		
.exit 
     write_enable proc 
	 pusha 
      xor eax,eax
      mov al,90h 
      or eax,80000000h 
      mov dx,0cf8h
      out dx,eax 
      
      mov eax,33333333h
      mov dx,0cfch 
      out dx,eax 
      
      xor eax,eax 
	  mov al,94h 
	  or eax,80000000h
	  mov dx,0cf8h
	  out dx,eax 
	
      mov eax,33333333h	  
      mov dx,0cfch 
	  out dx,eax
popa	  
	  ret 
	 
	  write_enable endp 

 display_eax_s proc far
	   pusha
	   mov cx,4 
	   ;and eax,eax 
 display_al:        
    		
       rol eax,8 
	   call assc		
       cmp cx,3 
       jnz  continue_al
	   msg  fuhao
 continue_al:	  
       loop display_al
      	  
       popa
       ret 
 display_eax_s  endp 

; assc proc far               ;hex to asscii from al 
			   ; PUSHA
			   ; ; cmp al,0ffh 
			   ; ; jz 
            
			   ; mov bl,al              ;reserve al_high
			   ; shr al,4               
			   ; add al,30h             ;将高四位转换成对应的十六进制数字
			   ; cmp al,'9'             ;判断位数是否大于 9   大于则对其ASCII码值加7转换成16进制
			   ; jLE  next11
			   ; add al,7
	 ; next11:
			   ; mov dl,al
			   ; mov ah,2               ;调用DOS功能显示高四位对应的数字
			   ; int 21h
			   ; and bl,0fh
			   ; mov dl,bl
			   ; add dl,30h
			   ; cmp Dl,'9'             ;调用DOS功能显示低四位对应的数字
			   ; jLE  next22
			   ; add Dl,7
	   ; next22:
			   ; mov ah,2
			   ; int 21h 
			
                
			   ; popa
			
			  ; ret
			; assc endp

 ; clear_screen  proc far
  ; ; protec registers
   ; push ax
   ; push bx 
   ; push cx 
   ; push dx
  ; ;clear_screen
  ; mov ah,6 
  ; mov al,0 
  ; mov bh,27h 
  ; mov ch,0 
  ; mov cl,0 
  ; mov dh,24
  ; mov dl,79
  ; int 10h
  ; ;locate_cussor
  ; mov dx,0 
  ; mov ah,2 
  ; int 10h
  ; ;restore registers
  
  ; pop dx 
  ; pop cx 
  ; pop bx 
  ; pop ax 
  ; ret 
  ; clear_screen endp
end 