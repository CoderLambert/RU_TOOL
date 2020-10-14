.model small
.586
extrn hide:far,recover:far, hex:far,locate_DH_DY:far,locate_X_Y:far,clear_screen:far,
      H:byte,L:BYTE,D_H:BYTE,D_L:BYTE,row:byte,cont1:word,D_H_CHANGE:byte,
	  H_CHANGE:BYTE,DELAY_LONG:FAR,DELAY_MUSIC:FAR,DELAY_SHORT:FAR,
	  first_screen_h:byte,first_screen:far,space:far

public display_BEEP
.data
  MESG_BEEP DB '1-7 Play piano      8.Long sound       9.Short sound     ','$'
  MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$'
  .code 
display_BEEP:
 INCLUDE MACRO_zifu.MAC 
LOCATE_BEEP_START:
	  CALL clear_screen 
      LOCATE_BEEP:
	     mov D_H, 1
	     MOV D_L, 2 
	     call  locate_DH_DY
		 push bx
        push dx
        push ax 		
	   mov bh,0 
	    mov dh,23    ;放入行号
	    mov dl,1     ;放入列号
        mov ah,02h	  
	    int 10h;
		
		
	    msg  MESG_RETURN
		mov BH,0 
	    MOV DH,1    ;放入行号
	    MOV DL,3     ;放入列号
        mov AH,02h	  
	    INT 10H;
  		POP AX
		POP DX 
		POP BX 
		 msg  MESG_BEEP	
         ;call get_key_IO		   
         ;call hide 
              mov BH,0 
	    MOV DH,1    ;放入行号
	    MOV DL,1     ;放入列号
        mov AH,02h	  
	    INT 10H;
          msg  MESG_BEEP	
 STAR_BEEP:      
 

			 mov ah,0
			 int 16h
			  
			 cmp al,'1'     
			 jz  BEEP1
			 cmp al,'2'    
			 JZ  BEEP2
			  cmp al,'3'     
			 JZ  BEEP3
			 CMP AL,'4'    
			 JZ  BEEP4
			  CMP AL,'5'     
			 JZ  BEEP5
			 CMP AL,'6'    
			 JZ  BEEP6
             CMP AL,'7'     
			 JZ  BEEP7
             CMP AL,'8'
             JZ   BEEP_long
             cmp al,'9'
             jz   BEEP_short			 ; ;********************************************** 
             cmp ah,01h
             jz  first_screen	
 
  	
     	 
 BEEP1: 
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,2281
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_MUSIC  
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
  JMP STAR_BEEP





 BEEP2:
  
  ; ;*****************************
; ;8254计数器2设置，产生600HZ声音
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,2032
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_MUSIC  
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
  JMP STAR_BEEP
BEEP3:
  
  ; ;*****************************
; ;8254计数器2设置，产生600HZ声音
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,1810
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_MUSIC 
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
  JMP STAR_BEEP
  
  BEEP4:
  
  ; ;*****************************
; ;8254计数器2设置，产生600HZ声音
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,1709
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_MUSIC 
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
  JMP STAR_BEEP
  BEEP5:
  
  ; ;*****************************
; ;8254计数器2设置，产生600HZ声音
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,1521
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_MUSIC 
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
 JMP STAR_BEEP
 
 BEEP6:
  
  ; ;*****************************
; ;8254计数器2设置，产生600HZ声音
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,1355
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_MUSIC 
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
 JMP STAR_BEEP
 BEEP7:
  
  ; ;*****************************
; ;8254计数器2设置，产生600HZ声音
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,1207
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_MUSIC 
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
 JMP STAR_BEEP
 
 BEEP_long: 
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,1000
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_LONG  
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
  JMP STAR_BEEP
  
  BEEP_short: 
 MOV AL,10110110B ;通道2，方式3,16位二进制
 OUT 43H,AL         
 MOV AX,1000
 OUT 42H,AL
 MOV AL,AH
 OUT 42H,AL 
 
 IN AL,61H
 MOV AH,AL
 OR AL,03h
 OUT 61H,AL
 CALL DELAY_SHORT  
 ; 延时
 in al,61H
 and al,0fch   ;关
 out 61H,al
  JMP STAR_BEEP

end