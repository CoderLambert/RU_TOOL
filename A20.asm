.model small 
.586 
public display_a20
extrn  first_screen:far,QUIT:far,clear_screen:far,ib_free:far  
.data 
kbc_satte_present db 'kbc present now ','$'
kbc_satte_not_present db 'kbc not present now ','$'
  msg_enable_fast_ga20  db 'enable  a20      ','$'
  msg_disable_fast_ga20 db 'disable  a20      ','$'
  msg_port     db'1.enable  a20       2.disable  a20','$'
  msg_kbc     db'3.enable  a20       4.disable  a20(keyboarf controler)','$' 
  msg_enable_fast_kbc  db 'enable a20 by keboard          ','$'
  msg_disable_fast_kbc  db 'disable a20 by keboard          ','$'
  MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$'
  .code 
 
  display_a20:
   include MACRO_zifu.MAC 
   call clear_screen
 
        mov BH,0 
	    MOV DH,1    ;放入行号
	    MOV DL,3     ;放入列号
        mov AH,02h	  
	    INT 10H;
 	
 msg msg_port
 
        mov bh,0 
	    mov dh,23    ;放入行号
	    mov dl,1     ;放入列号
        mov ah,02h	  
	    int 10h;
		
		
	    msg  MESG_RETURN

 
		NO_INPUT_key:
		 
		 push ax 
         push bx 
         push dx 
         mov BH,0 
	     MOV DH,3    ;放入行号
	     MOV DL,3     ;放入列号
         mov AH,02h	  ;display start point 
	     INT 10H;
         pop dx 
         pop bx 
         pop ax 	
         	 MOV AH,11H    
		 	 INT 16H      ;检测按键是有否按下，有则判断按键是否是ESC,否则继续刷新
             jz NO_INPUT_key
			 mov ah,0
			 int 16h
			 
			 cmp ah,01h     ;若为Q 键则退到主界面
			 jz  first_screen
			 ; cmp  al,'1'
			 ; jz   enable_fast_ga20
			
			 cmp al,'1'
			 jz  enable_addr_bit_20 
			 cmp al,'2'
			 jz  disable_addr_bit_20
			 jmp NO_INPUT_key
			 




enable_addr_bit_20:
mov ah, 0DFh ; Data for output port to enable A20.
ed_00:
mov al, 0D1h
out 64h, al
ed_01:
 jcxz $+2
in al, 64h
cmp al, 0FFh

je kbc_not_present
call ib_free
mov al, ah
out 60h, al

msg msg_enable_fast_kbc
JMP NO_INPUT_key

kbc_not_present:

mov al, 02h
out 92h, al
cmp sp, sp ; ZF - Indicates Gate-A20 enabled.

msg msg_enable_fast_ga20
jmp NO_INPUT_key





disable_addr_bit_20 :
mov ah, 0DDh ; Data for output port to disable A20.
ed_2:
mov al, 0D1h
out 64h, al
ed_21:
 jcxz $+2
in al, 64h
cmp al, 0FFh

jz kbc_not_present1
call ib_free
mov al,ah 
out 60h,al 


msg msg_disable_fast_kbc

jmp NO_INPUT_key

kbc_not_present1:

mov al, 00h
out 92h, al
cmp sp, sp ; ZF - Indicates Gate-A20 disabled.
msg msg_disable_fast_ga20

JMP NO_INPUT_key

   END 