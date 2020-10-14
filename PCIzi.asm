;*******************************************
;*******************************************
;功能实现对指定内存地址值得显示
;使用说明
;程序运行的任意时刻 ESC按下退出程序   按下TAB键改写入口地址

;*******************************************
;******************************************
.model MEDIUM
.486
extrn hide:far,recover:far, hex:far,locate_DH_DY:far,locate_X_Y:far,clear_screen:far,;公共部分，直接引用
      H:byte,L:BYTE,D_H:BYTE,D_L:BYTE,row:byte,cont1:word,D_H_CHANGE:byte,H_CHANGE:BYTE,
	  COW:BYTE,port_cont:byte,es_seg:word,bx_seg:WORD,;jicun_cont:byte,h_cont:byte,
	  hang_lie_display:far,asstohex:far,first_screen_h:byte,first_screen:far,space:far

public data_PCI,get_key_PCI,jicun_cont,h_cont,dispaly_PCI 
.data 

   ;cont dw 0
   ; cont_4 db 4 
   h_cont db 0 ;
   jicun_cont db 0 
  
   bus dB 2 DUP(?)
      
   bus_addr     db  0
   dev DB  2 DUP(?)
   dev_addr db 0 
   func db  2 DUP(?) 
   func_addr  db 0 
   PCI_addr   dd  0    ;保留按键输入的PCI 初始地址
   du_pci     dd  0    ;PCI 数据的入口地址
  
   
   mesg_dev db ' dev:','$'
   mesg_func db ' func:','$'
   MESG_PCI DB 'PCI bus:','$' 
   MESG_RETURN DB 'Quit: Q       rewrite: TAB ','$'
 .code
  dispaly_PCI:
  
  
     
     INCLUDE MACRO_zifu.mac
      LOCATE_PCI_START:
			 call clear_screen
			LOCATE_PCI :
			 mov D_H, 1
			 MOV D_L, 2 
			 call  locate_DH_DY
			PUSH BX
			PUSH DX
			PUSH AX 		
			mov BH,0 
			MOV DH,23    ;放入行号
			MOV DL,1     ;放入列号
			mov AH,02h	  
			INT 10H;
			
			
			msg  MESG_RETURN

	  mov BH,0 
			MOV DH,1    ;放入行号
			MOV DL,3     ;放入列号
			mov AH,02h	  
			INT 10H;
			POP AX
			POP DX 
			POP BX  
			 
			 msg  MESG_PCI	
			 call get_key_PCI		   
			 CALL hide 
				 
				  
		 NO_INPUT_PCI:      
				call data_PCI 
				CALL hang_lie_display
				
				MOV AH,11H    
				INT 16H      ;检测按键是有否按下，有则判断按键是否是ESC,否则继续刷新
				jz NO_INPUT_PCI
				CMP AL,'Q'     ;若为Q 键则退到主界面
				JZ  first_screen
				CMP AL,'q'     ;若为q 键则退到主界面
				JZ  first_screen
		
		;**********************************************
				mov ah,8
				int 21h            ;读键盘输入一个字符，不回显
				cmp al,9           ;若为tab则重新输入地址
				JZ   LOCATE_PCI 
				JMP NO_INPUT_PCI  
			
;**************PCI数据显示**************
;   入口参数：jicun_cont,D_H,D_L,D_H_CHANGE
;             bus_addr，func_addr,h_cont
;*******************************************		
			
            data_PCI proc
	      
	 STARPCI:  pusha
	       
		    mov cx,64         ;循环64次
			mov jicun_cont,0 
			 
			mov D_H,4
			MOV D_L,4
			mov D_H_CHANGE,4 
			
			CALL locate_DH_DY
xunhuanPCI:    
             
         	 xor eax, eax
	         or	al, bus_addr
	         shl	eax, 5
	         or al, dev_addr
	         shl	eax, 3
	         or	al,func_addr
	         shl	eax, 6
	        or	al, jicun_cont
	        shl	eax, 2
	        or	eax, 80000000h       ;求地址
	         
			
			 MOV DX,0CF8H
	         
			 OUT  dx,eax          ;确定首地址
			 mov dx,0cfch
			 in eax,dx 
            push cx 
			;push eax 
			mov cx ,4
    againPCI:      
    		call   asstohex      ;显示一次AL值
			call space
			shr eax,8
			loop againPCI
						
			pop cx 
			inc jicun_cont
			inc h_cont
			cmp h_cont,4 
			jnz sss
		DINGWEIPCI:
            mov h_cont,0
			
	        INC D_H_CHANGE
			MOV AL,D_H_CHANGE
			MOV D_H,AL
		    CALL locate_DH_DY 
          sss:      
		    loop xunhuanPCI
           popa 			
			RET  
			
			
		data_PCI endp	
		
		
			
			
	
	  

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
	get_key_PCI1:
           call recover
			mov ah,8
			int 21h   
           
   		   CMP AL,'Q'     ;若为Q键则退出
		    JZ  first_screen
		    CMP AL,'q'     ;若为键则退出
		    JZ  first_screen
             		   ;读键盘输入一个字符，不回显
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
			mov cx,4 	
			mov ah,2
			mov dl,3AH
			int 21h        ;显示冒号

			  
			  mov al,bus[1]
			  shl al,4
			  
			  add al,bus[0]
               
              mov bus_addr,Al	
              msg mesg_dev
              MOV DI,1  
              mov cx,2 			  
   			
	get_key_PCI2:
	        
			mov ah,8
			int 21h        ;读键盘输入一个字符，不回显
			 CMP AL,'Q'     ;若为Q键则退出
		    JZ  first_screen
		    CMP AL,'q'     ;若为键则退出
		    JZ  first_screen
			CMP AL,9
			JZ  LOCATE_PCI
			CMP AL,9
			JZ  LOCATE_PCI
			cmp al,'f'     ;若果数值不小于f 则重新输入                
			Ja get_key_PCI2    ;    
			cmp al,'a'     ;若数值大于等于a,重新输入
			               ; a <=ASCII <=f
						   ;调到next22 ，转化为相应ASSCII
			jNB  turn_capPCI2 
			jmp  FFPCI2
turn_capPCI2:   sub  al,32
		   jmp 	nextPCI22 
        
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
			;inc di 
			
			
            DEc Di 			
			dec  cx 
			cmp  cx,0
			jnz  get_key_PCI2 
		   
		   
		    ; MOV Al,addr_off_seg[3]        
		    ; shl al,4                       ;合并所得到的数据
			  
	        ; add Al,addr_off_seg[2]
			; mov ah,al 
			 
			  
		    mov al,dev[1]
		    shl al,4
			  
		    add al,dev[0]
               
            mov dev_addr,Al	
			  
			  MOV DI,1  
              mov cx,2 			  
   			msg mesg_func
	get_key_PCI3:
	        
			mov ah,8
			int 21h        ;读键盘输入一个字符，不回显
			 CMP AL,'Q'     ;若为Q键则退出
		    JZ  first_screen
		    CMP AL,'q'     ;若为键则退出
		    JZ  first_screen
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
	 
   
  end
			
