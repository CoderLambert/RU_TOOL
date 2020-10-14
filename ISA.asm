;*******************************************
;*******************************************
;功能实现对指定内存地址值得显示
;使用说明
;程序运行的任意时刻 ESC按下退出程序   按下TAB键改写入口地址

;*******************************************
;******************************************
.model medium
.486


EXTRN asstohex:far,locate_X_Y:far,locate_DH_DY:far,recover:far,hide:far,hex:far,hang_lie_display:far,
      clear_screen:far,first_screen_h:byte,space:far,asscii:far,W_H:BYTE,W_L:BYTE,port_cont:byte,es_seg:word,bx_seg:WORD,
	  first_screen:far,D_H:BYTE,D_L:BYTE,row:byte,cont1:word,D_H_CHANGE:byte,back_ground_color:word
EXTRN   display_coordinate_xy:far,coordinate_xy:byte,off_set_num:byte,clear_front_address:far,clear_one_charact:far,		
        display_del:far,display_nul:far,clear_one_charact:far,clear_front_address:far,locate_write_X_Y:far	  	  
PUBLIC  get_key_ISA,data_ISA,display_ISA  
.data 
	
	
     MESG_PORT DB '  Port:$'
     addr_seg_ISA    dB 4 DUP(?) ;按键数据寄存单元
     addr_off_seg_ISA DB 4 DUP(?)
     ISA_data db 256 dup(?)
     write_data_ISA  db 2 dup(?)
     write_data_value_ISA  db 0
     MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$';
     MESG_ISA DB '  ISA Space, Index:','$'
 .code
 display_ISA:
            INCLUDE MACRO_zifu.mac
            
             mov coordinate_xy,0
             mov W_H,4
             mov W_L,4
LOCATE_ISA_START:
             mov back_ground_color,29h 
			 call clear_screen
LOCATE_ISA :
			 mov D_H, 1
			 mov D_L, 2 
			 call  locate_DH_DY
			push bx
			push dx
			push ax 		
			mov bh,0 
			mov dh,23    
			mov dl,1     
			mov ah,02h	  
			int 10h;
			
			
			msg  MESG_RETURN

	        mov bh,0 
			mov dh,1    
			mov dl,3     
			mov ah,02h	  
			int 10h;
			pop ax
			pop dx 
			pop bx  
			 
			msg  MESG_ISA	
			call get_key_ISA		   
			CALL hide 
COLOUR_ISA: 
            call hang_lie_display	
            call display_coordinate_xy				 
				  
NO_INPUT_ISA:      
            CALL hide 
NO_INPUT_IS:		
            call load_ISA_data 		 
            call data_ISA 
            call data_ISA_assc
            
            mov ah,11h    
            int 16H         ;quit: esc 
            jz NO_INPUT_IS
				
            mov ah,0
            int 16h  
       
       ;------------------
            cmp al,0dh 
            jz enter_write_ISA
            jmp cmp_table_ISA
				
enter_write_ISA:	
    		
	       call write_ISA
	       call hide
	       
           mov dx,es_seg
	       mov al,coordinate_xy
	       out dx,al 
	
           mov dx,bx_seg 
           mov al,write_data_value_ISA           
           out dx,al 
           jmp  NO_INPUT_ISA				
				
				
				
				
		
		;**********************************************
				
				cmp_table_ISA:       
        
				cmp al,9           ;若为tab则重新输入地址
				JZ   LOCATE_ISA 
				
				cmp ah,01h     ;QUIIT:ESC
                jz  first_screen
		        cmp ah,48h                     ;up
                jz  cmp_al_up_I0
                jmp  cmp_ah_down_IO 			
cmp_al_up_I0:    cmp al,38h 
               			
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
            jmp NO_INPUT_IS         			;right
cmp_al_right_IO:
            cmp al,36h 			
		    JnZ  ADD_coordinate_xy_16_IO		
            jmp NO_INPUT_IS
;-------------------------------------------------		
            
ADD_coordinate_xy_IO:
			;CALL locate_write_FX_FY
			dec W_H
			cmp W_H,04H
            JNC NO_INPUT_ADDC_IO
			MOV W_H,4 
			
			jmp  COLOUR_ISA
NO_INPUT_ADDC_IO:  
            SUB coordinate_xy,10h
            
            jmp  COLOUR_ISA			
			
