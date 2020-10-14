;*******************************************
;*******************************************
;FUC:read or write pci data 
;*******************************************
;******************************************
.model MEDIUM
.486
extrn hide:far,recover:far, hex:far,locate_DH_DY:far,locate_X_Y:far,clear_screen:far,
      H:byte,L:BYTE,D_H:BYTE,D_L:BYTE,row:byte,cont1:word,D_H_CHANGE:byte,H_CHANGE:BYTE,
      COW:BYTE,port_cont:byte,es_seg:word,bx_seg:WORD,display_coordinate_xy:far,asscii:far  
      
extrn hang_lie_display:far,asstohex:far,first_screen_h:byte,first_screen:far,space:far,clear_front_address:far,
      display_eax:far,back_ground_color:byte,W_H:byte,W_L:byte,coordinate_xy:byte,off_set_num:byte,locate_write_X_Y:far,
      display_del:far,clear_one_charact:far    
public data_PCI,get_key_PCI,jicun_cont,h_cont,display_PCI 
.data 

   
   h_cont db 0 ;
   jicun_cont db 0 
  
   bus dB 2 DUP(?)
   consult     db 0 
   remainder   db 0 
   bus_addr     db  0
   dev DB  2 DUP(?)
   dev_addr db 0 
   func db  2 DUP(?) 
   func_addr  db 0 
   PCI_addr   dd  0    
   du_pci     dd  0    
   pci_data   db  256 dup(?) 
   number_4   db  4 
   write_temp dd  0ffffff00h
   write_temp_value    dd 0 
   write_data_PCI  db 2 dup(?)
   write_data_value_PCI  db 0
   base_address dd 0 
   mesg_dev db ' dev:','$'
   mesg_func db ' func:','$'
   MESG_PCI DB 'PCI bus:','$' 
   MESG_BASE_ADDRESS_REGISTER   db '     Address :  ','$'
   MESG_RETURN DB 'Return menu: ESC       Rewrite: Tab and Backspace ','$'
   
 .code
   INCLUDE MACRO_zifu.mac
;-----------------------------------         
display_PCI:
  
        mov coordinate_xy,0
        mov W_H,4
        mov W_L,4
     
LOCATE_PCI_START:
        mov back_ground_color,29h 
        call clear_screen
LOCATE_PCI :
        mov D_H, 1
        MOV D_L, 2 
        call  locate_DH_DY
        push bx
        push dx
        push ax 
        mov bh,0 
        mov dh,23    ;set start  position 
        mov dl,1     
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
  
        msg  MESG_PCI 
        call get_key_PCI 
        call hide 
                  
COLOUR_PCI: 
        call hang_lie_display	
        call display_coordinate_xy	

        
NO_INPUT_PCI:      
        call hide 
NO_INPUT_PC:      
        call  load_pci_data     
        call data_PCI
        call data_PCI_assc                


        mov ah,11h    
        int 16h      
        jz NO_INPUT_PC
        
        mov ah,0
        int 16h
            
        cmp al,0dh 
        jz enter_write_PCI
        jmp cmp_table_PCI

enter_write_PCI:	
    		
        pusha 
            
        call write_PCI
           
           
        call hide
        push ax 
        xor eax,eax 
           
        mov ax,word ptr coordinate_xy
        and ax,00ffh 
         
          
        div number_4
           
        mov remainder,ah      ;off_set_num
        mov consult,al        ;jicun_cont   
        mov jicun_cont,al
        pop ax            
           
           
           
        xor eax, eax
        or  al, bus_addr
        shl eax, 5
        or  al, dev_addr
        shl eax, 3
        or  al,func_addr
        shl eax, 6
        or  al, jicun_cont
        shl eax, 2
        or  eax, 80000000h       ;求地址
           
        mov dx,0cf8h
         
        out  dx,eax            
        mov dx,0cfch
        in eax,dx 
          
; ;---------------------------------------------          
        push cx      
        xor cx,cx 
        mov cl,remainder
        mov ebx,dword ptr write_data_value_PCI
        mov write_temp_value,ebx
        and write_temp_value,000000ffh 
          
