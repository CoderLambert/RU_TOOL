;*******************************************
;******************************************

.model medium
.586
public D_H,D_L,H,L,H_CHANGE,COW,row,D_H_CHANGE,port_cont,es_seg,bx_seg,off_set_num,
       first_screen_h,first_screen,QUIT,coordinate_xy,start_cow,start_row,
       cont_4,back_ground_color,font_colour,number,cont1,row_number,cow_number
	   
 extrn hide:far,recover:far, hex:far,clear_screen:far,menu_locate:far, 
       display_memery:far,display_IO:far,display_ISA:far,display_PCI:far,
	   display_BEEP:far,display_KEY:far,display_a20:far,display_E820:far,
	   dispaly_8259a:far,display_CPUID:far,display_Shandow:far,display_CMOS:far,
       display_OPTION:FAR,display_SIO:far,display_SMBUS:FAR,display_BDA:FAR       	   
     .data 
	    off_set_num db 0
	    number   db 0 
		start_cow db 0
		start_row db 0
		
		coordinate_xy  db 0 
        back_cussor_x db 0
        back_cussor_y db 0
        back_cussor_dx db 0 
        back_cussor_dy	db 0 	
	    font_colour  db 0 
	    back_ground_color  db 0 
		cow_number  db 0 
		row_number  db 0
		high_colour db 1
        H db 0    ;
        L DB 0     ;
		
		cont1   dw 0
        H_CHANGE  DB 4  ;
        port_cont db 0 
        row db 0    ;
        COW DB 0  ; 
        D_H db 1    ;
        D_L DB 2     ;
		es_seg  dw 0 
        bx_seg  dw 0
              
        cont_4 db 4 
        D_H_CHANGE  DB 4 ;
	
       
  first_screen_h  db 0
  MESG_1   DB 'Please chose your function:','$'
  MESG_2   DB '1.MEMORY ','$'
  MESG_3   DB '2.IO ','$'
  MESG_4   DB '3.ISA ','$'
  MESG_5   DB '4.PCI', '$'
  MESG_6   DB '5.BEEP','$'
  MESG_7   DB '6.KEY ','$' 
  MESG_8   DB '7.A20 address','$'
  MESG_9   DB '8.E820 ','$'
  MESG_A   DB '9.8259A','$'
  MESG_B   DB 'A.CPUID','$'
  MESG_C   DB 'B.Shadow RAM','$'
  MESG_D   DB 'C.CMOS','$'
  MESG_E   DB 'D.OPTION ROM','$'
  MESG_F   DB 'E.Super IO','$'
  MESG_G   DB 'F.SMBUS','$'
  MESG_H   DB 'G.BDA ','$'
  MESG_NOTICE  DB 'QUIT : Esc ','$'
  MESG_OPTION  DB 'F1: Contact Information','$'
  author    db 'Programer:   Lambert Lee','$' 
  contact_informaition   db'Email: LambertLee @ami.com','$'    
  MESG_F1   db 'Select menus: Up Down Left Right  -- Enter  ','$'
     
       
 
  
   
  
  
 
.code
.startup 
         include  MACRO_zifu.MAC
;----------------------------------   set display model 
         mov al,03h
         mov ah,0 
         int 10h 		 
   		  
first_screen: 
        
        call hide 
        mov back_ground_color,2Fh		
        call clear_screen
       	   
menu:   
        mov ax,@data 
        mov ds,ax                 
        mov first_screen_h,0 
    ;-----------------------------------
        mov row_number,1
		mov cow_number,1
        call menu_locate
	
	    msg MESG_1
    ;-----------------------------------		
        mov row_number,3
		mov cow_number,8
		cmp high_colour,1
		jnz s1 
		mov back_cussor_x,6   ;cow_number-2 
		mov back_cussor_y,4   ;row_number+1
        call  high_light_background
    s1:		
        call menu_locate
		msg  MESG_2
	;-----------------------------------	
       
		mov row_number,5
		mov cow_number,8
		cmp high_colour,2
		jnz s2 
		mov back_cussor_x,6 
		mov back_cussor_y,6
        call  high_light_background
    s2:		
        call menu_locate
		;call menu_locate
		msg MESG_3	
	;-----------------------------------	
       mov row_number,7
       mov cow_number,8
	   cmp high_colour,3
       jnz s3 
       mov back_cussor_x,6 
       mov back_cussor_y,8
       call  high_light_background
    s3:		
        call menu_locate
       
       msg MESG_4
    ;-----------------------------------
       mov row_number,9
       mov cow_number,8
	   cmp high_colour,4
       jnz s4 
       mov back_cussor_x,6 
       mov back_cussor_y,10
       call  high_light_background
    s4:		
       call menu_locate
	   msg MESG_5	
