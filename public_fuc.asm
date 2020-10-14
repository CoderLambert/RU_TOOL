.model small
.486
PUBLIC  hide,recover,hex,asstohex,locate_DH_DY,locate_X_Y,clear_screen,hang_lie_display,DELAY_LONG,
        DELAY_MUSIC,DELAY_SHORT,rest_system,cheack_input_busy, 
		ib_free,assc,space,display_eax
extrn D_H:BYTE,D_L:BYTE,H:byte,L:byte,row:byte,cow:byte,H_CHANGE:BYTE,coordinate_xy:byte,
      W_H:byte,W_L:byte,off_set_num:byte,coordinate_xy:byte,
       back_ground_color:byte,number:byte,font_colour:byte,row_number:byte,cow_number:byte,start_cow:byte,start_row:byte
     ; W_H:BYTE,W_L:BYTE	   
      
  
.data 


.CODE 
        start_point proc far public   
	    PUSHA 
	    mov bh,0 
        mov dh,start_row   ;放入行号
        mov dl,start_cow    ;放入列号
        mov ah,02h	  
        int 10h
		POPA  
		ret 
        start_point  endp 


        menu_locate proc far public 
;--------------------------------------
;       input: row_number
;              cow_number 
;       output: NO    
		push bx 
		push dx 
		push ax 
		mov bh,0 
        mov dh,row_number    ;放入行号
        mov dl,cow_number    ;放入列号
        mov ah,02h	  
        int 10h
		pop ax 
		pop dx 
		pop bx 
        ret 
		menu_locate endp 


      locate_write_X_Y   proc far  PUBLIC  
	  pusha
	  mov BH,0 
	  MOV DH,W_H     ;放入行号
	  MOV DL,W_L    ;放入列号
      mov AH,02h	  
	  INT 10H;
	  popa
      ret
	  locate_write_X_Y endp
 ;********display  space*********** 		   
         space  proc far  public
         push ax
         push dx
         mov ah,2
         mov dl,20H
         int 21H
        ; mov ah,2
        ; mov dl,20H
        ; int 21H
         pop dx 
         pop ax 
         ret 
         space endp
         
         space_5 proc far public 
         pusha 
         mov cx,5 
 loop_space:
         call space 
        loop  loop_space
        popa 
        ret 
        space_5 endp         
         

;**************************


 ;********display  space*********** 		   
         asscii  proc far  public
         push ax
         push dx
		 
	     push ax 
         mov al,off_set_num
         cmp al,coordinate_xy
         jz  change_colour_high_back_assc 
         pop ax
         jmp normal_color_assc			
change_colour_high_back_assc:
         pop ax 
         mov font_colour,5bh         ;blue
         jmp  no_change_assc
;--------------------------------------------------
		 
normal_color_assc:	
            mov font_colour,2bh         ; 
no_change_assc:		 
        ; mov ah,9
         ;mov dl,al                   ;load al    check   dl  value    
		 cmp al,127                  ;>127   display_point
         jnc display_point	
         cmp al,31
		 jc display_point
         		 
        pusha
		 mov ah,9 
         ;mov al,46
		 mov bl,font_colour
		 mov bh,0 
         mov cx,1    		 ; '.' 
         int 10h		 
;-------------------------
         mov ah,3 
         mov bh,0 
         int 10h 
;-------------------------
			
         mov ah,2 
         add DL,1 
         MOV BH,0
         INT 10h			
;----------------------------
         popa 
		 jmp  next_asscii
		 
display_point:
         pusha
		 mov ah,9 
         mov al,46
		 mov bl,font_colour
		 mov bh,0 
         mov cx,1    		 ; '.' 
         int 10h		 
;-------------------------
         mov ah,3 
         mov bh,0 
         int 10h 
;-------------------------
			
         mov ah,2 
         add DL,1 
         MOV BH,0
         INT 10h			
;----------------------------
         popa 
next_asscii:
         pop dx 
         pop ax 
         ret 
         asscii endp

