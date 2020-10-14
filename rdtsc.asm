.model small
.586
    ;extrn assc:far 
.data
    eax_bcd    dd 0  
    eax_data   dd 0
    ax_data    dw 0
	edx_data   dd 0 
    array      db 4 dup(?)
    number_1000 dd 1000000
    number_10   db 10
.code 
.startup 
 @:
  ;call clear_screen
 
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
  
  mov cx,18 
cont_1s:
    
  
  mov al,es:[bx+si]
wait_55ms:  
  cmp al,es:[bx+si]
  jz wait_55ms
  loop cont_1s
  
  rdtsc
  
  sub eax,eax_data
  sbb edx,edx_data
  
  mov eax_data,eax
  mov edx_data,edx 
  
  mov eax,eax_data

  call display_eax
  call space
  call space
  
  xor edx,edx
  div number_1000
   
  call display_eax
  popa 
  endp 
  frequz endp 
  ; mov ax_data,ax 
  ; call space 
  ; ; 
  ; div number_10 
  ; mov array[0],ah 
  
  ; and ax,0fh 
  ; div number_10 
  ; mov array[1],ah 

  ; ;mov   
  ; div number_10 
  ; mov array[2],dl
  
  ; mov al,array[0]
  ; call assc
  ; call space 
  
  ; mov al,array[1]
  ; call assc
  ; call space 
  
  ; mov al,array[2]
  ; call assc
  ; call space 
  
  
         
   jmp $
  
  
  
 
.exit

space  proc far  public
        
         mov ah,2
         mov dl,20H
         int 21H
       
         ret 
         space endp

clear_screen  proc far
  ; protec registers
   push ax
   push bx 
   push cx 
   push dx
  ;clear_screen
  mov ah,6 
  mov al,0 
  mov bh,27h 
  mov ch,0 
  mov cl,0 
  mov dh,24
  mov dl,79
  int 10h
  ;locate_cussor
  mov dx,0 
  mov ah,2 
  int 10h
  ;restore registers
  pop dx 
  pop cx 
  pop bx 
  pop ax 
  ret 
  clear_screen endp
  
display_eax proc far
	  pusha
	  mov cx,4 
	  ;and eax,eax 
display_al:        
    		
      rol eax,8 
	  call assc			
      loop display_al 
      popa
      ret 
display_eax  endp 


assc proc far               ;hex to asscii from al 
			   PUSHA
			   ; cmp al,0ffh 
			   ; jz 
            
			   mov bl,al              ;reserve al_high
			   shr al,4               
			   add al,30h             
			   cmp al,'9'             ;
			   jLE  next11
			   add al,7
	 next11:
			   mov dl,al
			   mov ah,2               ;high 
			   int 21h
			   and bl,0fh
			   mov dl,bl
			   add dl,30h
			   cmp Dl,'9'             ;low 
			   jLE  next22
			   add Dl,7
	   next22:
			   mov ah,2
			   int 21h 
			
                
			   popa
			
			  ret
			assc endp
end 