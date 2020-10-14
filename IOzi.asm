;*******************************************
;*******************************************
;功能实现对指定内存地址值得显示
;使用说明
;程序运行的任意时刻 ESC按下退出程序   按下TAB键改写入口地址

;*******************************************
;******************************************
.model small
.486
public data_IO,get_key_IO,display_IO
EXTRN asstohex:far,locate_X_Y:far,locate_DH_DY:far,recover:far,hide:far,hex:far,hang_lie_display:far,
      clear_screen:far,first_screen_h:byte,space:far,asscii:far,W_H:BYTE,W_L:BYTE,
	  first_screen:far,D_H:BYTE,D_L:BYTE,row:byte,cont1:word,D_H_CHANGE:byte,back_ground_color:word
	  
EXTRN   es_seg:word,display_coordinate_xy:far,coordinate_xy:byte,off_set_num:byte,		
        display_del:far,display_nul:far,clear_one_charact:far,clear_front_address:far,locate_write_X_Y:far	  
.data 
write_data_IO   db 2 dup(?)
 ;IO DW 0   ;IO 地址
 IO_data db 256 dup(?)
 write_data_value_IO  db  0
 MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$'
 MESG_IO DB 'IO SPACE:','$' 
 addr_off_seg_IO DB 4 DUP(?) 
 .code
          include MACRO_zifu.MAC
;------------------------------------------
 display_IO:
         MOV coordinate_xy,0
         MOV W_H,4
         MOV W_L,4
LOCATE_IO_START:
        mov back_ground_color,29h 
        CALL clear_screen 
LOCATE_IO:
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
        mov bh,0 
        mov dh,1    ;放入行号
        mov dl,3     ;放入列号
        mov ah,02h	  
        int 10h;
        pop ax
        pop dx 
        pop bx 
        msg  MESG_IO	
        call get_key_IO		   
        call hide 
COLOUR_IO: 
        call hang_lie_display	
        call display_coordinate_xy		
		
           
            
NO_INPUT_IO: 
        call hide 
NO_INPUT_I:		
        call load_IO_data        
        call data_IO 
		call data_IO_assc
     
	       
        mov ah,11H    
        int 16H      ;检测按键是有否按下，有则判断按键是否是ESC,否则继续刷新
        jz NO_INPUT_I
       


    	mov ah,0
        int 16h  
       
       ;------------------
	   cmp al,0dh 
       jz enter_write_IO
       jmp cmp_table_I0
	   
enter_write_IO:	
    		
	call write_IO
	call hide
	mov al,write_data_value_IO
	mov bl,coordinate_xy
	mov bh,0 
	;mov si,0 
	mov dx,es_seg
	add dx,bX 
	;mov dx,00H
	
	out dx,al 
	jmp 	NO_INPUT_IO
	   
	;**********************************************
cmp_table_I0:       
        cmp al,9         ;若为'tab'则重新输入地址
        jz   LOCATE_IO 
		
		cmp ah,01h     ;QUIIT:ESC
        jz  first_screen
		cmp ah,48h                     ;up
            jz  cmp_al_up_I0
            jmp  cmp_ah_down_IO 			
cmp_al_up_I0:  cmp al,38h 
               			
	        jnz ADD_coordinate_xy_IO 
			
;-------------------------------		
cmp_ah_down_IO:	
      	    cmp ah,50h 
            jz cmp_al_down_IO
            jmp cmp_ah_left_IO			
cmp_al_down_IO: 
            cmp al,32h 			
                                 			;down
			jnz DEC_coordinate_xy_IO
;---------------------------------			
cmp_ah_left_IO:			
            cmp ah,4bh                     ;left
			jz cmp_al_left_IO 
			jmp cmp_ah_right_IO 
cmp_al_left_IO:  
            cmp al,34h 
			jnz  dec_coordinate_xy_16_IO
			
			
			
;----------------------------------			
cmp_ah_right_IO:
			CMP Ah,4dh
            jz  cmp_al_right_IO 
            jmp NO_INPUT_I         			;right
cmp_al_right_IO:
            cmp al,36h 			
		    JnZ  ADD_coordinate_xy_16_IO		
            jmp NO_INPUT_I
;-------------------------------------------------		
            
ADD_coordinate_xy_IO:
			;CALL locate_write_FX_FY
			dec W_H
			cmp W_H,04H
            JNC NO_INPUT_ADDC_IO
			MOV W_H,4 
			
			jmp  COLOUR_IO
NO_INPUT_ADDC_IO:  
            SUB coordinate_xy,10h
            
            jmp  COLOUR_IO			
			
DEC_coordinate_xy_IO:			
			 
			
			inc W_H
            cmp W_H,14H 
            JC NO_INPUT_DEEC_IO
            MOV W_H,13H  			
			jmp  COLOUR_IO