;**************************


;cheack 8042 input register bit1
cheack_input_busy proc far
	
	continue_cheack:
	    in al,64h              ;read status register
		test al,2             ;cheack bit 1
		jnz  continue_cheack
       
        ret 
    cheack_input_busy endp	
;**************************
;       reset_sysytem
;notice： test input register busy
rest_system  proc far 
	call cheack_input_busy
	mov al,0feH       
    OUT 64H,AL 
	jmp $
	ret 
	rest_system endp
	
	



;********************************************
;cheack input register (60h/64h) has data for 8042
        ib_free proc far  
       
ib_free_again:
        in al,64h
        test al,2
        jnz ib_free_again 
		
		ret 
		ib_free endp
		
		
 		
		
;************************************
;***********长延时*******************
DELAY_LONG proc far 
push ax
PUSH cx
MOV cx,0
D1:MOV ax,30000
D2:DEC ax 
   JNZ D2
   LOOP D1 
      
 POP cx
 pop ax 
 RET 
DELAY_LONG endp 
;************************************
;***********短延时*******************
DELAY_SHORT proc far 
 push ax
 PUSH CX
MOV CX,0
D11:MOV AX,2000
D22:DEC AX 
   JNZ D22
   LOOP D11 
       
 POP cX
 pop ax 
 RET 
DELAY_SHORT endp 
;************************************
;***********节拍延时*******************
DELAY_MUSIC proc far 
 push ax
 PUSH CX
MOV CX,0
D11:MOV AX,1500
D22:DEC AX 
   JNZ D22
   LOOP D11 
       
 POP cX
 pop ax 
 RET 
DELAY_MUSIC endp
        change_font_colour proc far public  
            push cx 
			push dx
            push ax 
            push bx 			
			mov ah,09 
			;mov al,0 
			mov bh,0 
			MOV AL,56h 
			mov bl,font_colour 
			mov cx,1 
			int 10h 
	       
			pop bx 
			pop ax 
			pop dx 
			pop cx 
			ret 
			change_font_colour endp 
			



change_font_colour_normal proc far public  
            push cx 
			push dx
            push ax 
            push bx 			
			mov ah,09 
			;mov al,0 
			mov bh,0 
			;MOV AL,56h 
			mov bl,font_colour 
			mov cx,1 
			int 10h 
	       
			pop bx 
			pop ax 
			pop dx 
			pop cx 
			ret 
			change_font_colour_normal endp 
;***************************************
;显示行列
;入口参数: H,L ,row,cow,H_CHANGE 
; 可独立使用
;注意，需要更改数字显示方式，
;如显示格式及修改读的位数时 可以修改本函数
;***************************************
 hang_lie_display proc FAR 
	        pusha 
			mov cx,16
			MOV BX,16 
	        mov H,3
			MOV L,4 
			mov row,0 
			mov cow,0
			mov H_CHANGE,4
			
		    call locate_X_Y
	 hang:  
	        push dx 
	        mov dl,coordinate_xy
			mov dh,dl 
			and dl,0fh
            ;shr dl,4 			
			cmp dl,cow 
			jz  high_color_cow
            pop dx 			
;----------------------------			
			mov font_colour,24h 
		    call change_font_colour
			jmp display_cow
high_color_cow:
            pop dx 
           	mov font_colour,2eh 
		    call change_font_colour
			jmp display_cow		
display_cow:		    
			mov al,cow  
			call asstohex_back
			call space                       ;coordinate_xy
			
			inc cow                          ;coordinate_xy=row+cow(<<4) 
			dec cx
			cmp cx,0
		    jz  lie_star
			jmp hang
 lie_star:  
            mov al,H_CHANGE
			mov H,al
            MOV L,1 
            CALL locate_X_Y			
	lie:   
	        push dx 
	        mov dl,coordinate_xy
			mov dh,dl 
			and dl,0f0h
            shr dl,4 			
			cmp dl,row 
			jz  high_color_row
            pop dx 		
			mov font_colour,24h 
		    call change_font_colour
			jmp display_row