DEC_coordinate_xy_IO:			
			 
			;call locate_write_FX_FY
			inc W_H
            cmp W_H,14H 
            JC NO_INPUT_DEEC_IO
            MOV W_H,13H  			
			jmp  COLOUR_ISA
NO_INPUT_DEEC_IO: 
            ADD coordinate_xy,10h
            
            JMP COLOUR_ISA			
dec_coordinate_xy_16_IO:
            
			;call locate_write_FX_FY
            SUB W_L,3 
            cmp W_L,3 
            JNC  NO_INPUT_ADD16_IO
            MOV  W_L,4			
			jmp COLOUR_ISA
NO_INPUT_ADD16_IO:
            DEC coordinate_xy
            
            JMP COLOUR_ISA			
ADD_coordinate_xy_16_IO:
             
			
            
            ADD W_L,3	
            CMP W_L,50
            JC	NO_INPUT_DEEC16_IO
            MOV W_L,31H			
            jmp COLOUR_ISA
NO_INPUT_DEEC16_IO:
            INC coordinate_xy
           
            jmp COLOUR_ISA	
		
		
		
		
        
				
				JMP NO_INPUT_ISA
			
			
		 load_ISA_data proc far 
		    pusha
		    
            ;mov dx,es_seg
            			
          	mov di,0 	 
            mov si,0 
            mov cx,256 
load_IO_data_again:		 
		    
			mov Dx,es_seg
			mov AL,port_cont            ;
			OUT DX,AL 
			
			MOV DX,bx_seg
			IN AL,DX 
			
			
            mov ISA_data[di],al 
		  
			;inc dx  
			inc di 
			inc si               ;si指向下一个地址
			mov bl, port_cont
			inc bl 
			mov port_cont,bl
			loop load_IO_data_again
    		popa 
            ret 
		   load_ISA_data endp	
			
			
			
			
			
			
            data_ISA proc far
	      
	         PushA
			 call hide
			 mov si,0 
	         mov cx,256          ;循环256次
			 MOV port_cont,0     
	         mov D_H,4
			 MOV D_L,4
			 mov D_H_CHANGE,4 
			 CALL locate_DH_DY
xunhuan_ISA:  
           
        
			; mov Dx,es_seg
			; mov AL,port_cont            ;确定首地址
			; OUT DX,AL 
			
			; MOV DX,bx_seg
			; IN AL,DX 
            
			mov  al,ISA_data[si]
			push ax 
			mov ax,si 
		    mov off_set_num,al  
			pop ax 
            call   asstohex      ;将al的值转化为ASCII码 显示
            call  space       
		    inc si               ;si指向下一个地址
			
			;mov bl, port_cont
			;inc bl 
			;mov port_cont,bl 
         	inc cont1            ;换行控制   每显示16个地址换一行
			cmp cont1,16
			
			jz  DINGWEI_ISA         ;换行计数标志到16则换行，否则退出子程序
			
			
			jmp tuichu_ISA
   DINGWEI_ISA:
            mov cont1,0
	        INC D_H_CHANGE
			MOV AL,D_H_CHANGE
			MOV D_H,AL
		    CALL locate_DH_DY 
       
  	   tuichu_ISA:
			
			dec cx               ;计数标志减1
            cmp cx,0            ;如果循环计数标志不为零，则继续循环否则程序停止
            jnz  xunhuan_ISA
            POPA  			
			RET  
			
			
		   data_ISA endp	
	;-------------------------------


 data_ISA_assc proc  far 
	      
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
            mov al,ISA_data[si]    ;将内存地址赋值给al		   
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
			
			
		data_ISA_assc endp	
	  
	 
;**********按键输入子程序*************
;*****入口参数 cx ax dx 
;**********************************
	get_key_ISA proc FAR  ;按键输入子程序
			push cx
			push ax
			push dx
			push bx
			push di
			PUSH SI 
			MOV SI,3
			mov di,3
			mov cx,4
            call clear_front_address
			call recover
	get_key_ISA1:
   
			mov ah,0
			int 16h            ;读键盘输入一个字符，不回显
           
           cmp al,08h 
		   jz back1
		   jmp bb1
back1:     
           cmp cx,4 
		   jz  get_key_ISA1
		   jc  clear_char1 
		   jmp get_key_ISA1