;-----------------------------------
       mov row_number,11
       mov cow_number,8
	   cmp high_colour,5
       jnz s5 
       mov back_cussor_x,6 
       mov back_cussor_y,12
       call  high_light_background
    s5:		
       call menu_locate
       msg MESG_6	
 ;-----------------------------------
       mov row_number,13
       mov cow_number,8
	   cmp high_colour,6
	   jnz s6 
	    mov back_cussor_x,6 
		mov back_cussor_y,14
        call  high_light_background
    s6:	
        call menu_locate
       ;call menu_locate
       msg MESG_7	 
;-----------------------------------	
       mov row_number,15 
       mov cow_number,8
	   cmp high_colour,7
       jnz s7 
       mov back_cussor_x,6 
       mov back_cussor_y,16
       call  high_light_background
    s7:	
       call menu_locate
       msg MESG_8	
;-----------------------------------
      
       mov row_number,3
       mov cow_number,36
	   cmp high_colour,8
       jnz s8 
       mov back_cussor_x,34 
       mov back_cussor_y,4
       call  high_light_background
    s8:	
       call menu_locate
       msg MESG_9
;-----------------------------------
       mov row_number,5
       mov cow_number,36
	   cmp high_colour,9
       jnz s9 
       mov back_cussor_x,34 
       mov back_cussor_y,6
       call  high_light_background
    s9:	
       call menu_locate
       msg MESG_A
;-----------------------------------
       mov row_number,7
       mov cow_number,36
	   cmp high_colour,10
       jnz s10 
       mov back_cussor_x,34 
       mov back_cussor_y,8
       call  high_light_background
    s10:	
       call menu_locate
       msg MESG_B
;-----------------------------------
       mov row_number,9
       mov cow_number,36
	   cmp high_colour,11
       jnz s11 
       mov back_cussor_x,34 
       mov back_cussor_y,10
       call  high_light_background
    s11:	
       call menu_locate
       msg MESG_C	   
;-----------------------------------
       mov row_number,11
       mov cow_number,36
	   cmp high_colour,12
       jnz s12 
       mov back_cussor_x,34 
       mov back_cussor_y,12
       call  high_light_background
    s12:	
       call menu_locate
       msg MESG_D	
;-----------------------------------
       mov row_number,13
       mov cow_number,36
	   cmp high_colour,13
       jnz s13 
       mov back_cussor_x,34 
       mov back_cussor_y,14
       call  high_light_background
    s13:	
       call menu_locate
       msg MESG_E		   
;-----------------------------------

       mov row_number,15
       mov cow_number,36
	   cmp high_colour,14
       jnz s14 
       mov back_cussor_x,34 
       mov back_cussor_y,16
       call  high_light_background
    s14:	
       call menu_locate
       msg MESG_F		   
;-----------------------------------
       mov row_number,3
       mov cow_number,60
	   cmp high_colour,15
       jnz s15 
       mov back_cussor_x,58
       mov back_cussor_y,4
       call  high_light_background
    s15:	
       call menu_locate
       msg MESG_G
;-----------------------------------
       mov row_number,5
       mov cow_number,60
	   cmp high_colour,16
       jnz s16 
       mov back_cussor_x,58
       mov back_cussor_y,6
       call  high_light_background
    s16:	
       call menu_locate
       msg MESG_H       

       mov row_number,22
       mov cow_number,30
	  
       call menu_locate
		
       msg MESG_NOTICE	   
;-----------------------------------
       mov row_number,22
       mov cow_number,4
	  
       call menu_locate
		
       msg MESG_OPTION
       
       
       
 