high_color_row:
            pop dx 
           	mov font_colour,2eh 
		    call change_font_colour
			jmp display_row		
display_row:		    
			
           call change_font_colour
               
         	
		    mov al,row
			shl al,4
			call asstohex_back
		   
			inc row
			inc H_CHANGE 
			dec  bx
			cmp Bx,0
		    jz  jieshu
			jmp lie_star		
			
	       
	jieshu:	
	        popa
	        ret
	  hang_lie_display endp
	  
;**************************************
;backspace 
       display_del  proc far  public 
		    push ax 
		    push bx 
		    push dx 
            mov bl,08h  
			mov ah,2
			mov dl,bl
			int  21h
		    pop dx 
            pop bx 
            pop ax 
     		ret 
			display_del endp
	 
	 ;****************************
	 ;clear current charact
	 display_nul  proc far public 
		    push ax 
		    push bx 
		    push dx 
            mov bl,0        
			mov ah,2 
			mov dl,bl 
			int 21h 
		    pop dx 
            pop bx 
            pop ax 
     		ret 
	 display_nul endp 
	 
	 
;**********************************************		
		clear_one_charact    proc far public 
	     call display_nul
;----------------------------------	
         call display_del  		
		 call display_del 
;----------------------------------			
	     call display_nul   
;----------------------------------   tuige 			
         call display_del 
;------------------------------	  qingkong 		
         ret 
    clear_one_charact   endp 	
;*****************************************************        
    clear_front_address   proc   far public
		 pusha 
		 mov cx,50 
display_nul_again:
        call display_nul
        loop display_nul_again
                  
        mov cx,50 
display_del_again:
        call display_del
        loop display_del_again
        
        popa 
        ret
       clear_front_address endp  	  
	  
	  
	  
	  
;********display coordinate_xy***************
;*******input:                *************** 
	  display_coordinate_xy  proc far public 
	  
	  ;mov coordinate_xy,0 
	  mov H,3
	  mov L,1  
	  call locate_X_Y
	  mov font_colour,04fh 
	  call change_font_colour
	  mov al,coordinate_xy  
	  call asstohex_back 
	  call space
	  
	  
      ret 
      display_coordinate_xy endp	  
;***************************************
;将 AL中的值转化为对应的两位16进制
;入口参数: AL  
; 可独立使用
;注意，需要更改数字显示方式，
;如显示格式及修改读的位数时 可以修改本函数
;***************************************
	
				asstohex proc far               ;子程序 将AL中16进制转换成对应的ASCII码
			 PUSHA
			 push ax 
			 mov al,off_set_num
			 cmp al,coordinate_xy
			 jz  change_colour_high_back 
			 pop ax 
			 cmp al,0ffh 
			 jz change_cusor_colour_GREY
			 cmp al,0 
			 jz  change_cusor_colour_blue 
			 jmp normal_color
			
change_colour_high_back:
             pop ax 
             mov font_colour,05bh         ;blue
			
			 jmp  no_change
			
change_cusor_colour_blue:
     		 mov font_colour,28h         ;blue
			 
			 jmp  no_change
   ;-----------------------------------		   
normal_color:
            mov cl,4
			mov bl,al              ;保留高四位
			shr al,cl               
			add al,30h
     		 mov font_colour,2bh         ;blue
			 jmp  normal_change
   ;-------------------------------------
change_cusor_colour_GREY:
             mov font_colour,2ch
            			
no_change: 			
            mov cl,4
			mov bl,al              ;保留高四位
			shr al,cl               
			add al,30h             ;将高四位转换成对应的十六进制数字
		