NO_INPUT_DEEC_IO: 
            ADD coordinate_xy,10h
            
            JMP COLOUR_IO			
dec_coordinate_xy_16_IO:
            
			
            SUB W_L,3 
            cmp W_L,3 
            JNC  NO_INPUT_ADD16_IO
            MOV  W_L,4			
			jmp COLOUR_IO
NO_INPUT_ADD16_IO:
            DEC coordinate_xy
            
            JMP COLOUR_IO			
ADD_coordinate_xy_16_IO:
             
			
            
            ADD W_L,3	
            CMP W_L,50
            JC	NO_INPUT_DEEC16_IO
            MOV W_L,31H			
            jmp COLOUR_IO
NO_INPUT_DEEC16_IO:
            INC coordinate_xy
           
            jmp COLOUR_IO	
		
		
		
		
        jmp  NO_INPUT_IO
 ;*******************************************
 ;restore IO data to  IO_data[256] 
 load_IO_data proc far 
		    pusha
		  
            mov dx,es_seg
            			
          	mov di,0 	 
            mov si,0 
            mov cx,256 
load_IO_data_again:		 
		    
			in al,dx           ;将IO地址赋值给al
            mov IO_data[di],al 
		  
			inc dx  
			inc di 
			loop load_IO_data_again
    		popa 
            ret 
		   load_IO_data endp
;******************************************
;************display_IO data*************
;***********input:IO_data ***************

			data_IO proc FAR
STAR_IO:   
	        PUSHA
	       
			mov di,0
			mov si,0 
		    mov cx,256          ;循环256次
						
			mov D_H,4
			MOV D_L,4
			mov D_H_CHANGE,4 
			call locate_DH_DY
			
			
xunhuan_IO:  
            mov al,IO_data[si] 
			
			push ax 
			mov ax,si 
		    mov off_set_num,al  
			pop ax 
     
            call   asstohex      ;将al的值转化为ASCII码 显示
         	call   space
			inc cont1            ;换行控制   每显示16个地址换一行
			inc si 
            cmp cont1,16
			jz  DINGWEI_IO         ;换行计数标志到16则换行，否则退出子程序
			jmp tuichu_IO 
   DINGWEI_IO:
            mov cont1,0
	        INC D_H_CHANGE
			MOV AL,D_H_CHANGE
			MOV D_H,AL
		    CALL locate_DH_DY 
       
  	   tuichu_IO:
			dec cx               ;计数标志减1
            cmp cx,0            ;如果循环计数标志不为零，则继续循环否则程序停止
            jnz  xunhuan_IO			
			POPA
			RET  
	data_IO endp	
			
			 data_IO_assc proc  far 
	      
	 STAR_MEMERY_assc:
        	pusha
	        mov cx,16          ;循环256次
			mov si,0 
			mov D_H,4
			MOV D_L,55
			mov D_H_CHANGE,4     ;数据显示定位到初始位置
			CALL locate_DH_DY
xunhuan_MEMERY_assc:  
            push cx                  
		    mov cx,16            ;每次显示16个数
again_MEMORY_assc:  
            mov al,IO_data[si]    ;将内存地址赋值给al		   
           push ax 
			mov ax,si 
		    mov off_set_num,al  
			pop ax 
  		    call   asscii      ;将al的值转化为ASCII码 显示16组数据 
            ;call   space
			inc   si             ;指向下一个地址
            inc cont1            ;换行控制   每显示玩一次数据加一，读满16个数换一行		   
		    loop again_MEMORY_assc    ;接着返回读下一个数据
		    pop CX 	
			
		    cmp cont1,16
			
			 jz  DINGWEI_MEMERY_assc         ;换行计数标志到16则换行定位程序，否则退出子程序
			
			
			 jmp tuichu_MEMERY_assc
    DINGWEI_MEMERY_assc:
             mov cont1,0
	         INC D_H_CHANGE            ;行变化计数加一
			 MOV AL,D_H_CHANGE         ;将变化量传给D_H 
			 MOV D_H,AL
		     CALL locate_DH_DY         ;定位
     
  	tuichu_MEMERY_assc:
			dec cx               ;计数标志减1
            cmp cx,0            ;如果循环计数标志不为零，则继续循环否则程序停止
            jnz  xunhuan_MEMERY_assc
           popa 			
			RET  
			
			
		data_IO_assc endp
			
	
;**********按键输入子程序*************
;*****入口参数 cx ax dx 
;     出口参数  es_seg
;**********************************
	get_key_IO proc FAR  ;按键输入子程序
			push cx
			push ax
			push dx
			push bx
			;push di
			PUSH SI 
			MOV SI,3
			;mov di,3
			mov cx,4
			call  clear_front_address
			call recover
	   
get_key2_IO:
       
           mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		   
           cmp al,08h 
		   jz back1
		   jmp bb1
