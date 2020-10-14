.model small
.586
PUBLIC data_memory,get_key_MEMERY,display_memery,W_H,W_L,FW_H,FW_L
extrn   first_screen_h:byte,font_colour:byte,change_font_colour:far,cont1:word,
        locate_write_X_Y:far,D_H:BYTE,D_L:BYTE,row:byte,D_H_CHANGE:byte,clear_screen:far,
		hide:far,hang_lie_display:far,space:far,first_screen:far,recover:far,hex:far
		
extrn	locate_DH_DY:far,asstohex:far,back_ground_color:byte,asscii:far,asstohex_back:far,
		es_seg:word,bx_seg:word,display_coordinate_xy:far,coordinate_xy:byte,off_set_num:byte,		
        display_del:far,display_nul:far,clear_one_charact:far,clear_front_address:far
		
		.data
         
        W_H  db 4 
		W_L  db 4
		FW_H DB 0
		FW_L DB 0 
        restore_si   db 0 		
        addr_off_seg DB 4 DUP(?)  ;
        addr_seg  db 4 dup(?)     ;
		write_data_memory   db 2 dup(?)
		write_data_value   db 0 
        MESG_MEMORY DB 'Memory real:','$' 
        MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$'
		memory_data db 256 dup(?)
.CODE  
       include MACRO_zifu.MAC
display_memery:
       MOV coordinate_xy,0
       MOV W_H,4
       MOV W_L,4			 
LOCATE_MEMORY_START:
       mov back_ground_color,29h
	   call clear_screen
LOCATE_MEMORY_START_POINT:
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
        int 10h
		
        msg  MESG_RETURN

        mov bh,0 
        mov dh,1                  
        mov dl,3                   
        mov ah,02h	  
        int 10h
		
        pop ax
        pop dx 
        pop bx 
        msg  MESG_MEMORY		
        call get_key_MEMERY		   
        call hide
        
    COLOUR: 
        call hang_lie_display	
        call display_coordinate_xy
       
        	
NO_INPUT:
        call hide 
NO_INPUT_M:	
        call load_memeory_data 
        call data_memory 
        call data_memory_assc
	
       
			         
		mov ah,11H    
        int 16H      
        
		jz NO_INPUT_M
		
 ; change_cussor:  
	;********************************************** 
            mov ah,0
            int 16h 

			
            
			
			cmp al,0dh 
			jz enter_write
            jmp cmp_table			
enter_write:	
    		
	call write_memory
	call hide
	mov al,write_data_value
	mov bl,coordinate_xy
	mov bh,0 
	mov si,0 
	mov es:[bx+si],al 
	jmp 	NO_INPUT	
			; mov ah,0
            ; int 16h 
			
			
;----------------------------------
cmp_table:   	      
		    cmp al,9         ;table  rewrite address 
            jz LOCATE_MEMORY_START_POINT
            
			cmp ah,01h       ;return menu:ESC  
     		jz  first_screen
            
			cmp ah,48h                     ;up
            jz  cmp_al_up
            jmp  cmp_ah_down 			
cmp_al_up:  cmp al,38h 
               			
	        jnz ADD_coordinate_xy 
			
;-------------------------------		
cmp_ah_down:	
      	    cmp ah,50h 
            jz cmp_al_down
            jmp cmp_ah_left			
cmp_al_down: 
            cmp al,32h 			
                                 			;down
			jnz DEC_coordinate_xy
;---------------------------------			
cmp_ah_left:			
            cmp ah,4bh                     ;left
			jz cmp_al_left 
			jmp cmp_ah_right 
cmp_al_left:  
            cmp al,34h 
			jnz  dec_coordinate_xy_16
			
			
			
;----------------------------------			
cmp_ah_right:
			CMP Ah,4dh
            jz  cmp_al_right 
            jmp NO_INPUT         			;right
cmp_al_right:
            cmp al,36h 			
		    JnZ  ADD_coordinate_xy_16		
            jmp NO_INPUT
;-------------------------------------------------		
            
ADD_coordinate_xy:
			;CALL locate_write_FX_FY
			dec W_H
			cmp W_H,04H
            JNC NO_INPUT_ADDC
			MOV W_H,4 
			
			jmp  COLOUR
NO_INPUT_ADDC:  
            SUB coordinate_xy,10h
            
            jmp  COLOUR			
			
DEC_coordinate_xy:			
			 
			;call locate_write_FX_FY
			inc W_H
            cmp W_H,14H 
            JC NO_INPUT_DEEC
            MOV W_H,13H  			
			jmp  COLOUR
NO_INPUT_DEEC: 
            ADD coordinate_xy,10h
            
            JMP COLOUR			
