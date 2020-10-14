.model small 
.586
PUBLIC display_CMOS
extrn space:far,clear_screen:far,assc:far,hide:far,start_point:far,asstohex_color:far, 
      start_cow:byte,start_row:byte,    
      back_ground_color:byte,first_screen_h:byte,first_screen:far 
.data 

         time db 13 dup(?)                   ;restore time
         Delimiters  db '/','$'
         Delimiters1 db ':','$'
         address_isa db 0 
         flag        dw 0 
         
         week_1      db 'Monday        ','$'
         week_2      db 'Tuseday        ','$'
         week_3      db 'Wednesday       ','$'
         week_4      db 'Thursday        ','$'
         week_5      db 'Friday         ','$'
         week_6      db 'Saturday        ','$'
         week_7      db 'Sunday          ','$'	
         MESG_RETURN DB 'Quit: Q  ','$'		 
		 
.code 
.startup 
display_CMOS:
        mov  back_ground_color,2bh
        call clear_screen
        include MACRO_zifu.MAC
         mov time[2],'/'
         mov time[4],'/'       
         mov time[6],' '
         mov time[8],':'
         mov time[10],':'
         call hide
         
         mov start_cow,2
         mov start_row,23 
         call start_point
		 msg MESG_RETURN
		 
		 
read_time:
        mov start_cow,3
		 mov start_row,3
        call start_point		
         mov time[0],20h
		 
		 
         MOV  al,time[0]
		
;year high 
        mov address_isa,09h 
        call read_isa	   
	    mov time[1],al 
       
;year low 		 
		 mov address_isa,08h 
		 call read_isa
		 mov time[3],al 
		
;month  		 
		 mov address_isa,07H
         call read_isa
         mov time[5],al 
        
;DAY    
         mov address_isa,04h 
         call read_isa
         mov time[7],al
        
;hour  
        mov address_isa,02h 
        call read_isa
        mov time[9],al 
        
;minutes 
         mov address_isa,00h 
         call read_isa
         mov time[11],al  	
         
		 mov address_isa,06h
		 call read_isa 
		 mov time [12],al 
		 
          mov cx,12	
		  mov si,0 
display_time:
          mov al,time[si]
		  mov  bx,si
		  mov flag,bx 
          and flag,01h 
          cmp flag,01h 
          jz  ou   	
		
    	  call assc_al
          jmp next_time 		  
    ou:
          call asstohex_color
next_time:
 		  inc si 
          loop display_time
         mov start_cow,24
		 mov start_row,3 
		 call start_point
         		  
          mov al,time[12]
          cmp al,2
          jz display_week1
          cmp al,3 
          jz display_week2
		  cmp al,4 
		  jz display_week3
		  cmp al,5
		  jz display_week4
		  cmp al,6 
		  jz display_week5 
		  cmp al,0
		  jz display_week6 
		  cmp al,1 
		  jz display_week7 
		  jmp cheack_cmos
display_week1:
          msg week_1
          jmp cheack_cmos	
display_week2:
          msg week_2
          jmp cheack_cmos			  
display_week3:
          msg week_3
          jmp cheack_cmos
display_week4:
          msg week_4
          jmp cheack_cmos			  
display_week5:
          msg week_5
          jmp cheack_cmos
display_week6:
          msg week_6
          jmp cheack_cmos
display_week7:
          msg week_7
         ; jmp read_time

cheack_cmos:

	
        mov ah,11h    
        int 16h      ;检测按键是有否按下
       ; jz   cheack_cmos
       
        jz   read_time
		
		mov ah,8
		int 21h
        cmp al,'q'     
        jz  first_screen
		cmp al,'Q'     ;若为Q 键则退出
        jz  first_screen
	;**********************************************
         		 
        jmp cheack_cmos		 

.exit 


		
		
		
        read_isa   proc far public 
         mov al,address_isa  
         out 70h,al  
         in  al,71h 
		ret 
        read_isa  endp 		
         
		  
		assc_al proc far               ;hex to asscii from al    ASSCC 
			   PUSHa
			   mov dl,al
			   mov ah,2                ; 
			   int 21h 
			   popa
			   ret
	   assc_al endp



 
end 