normal_change:
     		cmp al,'9'             ;判断位数是否大于 9   大于则对其ASCII码值加7转换成16进制
			jLE  next11
			add al,7
	next11:
			                        ;调用DOS功能显示高四位对应的数字
			pusha
            mov ah,9
			mov bh,0 
			mov bl,font_colour 
			mov cx,1 
			int 10h 
			;-------------------------
			mov ah,3 
			mov bh,0 
			int 10h 
			;-------------------------
			
			mov ah,2 
			add DL,1 
			MOV BH,0
            INT 10h			
			;----------------------------
			popa 
			
			and bl,0fh
			mov dl,bl
			add dl,30h
			cmp Dl,'9'             ;调用DOS功能显示低四位对应的数字
			jLE  next22
			add Dl,7
	next22: 
			mov al,dl
			;-----------------------
			pusha
            mov ah,9
			mov bh,0 
			mov bl,font_colour 
			mov cx,1                      ;display colour charact
			int 10h 
			;-------------------------
			mov ah,3                      ;get now current
			mov bh,0 
			int 10h 
			;-------------------------
			                              ;move currsor point  next 
			mov ah,2 
			add DL,1 
			MOV BH,0
            INT 10h			
			;----------------------------
			popa 
	 
			popa
				
			ret
			asstohex endp
;-----------------------------------
	asstohex_color proc far    public           
			 PUSHA
			
			 
   ;-----------------------------------		   
normal_color:
            mov cl,4
			mov bl,al              ;保留高四位
			shr al,cl               
			add al,30h
     		 mov font_colour,2bh         ;blue
			 jmp  normal_change
   ;-------------------------------------
change_cusor_colour_GREY:
             mov font_colour,2ch
            			
no_change: 			
            mov cl,4
			mov bl,al              ;保留高四位
			shr al,cl               
			add al,30h             ;将高四位转换成对应的十六进制数字
		
normal_change:
     		cmp al,'9'             ;判断位数是否大于 9   大于则对其ASCII码值加7转换成16进制
			jLE  next11
			add al,7
	next11:
			                        ;调用DOS功能显示高四位对应的数字
			pusha
            mov ah,9
			mov bh,0 
			mov bl,font_colour 
			mov cx,1 
			int 10h 
			;-------------------------
			mov ah,3 
			mov bh,0 
			int 10h 
			;-------------------------
			
			mov ah,2 
			add DL,1 
			MOV BH,0
            INT 10h			
			;----------------------------
			popa 
			
			and bl,0fh
			mov dl,bl
			add dl,30h
			cmp Dl,'9'             ;调用DOS功能显示低四位对应的数字
			jLE  next22
			add Dl,7
	next22: 
			mov al,dl
			;-----------------------
			pusha
            mov ah,9
			mov bh,0 
			mov bl,font_colour 
			mov cx,1                      ;display colour charact
			int 10h 
			;-------------------------
			mov ah,3                      ;get now current
			mov bh,0 
			int 10h 
			;-------------------------
			                              ;move currsor point  next 
			mov ah,2 
			add DL,1 
			MOV BH,0
            INT 10h			
			;----------------------------
			popa 
	 
			popa
				
			ret
			asstohex_color endp			
			
asstohex_back proc far    public           ;子程序 将AL中16进制转换成对应的ASCII码
			PUSHA
			
            mov cl,4
			mov bl,al              ;保留高四位
			shr al,cl               
			add al,30h             ;将高四位转换成对应的十六进制数字
			cmp al,'9'             ;判断位数是否大于 9   大于则对其ASCII码值加7转换成16进制
			jLE  next11
			add al,7
	next11:
			mov dl,al
			mov ah,2               ;调用DOS功能显示高四位对应的数字
			int 21h
			
			call change_font_colour
			and bl,0fh
			mov dl,bl
			add dl,30h
			cmp Dl,'9'             ;调用DOS功能显示低四位对应的数字
			jLE  next22
			add Dl,7
	next22:
			mov ah,2
			int 21h
			popa
				
			ret
			asstohex_back endp			
			
			
  huiche  proc far  public
         push ax
         push dx
         mov ah,2
         mov dl,0aH
         int 21H
         mov ah,2
         mov dl,0dH
         int 21H
         pop dx 
         pop ax 
         ret 
         huiche endp
 