dec_coordinate_xy_16:
            
			;call locate_write_FX_FY
            SUB W_L,3 
            cmp W_L,3 
            JNC  NO_INPUT_ADD16
            MOV  W_L,4			
			jmp COLOUR
NO_INPUT_ADD16:
            DEC coordinate_xy
            
            JMP COLOUR			
ADD_coordinate_xy_16:
             
			;call locate_write_FX_FY
            
            ADD W_L,3	
            CMP W_L,50
            JC	NO_INPUT_DEEC16
            MOV W_L,31H			
            jmp COLOUR
NO_INPUT_DEEC16:
            INC coordinate_xy
           
            jmp COLOUR			



 


;**********入口参数：无***************
;*****出口参数：es_seg：bx_seg    
;************** addr_seg：addr_off_seg
;注意事项：按下TAB键将重新输入，按下ESC退出程序
;*************************************
	get_key_MEMERY proc FAR  ;按键输入子程序
			push cx
			push ax
			push dx
			push bx
			push di
			PUSH SI 
			MOV SI,3
			mov di,3
			mov cx,4
			
		    call  clear_front_address
			call recover
	get_key1M:
    
           mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		   
           cmp al,08h 
		   jz back1
		   jmp bb1
back1:     
           cmp cx,4 
		   jz  get_key1M
		   jc  clear_char1 
		   jmp get_key1M
clear_char1: 
           inc di 
           call clear_one_charact  
           inc cx 
		   
	bb1:
           cmp al,27     ;esc  
           jz  first_screen
             		 
			
			CMP AL,9
			JZ  LOCATE_MEMORY_START_POINT
			cmp al,'f'                         
			Ja get_key1M        ; a <ASCII <f   
			cmp al,'a'         
			jNB  turn_capM1 
			jmp  FFM1
turn_capM1:   sub  al,32
		   jmp 	continue1M 
        
		FFM1:
			cmp al,'F'
			Ja  get_key1M      ;A<ASCII<F
			cmp  al,'A'
			jnb continue1M 
        
			cmp al,'9'
			Ja get_key1M
			cmp al,'0'         ;0<=ASCII<=F
			jNB  continue1M 
			jmp get_key1M 		
		continue1M :
			mov bl,aL          
			
			mov ah,2          ;
			mov dl,bl
			int  21h
			call hex
			mov addr_seg[di],al 
			
		
			
            DEc di 
			dec cx 
			cmp cx,0
			jnz  get_key1M 
			
			
			
			
			mov cx,4 	
			mov ah,2
			mov dl,3AH   ; ':'
			int 21h        
			mov di,0 
			
             
			  MOV Al,addr_seg[3]
			  shl al,4 
			  
			  add Al,addr_seg[2]
			  mov ah,al 
			 
			  
			  mov al,addr_seg[1]
			  shl al,4
			  
			  add al,addr_seg[0]
               
              mov es_seg,AX			  
   			
get_key2M:
	       mov ah,0
           int 16h        ;
		   cmp al,08h 
		   jz back2
		   jmp bb2
back2:     
           cmp cx,4 
		   jz  get_key2M
		   jc  clear_char 
		   jmp get_key2M
	clear_char: 
	       inc si 
           call clear_one_charact     

          inc cx 
          jmp  get_key2M
		
	bb2:
           cmp al,27     ;esc  
           jz  first_screen
			
			CMP AL,9
			JZ  LOCATE_MEMORY_START_POINT
			cmp al,'f'                     
			Ja get_key2M      
			cmp al,'a'     
		    jNB  turn_capM2 
			jmp  FFM2
turn_capM2:   sub  al,32
		   jmp 	continue2M 

            			    ; a <=ASCII <=f
FFM2:				        
			jNB continue2M 
            cmp al,'F'
			Ja  get_key2M      ;A<=ASCII<=F  
			cmp  al,'A'
			jnb continue2M
        
			cmp al,'9'
			Ja get_key2M        
			cmp al,'0'       ;0<=ASCII<=F  
			jNB  continue2M
			jmp get_key2M 		
		continue2M:
			mov bl,aL
			mov ah,2
			mov dl,bl
			int  21h
            call hex
			mov addr_off_seg[Si],al 
			inc di 
			
			
            DEc Si 			
			dec  cx 
			cmp  cx,0
			jnz  get_key2M 
		   
		   
		    MOV Al,addr_off_seg[3]        
		    shl al,4                    ;get addr_off_seg
			  
	        add Al,addr_off_seg[2]
			mov ah,al 
			 
			  
		    mov al,addr_off_seg[1]
		    shl al,4
			  
		    add al,addr_off_seg[0]
               
            mov BX_seg,AX	
            		
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
	 get_key_MEMERY endp
	 
	   	
		
    	