back1:     
           cmp cx,4 
		   jz  get_key2_IO
		   jc  clear_char1 
		   jmp get_key2_IO
clear_char1: 
           inc si 
           call clear_one_charact  
           inc cx 
		   
	bb1:
		   
		   
		   cmp al,27     ;若为esc键则退出
		   jz  first_screen
		   
		   
			cmp al,9         ;tab 
			jz    LOCATE_IO
			cmp al,'f'     ;若果数值不小于f 则重新输入                
			ja get_key2_IO   ; a <ASCII <f   
			cmp al,'a'     ;若数值大于等于a
			;jNB next22_IO 
        	jnb  turn_capIO2 
			jmp  FFIO2
turn_capIO2:  
           sub  al,32
		   jmp next22_IO

            			    ; a <=ASCII <=f
FFIO2:			
		
			cmp al,'F'
			Ja  get_key2_IO      ;A<ASCII<F
			cmp  al,'A'
			jnb next22_IO
        
			cmp al,'9'
			Ja get_key2_IO
			cmp al,'0'
			jNB  next22_IO
			jmp get_key2_IO		
		next22_IO:
			; mov bl,aL
			; mov ah,2
			; mov dl,bl
			; int  21h
			pusha
            mov ah,9
			mov bh,0 
			mov bl,27h 
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
			
			
			
            call hex
			mov addr_off_seg_IO[Si],al 
			;inc di 
			
			
            DEc Si 			
			dec  cx 
			cmp  cx,0
			jnz get_key2_IO 
		   
		   
		    MOV Al,addr_off_seg_IO[3]
		    shl al,4 
			  
	        add Al,addr_off_seg_IO[2]
			mov ah,al 
			                             ;合并所得到的数据
			                                
		    mov al,addr_off_seg_IO[1]
		    shl al,4
			  
		    add al,addr_off_seg_IO[0]
               
            mov es_seg,AX	
          ;-------------------------------         new line   		
			mov ah,2
			mov dl,10
			int 21h
			;mov cx,4
			
			POP SI            
		;	pop di 
			POP BX
			pop dx
			pop ax
			pop cx
			ret 
	 get_key_IO endp
	 
	 
	 write_IO proc FAR  ;按键输入子程序
			push cx
			push ax
			push dx
			push bx
			;push di
			PUSH SI 
			MOV SI,1
			;mov di,1
			mov cx,2
		    call locate_write_X_Y
	
           call recover
		   ; pusha
		   ; mov ah,1 
		   ; mov ch,3 
		   ; mov cl,3
           ; int 10h
           ; popa		   
write_data_I:
           mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		     
		   cmp al,08h 
		   jz backw1
		   jmp bbw1
backw1:    	 
           cmp cx,2 
		   jz  write_data_I
		   jc  clear_char1 
		   jmp bbw1
clear_char1: 
           inc si 
           call display_del  
           inc cx 
		   
	bbw1:     
	        call recover
			cmp al,1Bh       ;ESC :  cacel write 
     		jz NO_INPUT_I
			cmp al,'f'     ;若果数值不小于f 则重新输入                
			ja write_data_I   ; a <ASCII <f   
			cmp al,'a'     ;若数值大于等于a

        	jnb  turn_cap_number 
			jmp  write_number_2
turn_cap_number:  
           sub  al,32
		   jmp display_no

            			    ; a <=ASCII <=f
write_number_2:			
		
			cmp al,'F'
			Ja  write_data_I      ;A<ASCII<F
			cmp  al,'A'
			jnb display_no
        
			cmp al,'9'
			Ja write_data_I
			cmp al,'0'
			jNB  display_no
			jmp write_data_I		
		display_no:
			mov bl,aL
			mov ah,2
			mov dl,bl
			int  21h
            call hex
			mov write_data_IO[Si],al 
		 
			
			
            dec  si 			
			dec  cx 
			cmp  cx,0
			jnz write_data_I 
		   
		   
		     mov al,write_data_IO[1]
		     shl al,4
			  
		     add al,write_data_IO[0]
               
             mov write_data_value_IO,al 	
           ;-------------------------------         new line    		
           
no_enter:		   
		   call hide 
		   mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		   cmp al,1Bh       ;ESC :  cacel write 
     	   jz NO_INPUT_I
		   
		   cmp al,08h 
		   jz backw11
		   jmp bbw1111
backw11:    	 
           cmp cx,0 
		   
		   jz  clear_char3 
		   jmp bbw1
clear_char3: 
           inc si 
           call display_del  
           inc cx 
		   jmp bbw1
		   
		   
		   
	bbw1111:	
	
	      
		    cmp al,0dh      ;若果数值不小于f 则重新输入                
            jnz no_enter    ; a <ASCII <f 
			 			
			POP SI             
			POP BX
			pop dx
			pop ax
			pop cx
			ret 
	 write_IO endp
	
	 
	  end
			