loop_shl:     
          
        shl write_temp,8
        or write_temp,0ffh 
        shl write_temp_value,8 
        loop  loop_shl 
        pop cx 
          
        and eax,write_temp
        or  eax,write_temp_value
          
        mov write_temp_value,eax
          

        push ax 
        xor eax,eax 
           
        mov ax,word ptr coordinate_xy
        and ax,00ffh 
         
          
        div number_4
           
        mov remainder,ah      ;off_set_num
        mov consult,al        ;jicun_cont   
        mov jicun_cont,al
        pop ax 
            
        xor eax, eax
        or  al, bus_addr
        shl eax, 5
        or  al, dev_addr
        shl eax, 3
        or  al,func_addr
        shl eax, 6
        or  al, jicun_cont
        shl eax, 2
        or  eax, 80000000h       
          
        mov dx,0cf8h
        out  dx,eax   
          
        mov dx,0cfch
        mov eax,write_temp_value
         
        out dx,eax  
       
        popa 
        jmp  NO_INPUT_PCI        ;
                                   ;


;**********************************************
cmp_table_PCI:			
        cmp al,9           ;若为tab则重新输入地址
        jz   LOCATE_PCI 
                
        cmp ah,01h     ;QUIIT:ESC
        jz  first_screen

        cmp ah,48h                     ;up
        jz  cmp_al_up_PCI
        jmp  cmp_ah_down_PCI 			
cmp_al_up_PCI:   
        cmp al,38h 
               			
        jnz ADD_coordinate_xy_PCI 

;-------------------------------		
cmp_ah_down_PCI:	
        cmp ah,50h 
        jz cmp_al_down_PCI
        jmp cmp_ah_left_PCI			
cmp_al_down_PCI: 
        cmp al,32h 			
                                 			;down
        jnz DEC_coordinate_xy_PCI
;---------------------------------			
cmp_ah_left_PCI:			
        cmp ah,4bh                     ;left
        jz cmp_al_left_PCI 
        jmp cmp_ah_right_PCI 
cmp_al_left_PCI:  
        cmp al,34h 
        jnz  dec_coordinate_xy_16_PCI
       
			
			
;----------------------------------			
cmp_ah_right_PCI:
       cmp ah,4dh
       jz  cmp_al_right_PCI 
       jmp NO_INPUT_PC         			;right
cmp_al_right_PCI:
       cmp al,36h 			
       jnz  ADD_coordinate_xy_16_PCI		
       jmp NO_INPUT_PC
;-------------------------------------------------		
            
ADD_coordinate_xy_PCI:

       dec W_H
       cmp W_H,04H
       jnc NO_INPUT_ADDC_PCI
       mov W_H,4 

       jmp  COLOUR_PCI
NO_INPUT_ADDC_PCI:  
            SUB coordinate_xy,10h
            
            jmp  COLOUR_PCI			
			
DEC_coordinate_xy_PCI:			
			 

       inc W_H
       cmp W_H,14H 
       jc NO_INPUT_DEEC_PCI
       mov W_H,13H  			
       jmp  COLOUR_PCI
NO_INPUT_DEEC_PCI: 
       add coordinate_xy,10h
            
       jmp COLOUR_PCI			
dec_coordinate_xy_16_PCI:
            

       sub W_L,3 
       cmp W_L,3 
       jnc  NO_INPUT_ADD16_PCI
       mov  W_L,4			
       jmp COLOUR_PCI
NO_INPUT_ADD16_PCI:
       dec coordinate_xy
            
       jmp COLOUR_PCI			
ADD_coordinate_xy_16_PCI:
       add W_L,3	
       cmp W_L,50
       jc  NO_INPUT_DEEC16_PCI
       mov W_L,31H			
       jmp COLOUR_PCI
NO_INPUT_DEEC16_PCI:
       inc coordinate_xy
           
       jmp COLOUR_PCI	 

             
       jmp NO_INPUT_PCI  

        
       load_pci_data proc far 
        pusha

            mov di,0 
       mov jicun_cont,0  
;------------------------------- init             
            mov cx,64 
load_pci:                                  ;calact address            
       xor eax, eax
       or  al, bus_addr
       shl  eax, 5
       or al, dev_addr
       shl eax, 3
       or al,func_addr
       shl  eax, 6
       or   al, jicun_cont
       shl  eax, 2
       or   eax, 80000000h 


       mov dx,0CF8H
         
       out  dx,eax          ;确定首地址
       mov dx,0cfch
       in eax,dx 
         
      push cx    
      mov cx ,4