;********************内存数据显示*****************************	
;说明：以16行16列的方式显示256个内存地址数据
;*************************************************************
;入口参数：es_seg:附加段段地址，bx_seg 偏移地址 si：指向当前数据
; D_H,D_L 数据显示行列位置控制，初始值为4    
; D_H_CHANGE    每显示16个数据换一行，用来控制行的位置变化
;cont1,用于计当前已读数据个数，每到16个清零，并使D_H_CHANGE 加一
;************************************************************* 
         
;**************************************
;restore memory_data  
;output:memory_data[256]
 
    		load_memeory_data proc far 
		    pusha
		    mov ax,es_seg
		    mov es,ax
            mov bx,bx_seg
            mov di,0 
			
            mov si,0 
            mov cx,256 
load_memeory_data_again:		 
		    
			mov al,es:[bx+si]
		    mov memory_data[di],al 
			inc si 
			inc di 
			loop load_memeory_data_again
    		popa 
            ret 
		   load_memeory_data endp
;******************************************
;read  memory_data display by hex       
		   data_memory proc  far 
	      
	 STAR_MEMERY:
        	pusha
	        mov cx,16          ;循环256次
			mov si,0 
			mov D_H,4
			MOV D_L,4
			mov D_H_CHANGE,4     ;数据显示定位到初始位置
			CALL locate_DH_DY
xunhuan_MEMERY:  
            push cx                  
		    mov cx,16            ;每次显示16个数
again_MEMORY:  
             
            mov al,memory_data[si]    ;将内存地址赋值给al	
		  
		    push ax 
			mov ax,si 
		    mov off_set_num,al  
			pop ax 
     
		 
            call   asstohex      ;将al的值转化为ASCII码 显示16组数据 
            call   space
			inc   si             ;指向下一个地址
            inc cont1            ;换行控制   每显示玩一次数据加一，读满16个数换一行		   
		    loop again_MEMORY    ;接着返回读下一个数据
		    pop CX 	
			
		    cmp cont1,16
			
			 jz  DINGWEI_MEMERY         ;换行计数标志到16则换行定位程序，否则退出子程序
			
			
			 jmp tuichu_MEMERY
    DINGWEI_MEMERY:
             mov cont1,0
	         INC D_H_CHANGE            ;行变化计数加一
			 MOV AL,D_H_CHANGE         ;将变化量传给D_H 
			 MOV D_H,AL
		     CALL locate_DH_DY         ;定位
     
  	tuichu_MEMERY:
			dec cx               ;计数标志减1
            cmp cx,0            ;如果循环计数标志不为零，则继续循环否则程序停止
            jnz  xunhuan_MEMERY
           popa 			
			RET  
			
			
		data_memory endp

		
;**********************************************************
;     display_memery   by asscc form 
;     input:memory_data 
;----------------------------------------------------------		
		  data_memory_assc proc  far 
	      
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
            mov al,memory_data[si]    ;将内存地址赋值给al		   
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
			
			
		data_memory_assc endp	
		
		write_memory proc FAR  ;按键输入子程序
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
write_data:
           mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		     
		   cmp al,08h 
		   jz backw1
		   jmp bbw1
backw1:    	 
           cmp cx,2 
		   jz  write_data
		   jc  clear_char1 
		   jmp bbw1
clear_char1: 
           inc si 
           call display_del  
           inc cx 
		   
	bbw1:     
	        call recover
			cmp al,1Bh       ;ESC :  cacel write 
     		jz NO_INPUT_M
			cmp al,'f'     ;若果数值不小于f 则重新输入                
			ja write_data   ; a <ASCII <f   
			cmp al,'a'     ;若数值大于等于a

        	jnb  turn_cap_number 
			jmp  write_number_2
turn_cap_number:  
           sub  al,32
		   jmp display_no

            			    ; a <=ASCII <=f
write_number_2:			
		
			cmp al,'F'
			Ja  write_data      ;A<ASCII<F
			cmp  al,'A'
			jnb display_no
        
			cmp al,'9'
			Ja write_data
			cmp al,'0'
			jNB  display_no
			jmp write_data		
		display_no:
			mov bl,aL
			mov ah,2
			mov dl,bl
			int  21h
            call hex
			mov write_data_memory[Si],al 
		 
			
			
            dec  si 			
			dec  cx 
			cmp  cx,0
			jnz write_data 
		   
		   
		     mov al,write_data_memory[1]
		     shl al,4
			  
		     add al,write_data_memory[0]
               
             mov write_data_value,al 	
           ;-------------------------------         new line    		
           
no_enter:		   
		   call hide 
		   mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		   cmp al,1Bh       ;ESC :  cacel write 
     	   jz NO_INPUT_M
		   
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
	 write_memory endp
		
		
		
		
		

END 