cheack_gain:
	
       
	;**********************************************
            mov ah,0
			int 16h                        ;enter
			cmp al,27                      ;quit:esc 
            jz  QUIT
			cmp ah,1ch 
			jz  enter_proc
			cmp ah,3bh   
			jz   help_text                 ;F1:HELP 
			cmp ah,50h                     ;up       
	        jz ADD_high_colour 
			cmp ah,48h                     ;down
			jz DEC_high_colour
            cmp ah,4bh                     ;left
			jz  dec_high_colour_cow
			CMP Ah,4dh                     ;right
		    JZ  ADD_high_colour_cow        
            cmp al,'1'                       
            jz display_memery 
            cmp al,'2'
            jz display_IO
            cmp al,'3'
            jz display_ISA
            cmp al,'4'
            jz display_PCI
            cmp al,'5'
            jz display_BEEP
            cmp al,'6'
            jz display_KEY 
            cmp al,'7'
            jz display_a20
			
            cmp al,'8'
            jz display_E820
			
            cmp al,'9'
            jz   dispaly_8259a
		    cmp al,'a'
		    jz   display_CPUID 
		    cmp al,'A'
		    jz   display_CPUID
			cmp al,'b'
			jz   display_Shandow
			cmp al,'B'
			jz   display_Shandow
			
			cmp al,'C'
			jz   display_CMOS
			cmp al,'c'
			jz   display_CMOS 
			cmp al,'D'
			jz   display_OPTION
			cmp al,'d'
			jz   display_OPTION
			cmp al,'E'
			jz   display_SIO
			cmp al,'e'
			jz   display_SIO
			cmp al,'F'
			jz   display_SMBUS
			cmp al,'f'
			jz   display_SMBUS
            cmp al,'G'
			jz   display_BDA
			cmp al,'g'
			jz   display_BDA
			
			
			
 			;继续添加子函数
			
            jmp cheack_gain
		
	enter_proc:
            cmp high_colour,1 
			jz display_memery
			
            cmp high_colour,2
            jz display_IO

			cmp high_colour,3 
			jz display_ISA 
			
			cmp high_colour,4 
			jz display_PCI
			;add 
			cmp high_colour,5 
			jz display_BEEP	

            cmp high_colour,6
            jz display_KEY	

            cmp high_colour,7 
            jz  display_a20	

            cmp high_colour,8 
            jz display_E820
            cmp high_colour,9
            jz  dispaly_8259a
            cmp high_colour,10
            jz  display_CPUID
            cmp high_colour,11 
            jz  display_Shandow	

            cmp high_colour,12 
            jz  display_CMOS

            cmp high_colour,13 
            jz  display_OPTION	

            cmp high_colour,14 
            jz  display_SIO
            
            cmp high_colour,15 
            jz  display_SMBUS
    
            cmp high_colour,16 
            jz  display_BDA     
			jmp  cheack_gain	
	;----------------------------	
DEC_high_colour:
        
        dec high_colour
		
        cmp high_colour,0  
        jz  set_max
       		
        jmp first_screen 		
set_max: 
         
        mov high_colour,16    
		
        jmp first_screen 
 ;-----------------------------------
 
 ;-----------------------------------
ADD_high_colour: 
        inc high_colour 
        cmp high_colour,17 
		jz  set_min
	    jmp first_screen
set_min: 
        mov high_colour,1   
		jmp first_screen 		
 ;-----------------------------------

dec_high_colour_cow:
        cmp high_colour,8
		jc  cheack_gain
        sub high_colour,7 
        jmp first_screen	
;------------------------------------
add_high_colour_cow:
        cmp high_colour,10
		jnc  cheack_gain
        add high_colour,7 
        jmp first_screen			
;**********end*********************************
help_text:

 
          
		 mov back_cussor_x,3       ;left x  
		 mov back_cussor_y,19
		 mov back_cussor_dx,30     ;lie  end
		 mov back_cussor_dy,18       
		 mov back_ground_color,75h
		 call high_light 
		 mov cow_number,5       ;列
		 mov row_number,3      ;行 
		 call menu_locate
		 msg author
         mov cow_number,5       ;列
		 mov row_number,4      ;行 
		 call menu_locate
         msg contact_informaition
		jmp cheack_gain 
QUIT: 
        	.exit



;*****HIGH_LIGHT BACKOUND **************
 high_light_background  proc far
; protec registers
   push ax
   push bx 
   push cx 
   push dx
   mov ah,6 
   mov al,0 
   mov bh,3eH   ;BACK    FRONT 
  
   push bx
   push ax 
   mov al,back_cussor_x     
	 
   ;sub al,1              ;左列AL 
   mov ah,back_cussor_x
   add ah,17             ;右列AH 
   mov bl,back_cussor_y     ;下行BL 
   sub bl,2               
   mov bh,back_cussor_y   ;上行BH
    
  mov ch,BL     ;COW 
  mov cl,AL  
  mov dh,BH     ;ROW
  mov dl,AH
  POP AX 
  POP BX 
  int 10h
  ;restore registers
  pop dx 
  pop cx 
  pop bx 
  pop ax 
  ret 
  high_light_background endp
;***********************
;
	 high_light  proc far
;---------------------------
;    input:  back_cussor_dx   back_cussor_dy   back_cussor_x  back_cussor_y  
;            back_ground_color  	 
	 
; protec registers
   push ax
   push bx 
   push cx 
   push dx
   mov ah,6 
   mov al,0 
   mov bh,back_ground_color   ;BACK    FRONT 
  
   push bx
   push ax 
   mov al,back_cussor_x
	 
   ;sub al,1                   ;左列AL 
   mov ah,back_cussor_x
   add ah,back_cussor_dx       ;右列AH 
     
   mov bl,back_cussor_y        ;下行BL 
   sub bl,back_cussor_dy       ;确定范围                        
   mov bh,back_cussor_y        ;上行BH
    
  mov ch,BL                    ;COW 
  mov cl,AL  
  mov dh,BH                    ;ROW
  mov dl,AH
  POP AX 
  POP BX 
  int 10h
  ;restore registers
  pop dx 
  pop cx 
  pop bx 
  pop ax 
  ret 
  high_light endp		
 
  end
			