againPCI:    
      mov pci_data[di],al     
      inc di 
      shr eax,8
      loop againPCI
						
      pop cx 
    
			 
      inc jicun_cont 
      loop load_pci
      popa 
      ret 
      load_pci_data endp        
            
;**************PCI数据显示**************
;   input：jicun_cont,D_H,D_L,D_H_CHANGE
;             bus_addr，func_addr,h_cont
;*******************************************		

           data_PCI proc
	       pusha 
STARPCI:  
			mov si,0 
            mov di,0             
			mov D_H,4
			MOV D_L,4
			mov D_H_CHANGE,4 
		    CALL locate_DH_DY
            
            mov cx,256
xunhuanPCI:    
             
            mov al,pci_data[si]
            
            push ax 
			mov ax,si 
		    mov off_set_num,al  
			pop ax 
    		call   asstohex      ;显示一次AL值
			call    space 
            inc si 
			
		
			inc h_cont
			cmp h_cont,16 
			jnz next_data 
DINGWEIPCI:
            mov h_cont,0
			
	        INC D_H_CHANGE
			MOV AL,D_H_CHANGE
			MOV D_H,AL
		    CALL locate_DH_DY 
next_data:      
		   loop xunhuanPCI
           popa 			
		   RET  
			
			
		data_PCI endp	
		
		
		;-------------------------------


 data_PCI_assc proc  far 
	      
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
            mov al,pci_data[si]    ;将内存地址赋值给al		   
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
			
			
		data_PCI_assc endp		
			
	
	  

;**********按键输入子程序*************
;*****入口参数 cx ax dx 
;**********************************
	get_key_PCI proc   ;按键输入子程序
			push cx
			push ax
			push dx
			push bx
			push di
			PUSH SI 
			;MOV SI,3
			mov di,1 
			mov cx,2
            call clear_front_address
            call recover
	get_key_PCI1:
           
           mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		   
           cmp al,08h     ;backspace 
		   jz back1
		   jmp bb1
back1:     
           cmp cx,2 
		   jz  get_key_PCI1
		   jc  clear_char1 
		   jmp get_key_PCI1
clear_char1: 
           inc di 
           call clear_one_charact  
           inc cx 
		   
	bb1:
		   
		   
		   cmp al,27     ;quit:esc 
		   jz  first_screen
           
           
			CMP AL,9
			JZ  LOCATE_PCI
			cmp al,'f'         ;若果数值大于f 则重新输入                
			Ja get_key_PCI1        ; a <ASCII <f   
			cmp al,'a'         ;若数值大于等于a
			jNB  turn_capPCI1 
			jmp  FFPCI1
turn_capPCI1:   sub  al,32
		   jmp 	continuePCI1 
        
		FFPCI1:
		
			cmp al,'F'
			Ja  get_key_PCI1      ;A<ASCII<F
			cmp  al,'A'
			jnb continuePCI1 
        
			cmp al,'9'
			Ja get_key_PCI1
			cmp al,'0'         ;0<=ASCII<=F
			jNB  continuePCI1 
			jmp get_key_PCI1 		
		continuePCI1 :
			mov bl,aL         ;读键盘数据 
			
			mov ah,2          ;显示值
			mov dl,bl
			int  21h
			call hex
			mov bus[di],al 
			
		
			
            DEc di 
			dec cx 
			cmp  cx,0
			jnz  get_key_PCI1 
				
               
			mov al,bus[1]
			shl al,4
			  
			add al,bus[0]
               
            mov bus_addr,Al	
            msg mesg_dev
            MOV DI,1  
            mov cx,2 			  

get_key_PCI2:        
        mov ah,0
        int 16h        ;读键盘输入一个字符，不回显
        cmp al,08h 
        jz back2
        jmp bb2
back2:     
        cmp cx,2 
        jz  get_key_PCI2
        jc  clear_char 
        jmp get_key_PCI2
clear_char: 
        inc di 
        call clear_one_charact     

        inc cx 
        jmp  get_key_PCI2
        
bb2:
        cmp al,27     ;esc  
        jz  first_screen
      
        CMP AL,9
        JZ  LOCATE_PCI
        cmp al,'f'                    
        Ja get_key_PCI2        
        cmp al,'a'     
                           ; a <=ASCII <=f
   
        jNB  turn_capPCI2 
        jmp  FFPCI2