;*********数据光标定位子程序************
;***********************************
;入口参数 D_H    D_L
;刷新读取的内存参数时，使显示位置在原来地方
;***********************************
;光标定位
	 locate_DH_DY   proc  far
	  
	  push bx    ;页码
	  push dx    ;DH=行  DL=列 
	  mov BH,0 
	  MOV DH,D_H
	  MOV DL,D_L
      mov AH,02h	  
	  INT 10H;
	  POP DX
	  POP BX
	  ret
	 locate_DH_DY endp
	 
	  ;*********行列光标定位子程序************
	  ;*********显示行头与列头****************
	  ;***************************************
	  ;           可独立使用
   	  ;         入口参数 H , L 
	  ;***************************************
	  
	 locate_X_Y   proc  
	  
	  push bx    ;页码
	  push dx    ;DH=行  DL=列 
	  mov BH,0 
	  MOV DH,H     ;放入行号
	  MOV DL,L     ;放入列号
      mov AH,02h	  
	  INT 10H;
	  POP DX
	  POP BX
	  ret
	  locate_X_Y endp
	  
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
     
;-------------------------
     display_eax_asstohex_color proc far public 
	  pusha
	  mov cx,4 
	  ;and eax,eax 
display_all:        
    		
      rol eax,8 
	  call asstohex_color			
      loop display_all 
      popa
      ret 
display_eax_asstohex_color  endp 	 


    
     display_ax proc far public
	  pusha
	  mov cx,2 
	  ;and eax,eax 
display_al:        
    		
      rol ax,8 
	  call assc			
      loop display_al 
      popa
      ret 
display_ax  endp


display_char  proc far     public           
			   PUSHA
			  
			   mov dl,al
			   mov ah,2               ;high 
			   int 21h
			   
			   popa
			
			  ret
			display_char endp


;***********************************************************************************************

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
			

;***********************************************************************************************
;***************************************
;
;      可独立使用
;入口参数：AL
;出口参数：AL
;*****将键盘读到的值转化为十六进制******
	hex  proc   far 
	
      sub al,30h
      cmp al,9
      jbe  jieshu_HEX
      sub al,7
      cmp al,15
      jbe jieshu_HEX 
      sub al,20h
jieshu_HEX:ret
hex endp
;***********************
;
;      可独立使用
;
;*****隐藏光标**********
   hide  proc  far
   push cx
   push ax
   mov cx,2000h
   mov ah,1
   int 10h
   pop ax 
   pop cx 
   ret
   hide endp

;***********************
;
;      可独立使用
;
;*****恢复光标**********
  recover proc far 
  push cx 
  push ax
  MOV  AH,01H
  MOV  CX,0C0DH
  INT  10H 
  pop ax 
  pop cx 
  ret 	 
  recover endp 
;***********************
;
;      可独立使用
; 整个屏幕进行卷屏功能调用啊, 置 AL=0: 

  ; Interrupt:   10h     Functions:  06h and 07h

     ; Initializes a specified window of the display to ASCII blank
     ; characters with a given attribute, or scrolls the contents of
     ; a window by a specified number of lines.

     ; Input
     ; AH = 06h to scroll up
        ; = 07h to scroll down
     ; AL = Number of lines to scroll (if zero, entire window is blanked)
     ; BH = Attribute to be used for blanked area
     ; CH = y coordinate, upper left corner of window
     ; CL = x coordinate, upper left corner of window
     ; DH = y coordinate, lower right corner of window
     ; DL = x coordinate, lower right corner of window 
;
;*****清屏*****************************************
;  purpose:clear  screen  and set back_ground_color
;  input:back_ground_color
   clear_screen  proc far
  ; protec registers
   push ax
   push bx 
   push cx 
   push dx
  ;clear_screen
  mov ah,6 
  mov al,0 
  mov bh,back_ground_color
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
END 