clear_char1: 
           inc di 
           call clear_one_charact  
           inc cx 
		   
	bb1:
           cmp al,27     ;esc  
           jz  first_screen
             		 
			
			CMP AL,9
			JZ  LOCATE_ISA_START
			cmp al,'f'                         
			Ja get_key_ISA1        ; a <ASCII <f   
			cmp al,'a'         
			jNB  turn_capM1 
			jmp  FFM1
turn_capM1:   sub  al,32
		   jmp 	continue1M 
        
		FFM1:
			cmp al,'F'
			Ja  get_key_ISA1      ;A<ASCII<F
			cmp  al,'A'
			jnb continue1M 
        
			cmp al,'9'
			Ja get_key_ISA1
			cmp al,'0'         ;0<=ASCII<=F
			jNB  continue1M 
			jmp get_key_ISA1 

             continue1M :
			mov bl,aL          
			
			mov ah,2          ;
			mov dl,bl
			int  21h
			call hex
			mov addr_seg_ISA[di],al 
			
		
			
            DEc di 
			dec cx 
			cmp cx,0
			jnz  get_key_ISA1             
	
			
						
            
			;jnz  get_key_ISA1 
			mov cx,4
            mov ah,2 
                       
			msg  MESG_PORT 
			
			mov di,0 
			
            
			  MOV Al,addr_seg_ISA[3]
			  shl al,4 
			                                 ;合并所得到的数据
			  add Al,addr_seg_ISA[2]
			  mov ah,al 
			 
			  
			  mov al,addr_seg_ISA[1]
			  shl al,4
			  
			  add al,addr_seg_ISA[0]
               
              mov es_seg,AX			  
   			
         
		
	get_key_ISA2:
        mov ah,0
        int 16h        ;读键盘输入一个字符，不回显
        cmp al,08h 
        jz back2
        jmp bb2
back2:     
        cmp cx,4 
        jz  get_key_ISA2
        jc  clear_char 
        jmp get_key_ISA2
clear_char: 
        inc si 
        call clear_one_charact     

        inc cx 
        jmp  get_key_ISA2
        
bb2:
        cmp al,27     ;esc  
        jz  first_screen
 
        CMP AL,9
        JZ  LOCATE_ISA_START
        cmp al,'f'                     
        Ja get_key_ISA2      
        cmp al,'a'     
        jNB  turn_capM2 
        jmp  FFM2
turn_capM2:   sub  al,32
        jmp continue2M 
                               ; a <=ASCII <=f
FFM2:       
        jNB continue2M 
            cmp al,'F'
        Ja  get_key_ISA2      ;A<=ASCII<=F  
        cmp  al,'A'
        jnb continue2M
        
			cmp al,'9'
			Ja get_key_ISA2        
			cmp al,'0'       ;0<=ASCII<=F  
			jNB  continue2M
			jmp get_key_ISA2 		
		continue2M:
			mov bl,aL
			mov ah,2
			mov dl,bl
			int  21h
            call hex
			mov addr_off_seg_ISA[Si],al 
			inc di
			
            DEc Si 			
			dec  cx 
			cmp  cx,0
			jnz  get_key_ISA2 
		   
		   
		    MOV Al,addr_off_seg_ISA[3]
		    shl al,4 
			  
	        add Al,addr_off_seg_ISA[2]
			mov ah,al 
			 
			  
		    mov al,addr_off_seg_ISA[1]
		    shl al,4
			  
		    add al,addr_off_seg_ISA[0]
               
              mov bx_seg,AX	
            		
			mov ah,2
			mov dl,10
			int 21h
			mov cx,4
			
			POP SI            
			pop di 
			POP BX
			pop dx
			pop ax
			pop cx
			ret 
	 get_key_ISA endp
;--------------------------------
        write_ISA proc FAR  ;按键输入子程序
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
     		jz NO_INPUT_IS
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
			mov write_data_ISA[Si],al 
		 
			
			
            dec  si 			
			dec  cx 
			cmp  cx,0
			jnz write_data_I 
		   
		   
		     mov al,write_data_ISA[1]
		     shl al,4
			  
		     add al,write_data_ISA[0]
               
             mov write_data_value_ISA,al 	
           ;-------------------------------         new line    		
           
no_enter:		   
		   call hide 
		   mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		   cmp al,1Bh       ;ESC :  cacel write 
     	   jz NO_INPUT_IS
		   
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
	 write_ISA endp


	 
	  end
			