turn_capPCI2:  
        sub  al,32
        jmp  nextPCI22 
FFPCI2: 
        cmp al,'F'
        Ja  get_key_PCI2      ;A<=ASCII<=F  转next22
        cmp  al,'A'
        jnb nextPCI22
        
        cmp al,'9'
        Ja get_key_PCI2        
        cmp al,'0'       ;0<=ASCII<=F  转next22
        jNB  nextPCI22
        jmp get_key_PCI2 		
nextPCI22:
        mov bl,aL
        mov ah,2
        mov dl,bl
        int  21h
        call hex
        mov dev[Di],al 
 
			
        dec di 
        dec  cx 
        cmp  cx,0
        jnz  get_key_PCI2 
        
         
        mov al,dev[1]
        shl al,4
       
        add al,dev[0]
               
        mov dev_addr,al	
          
        mov di,1  
        mov cx,2 			  
        msg mesg_func
get_key_PCI3:
        
        mov ah,0
        int 16h        ;读键盘输入一个字符，不回显
        cmp al,08h 
        jz back3
        jmp bb3
back3:     
        cmp cx,2 
        jz  get_key_PCI3
        jc  clear_char4 
        jmp get_key_PCI3
clear_char4: 
        inc di 
        call clear_one_charact     

        inc cx 
        jmp  get_key_PCI3
        
bb3:
        cmp al,27     ;esc  
        jz  first_screen
			CMP AL,9
			JZ  LOCATE_PCI
			CMP AL,9
			JZ  LOCATE_PCI
			cmp al,'f'     ;若果数值不小于f 则重新输入                
			Ja get_key_PCI3   ;    
			cmp al,'a'     ;若数值大于等于a,重新输入
			               ; a <=ASCII <=f
						   ;调到next22 ，转化为相应ASSCII
			jNB  turn_capPCI3 
			jmp  FFPCI3
turn_capPCI3:   sub  al,32
		   jmp 	nextPCI33 
        
		FFPCI3:
            cmp al,'F'
			Ja  get_key_PCI3      ;A<=ASCII<=F  转next22
			cmp  al,'A'
			jnb nextPCI33 
        
			cmp al,'9'
			Ja get_key_PCI3        
			cmp al,'0'       ;0<=ASCII<=F  转next22
			jNB  nextPCI33 
			jmp get_key_PCI3 		
		nextPCI33:
			mov bl,aL
			mov ah,2
			mov dl,bl
			int  21h
            call hex
			mov func[Di],al 
			;inc di 
			
			
            DEc Di 			
			dec  cx 
			cmp  cx,0
			jnz  get_key_PCI3 
			 
			  
		    mov al,func[1]
		    shl al,4
			  
		    add al,func[0]
               
            mov func_addr,Al


          call space 
          call space 		  
			
          xor eax, eax
	      or  al, bus_addr
	      shl eax, 5
	      or  al, dev_addr
	      shl eax, 3
	      or  al,func_addr
	      shl eax, 6
	      or  al, jicun_cont
	      shl eax, 2
	      or  eax, 80000000h       ;求地址
	      
          mov base_address,eax
          msg MESG_BASE_ADDRESS_REGISTER          
          call display_eax		
          mov ah,2
          mov dl,10
          int 21h
			
			
			POP SI            
			pop di 
			POP BX
			pop dx
			pop ax
			pop cx
			ret 
	 get_key_PCI endp
	 
     
     
     write_PCI proc FAR  ;按键输入子程序
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
     		jz NO_INPUT_PC
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
			mov write_data_PCI[Si],al 
		 
			
			
            dec  si 			
			dec  cx 
			cmp  cx,0
			jnz write_data_I 
		   
		   
		     mov al,write_data_PCI[1]
		     shl al,4
			  
		     add al,write_data_PCI[0]
               
             mov write_data_value_PCI,al 	
           ;-------------------------------         new line    		
           
no_enter:		   
		   call hide 
		   mov ah,0
           int 16h        ;读键盘输入一个字符，不回显
		   cmp al,1Bh       ;ESC :  cacel write 
     	   jz NO_INPUT_PC
		   
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
	 write_PCI endp
     
   
  end
			
