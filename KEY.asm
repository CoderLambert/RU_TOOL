.MODEL  SMALL
.586
extrn recover:far,hide:far,hex:far,DELAY_LONG:FAR,DELAY_SHORT:FAR,
      clear_screen:far,first_screen_h:byte,space:far,cheack_input_busy:far,
	  first_screen:far,back_ground_color:word,rest_system:far
public  display_KEY
 .data
 MESG_KEY DB 'please input your number:','$'
 MESG_KEY_LED DB '1.led_display       2.rest system    Q.quit system','$' 
 MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$'
 .code 
display_KEY: 
 include MACRO_zifu.MAC
 call clear_screen
        mov bh,0 
        mov dh,0    ;放入行号
        mov dl,1     ;放入列号
        mov ah,02h	  
        int 10H;
        msg MESG_KEY
        mov bh,0 
        mov dh,2    ;放入行号
        mov dl,1     ;放入列号
        mov ah,02h	  
        int 10H;
        msg  MESG_KEY_LED
        
        mov bh,0 
        mov dh,23    ;放入行号
        mov dl,1     ;放入列号
        mov ah,02h	  
        int 10h;
		
		
	    msg  MESG_RETURN
  cheack_gain_key:
	
     		
	        mov ah,0
			int 16h            ;读键盘输入一个字符，不回显
			cmp al,'1'        ;若为1则进入1号功能
	        jz   led_display
			
			cmp  al,'2'
			JZ  rest_system  
			cmp ah,01h
			jZ first_screen
			
			JMP cheack_gain_key       ;mov cx,6

led_display:
	push ax 
	push bx 
	push cx 
	
    
    xor bx,bx
	mov bl,1
    mov cx,3 	
led_loop1:   
		
	call cheack_input_busy  ;读忙
    mov al,0edh 
	out 60h,al         ;发送设置命令

    call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
    mov al,bl
    out 60h,al
    call DELAY_LONG	
	call cheack_input_busy  ;读忙
     
	 mov al,0edh 
	 out 60h,al        ;发送设置命令 
                        ;回复结果     
     call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
     mov al,0  
     out 60h,al	
    shl bl,1                    ;回复结果 
    call DELAY_LONG
    loop led_loop1

	
	
	 
	 
    
	 mov cx,2  
led_loop2:	
	mov bx,3 
	call cheack_input_busy  ;读忙
     
	 mov al,0edh 
	 out 60h,al        ;发送设置命令 
                        ;回复结果     
     call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
     mov al,bl  
     out 60h,al	
	 shl bl,1
	  call DELAY_LONG	
	call cheack_input_busy  ;读忙
     
	 mov al,0edh 
	 out 60h,al        ;发送设置命令 
                        ;回复结果     
     call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
     mov al,0  
     out 60h,al	
   
	 loop led_loop2
	 
	 mov cx,3
	 
	 call cheack_input_busy  ;读忙
     
	 mov al,0edh 
	 out 60h,al        ;发送设置命令 
                        ;回复结果     
     call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
     mov al,03h  
     out 60h,al	
	 
	 mov al,0edh 
	 out 60h,al        ;发送设置命令 
                        ;回复结果     
     call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
     mov al,0  
     out 60h,al	
    shl bl,1                    ;回复结果 
    call DELAY_LONG
	 
	 call cheack_input_busy  ;读忙
     
	 mov al,0edh 
	 out 60h,al        ;发送设置命令 
 
     mov cx,3 
  led_loop3:                    ;回复结果     
    call cheack_input_busy  ;读忙
    mov al,0edh 
	out 60h,al         ;发送设置命令

    call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
    mov al,07H
    out 60h,al         ;LIGHT ALL      
    call DELAY_LONG	
     call cheack_input_busy  
	 mov al,0edh 
	 out 60h,al        ;发送设置命令 
                        ;回复结果     
     call cheack_input_busy  ;LED set_byte  0000 _ _ _ 0
     mov al,0  
     out 60h,al	
                          ;回复结果 
    call DELAY_LONG	 
	 
    pop ax     
	jmp cheack_gain_key	
	
	end 