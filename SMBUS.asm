.model small
.586
public  display_SMBUS
extrn  display_eax:far,DELAY_SHORT:far,space:far,assc:far,display_char:far,huiche:far,display_ax:far,first_screen:far,clear_screen:far       
.data   
        mesg_error_sla       db 'this slave devieve is not found','$'
		mesg_correct_slave       db 'this slave devieve is active','$'
        mesg_smbus_address   db 'BASE ADDRESS:','$'
		mesg_calculat_error  db 'can not calculate memory size','$'
		mesg_MB              db 'MB','$'
		mesg_GB              db 'GB','$'
        memory_size          dw 0
		capacity             dw 0
		SDRAM_Width          db 0 
        Ranks                db 0   
      	Primary_bus_width    db 0
        base_address         dw 0
        offset_smbus         db 0 
        slave_address        db 0 
        host_status          db 0
        loop_cont            db 0 
        buf         db 5 dup(?)
.code 
;.startup 
display_SMBUS:
;Purpose:Visit the SPD with Byte method and concluded that the SPD serial number 
;--------------------------------------------------------------------------
;read smbus base address  
;pci--bus:00h,dev:1fh,func:03h
;smbus address 20h-23h      
        include MACRO_zifu.MAC 
        call clear_screen
        mov bh,0 
        mov dh,0    
        mov dl,0     
        mov ah,02h	  
        int 10h;
          
;--------------------------------------------		
        mov dx,0cf8h        ;smbus controller PCI address=8000FB00
        mov eax,8000fb20h   ;20h   
        out dx,eax 

        mov dx,0cfch 
        in eax,dx	              
        and eax,0ffe0h      ;get smbus base_address
		
        mov base_address,ax
        msg mesg_smbus_address      ;display base address
        call display_ax	
        call huiche
		
        mov slave_address,0a1h  
        mov loop_cont,4
cheak_slave_device:		
        dec loop_cont
        mov al,slave_address
        call assc                   ;display  slave_address
        call space 
        call space
 
		
        call read_data 
		
        push cx
        mov cx,255 
check_error: 
 ;-------------------------------- 
                                    ;check error 
	  
        mov  ax,base_address
        add  ax,00h 
        mov  dx,ax 
        in   al,dx                  ;read host_status
        mov host_status,al
        and host_status,03h         
        cmp host_status,02h         
        jz  correct	 
        
        loop check_error            ;loop purpose is cheack_host_busy and error 
        pop cx                      ;if loop end and not correct
        msg mesg_error_sla          ;indicate error 
        call huiche	
        jmp  next_slave 	   
	 
correct:  
        pop cx 
   
   ;--------------------------
                                    ;cheack_slave_address a1,a3,a5,a7
        push cx 
        mov cx,18                ;read data 
        mov offset_smbus,80h 	  
read_data_again:	  
        
        call read_data
	   
	  
;------------------------------------
     	   
        mov ax,base_address
       
        add aL,05H 
        mov dx,ax 
        in al,dx 
        call display_char
	   
        inc offset_smbus
	 
        loop read_data_again
;display  memory_size
;----------------------------
       call get_memory_size
			   
next_slave:  
       call huiche 
	   
       add slave_address,2 
       cmp loop_cont,0 
       jnz  cheak_slave_device
no_input_sbus:	      
       mov ah,0
       int 16h		
;----------------------------------
       cmp ah,01h                 ;return menu:ESC  
       jz  first_screen
       jmp no_input_sbus


        



.exit 

read_data proc far 
	   pusha 
;------------------------------------------------
       ;set host status(offset:00h) 0ffh
       mov ax,base_address
       add ax,00h 
       
	   mov dx,ax 
	   mov al,0ffh 
	   out dx,al 
	   
       ;trasmit slave address 
	   
	   mov ax,base_address
	   add ax,04h 
	   
	   mov dx,ax 
       mov al,slave_address
       out dx,al 
       
       ;write the data offset in smbus device 

           mov ax,base_address
           add ax,03h 
       
           mov dx,ax 
           mov al,offset_smbus  
           out dx,al 

       ;host control 
           mov ax,base_address
           add ax,02h 
       
           mov dx,ax 
           mov al,48h 
           out dx,al 
	   
           call DELAY_SHORT
        
	   popa
	   ret 
	   read_data endp 
	   
	   
	   get_memory_size proc far 
	   

           pusha 
  
;----------------------------------------------
;purpose:  calculate memory size 


;   1. get total sdram capacity, offset:04h  bit[3.2.1.0] 
;      0000=256MB    0001=512MB    0010=1GB    0011=2GB 
;      0100=4GB      0101=8GB      0110=16GB 

        mov offset_smbus,04h 
        call  read_data
        mov  ax,base_address
        add  ax,05h 
        mov  dx,ax 
        in   al,dx
		;int 3h
        and al,0fh 
		;mov ah,0
        		
        cmp  al,0
        jz  equ_256Mb
        cmp  al,1
        jz  equ_512Mb
        cmp  al,2 
        jz  equ_1Gb	
        cmp  al,3 
        jz  equ_2Gb
        cmp  al,4 
        jz  equ_4Gb
        cmp  al,5 
        jz   equ_8Gb
        cmp  al,6 
        jz   equ_16Gb
        msg  mesg_calculat_error
        jmp next_slave
equ_256Mb:	
        mov ax,256             ;256/8     32MB 
        jmp get_capacity  	
equ_512Mb:
        mov ax,512                      ; 64MB
        jmp get_capacity         		
equ_1Gb:
        mov ax,1                     ;128MB 
        jmp get_capacity  
equ_2Gb:
        mov ax,2 
        jmp get_capacity  		
equ_4Gb:
        mov ax,4
        jmp get_capacity  		
equ_8Gb:
        mov ax,8 
        jmp get_capacity  		
equ_16Gb:
        mov ax,16 
        jmp get_capacity  

get_capacity:		
        mov capacity,ax        ;get SDRAM Capacity
		               ;int 3h
;----------------------------------
;   2. get SDRAM Device Width.  
;      offset:07h  bit[2.1.0] 
;      
;      000=4bit      001=8bit       010=16bit    011=32bit  
;      all other reserved
        mov offset_smbus,07h 
        call  read_data
      
        mov  ax,base_address
        add  ax,05h 
        mov  dx,ax 
	    in   al,dx                 
        and al,07h         ;reserve bit 0,1,2 
		;mov ah,0
        		
        cmp  al,0
        jz  equ_4bits
        cmp  al,1
        jz  equ_8bits
        cmp  al,2 
        jz  equ_16bits	
        cmp  al,3 
        jz  equ_32bits 
		                  ;else can not calculate 
        msg  mesg_calculat_error
        jmp next_slave 
equ_4bits:	
        mov al,4 
        jmp get_SDRAM_Device_Width  	
equ_8bits:
        mov al,8
        jmp get_SDRAM_Device_Width         		
equ_16bits:
        mov al,16 
        jmp get_SDRAM_Device_Width  
equ_32bits:
        mov al,32 
        jmp get_SDRAM_Device_Width  		
 

get_SDRAM_Device_Width:		
        mov SDRAM_Width,al  

;----------------------------------
;   3. get Number of Ranks.  
;      offset:07h  bit[5.4.3]      and  0011 1000   38h
;      
;      000=1_Ranks      001=2_Ranks       010=3_Ranks    011=4_Ranks  
;      all other reserved
        mov offset_smbus,07h 
        call  read_data
        mov  ax,base_address
        add  ax,05h 
        mov  dx,ax 
        in   al,dx                 
        and al,38h         ;reserve bit 3.4.5  
		;mov ah,0
        		
        cmp  al,0
        jz  equ_1_Ranks
        cmp  al,1
        jz  equ_2_Ranks
        cmp  al,2 
        jz  equ_3_Ranks
        cmp  al,3 
        jz  equ_4_Ranks 
		                  ;else can not calculate 
        msg  mesg_calculat_error
        jmp next_slave
equ_1_Ranks:	
        mov al,1 
        jmp get_Ranks 	
equ_2_Ranks:
        mov al,2
        jmp get_Ranks        		
equ_3_Ranks:
        mov al,3 
        jmp get_Ranks  
equ_4_Ranks:
        mov al,4 
        jmp get_Ranks  		
 

get_Ranks:		
        mov Ranks,al
		

;----------------------------------
;   4. get Primary_bus_width.  
;      offset:08h  bit[2.1.0]      and  0000 0111   07h
;      
;      000=1_Ranks      001=2_Ranks       010=3_Ranks    011=4_Ranks  
;      all other reserved
        mov offset_smbus,08h 
        call  read_data
        mov  ax,base_address
        add  ax,05h 
        mov  dx,ax 
        in   al,dx                 
        and al,07h              ;reserve bit 2.1.0 
	                 	        ;mov ah,0
         		
        cmp  al,0
        jz  equ_8bits_Primary_bus_width
        cmp  al,1
        jz  equ_16bits_Primary_bus_width
        cmp  al,2 
        jz  equ_32bits_Primary_bus_width
        cmp  al,3 
        jz  equ_64bits_Primary_bus_width 
		                  ;else can not calculate 
        msg  mesg_calculat_error
        jmp next_slave
equ_8bits_Primary_bus_width:	
        mov al,8 
        jmp get_Primary_bus_width	
equ_16bits_Primary_bus_width:
        mov al,16
        jmp get_Primary_bus_width        		
equ_32bits_Primary_bus_width:
        mov al,32 
        jmp get_Primary_bus_width  
equ_64bits_Primary_bus_width:
        mov al,64 
        jmp get_Primary_bus_width  		
 

get_Primary_bus_width:		
        mov Primary_bus_width,al		
;----------------------------------------
;  5.   get dd3 memory size 
;      (Capacity/8) * Primary_bus_width / SDRAM_Width*Ranks 
;                      
        mov ax,capacity
        mul Primary_bus_width         ;dx:high   ax:low      <65536
        
        mov bl,8
        div bl                       
        
        mul Ranks
        mov bl,SDRAM_Width
        div bl
        mov memory_size,ax 		  
        
        call display_ax_decc
		                             ;memory_size number 
		 
         mov  ax,base_address
         add  ax,04h 
         mov  dx,ax
         in   al,dx                 
         and al,0fh 
         mov ah,0
        		
     
         cmp  ax,2
         jc  display_MB 
         msg  MESG_GB
         
         jmp   quit_memory
display_MB:  
         msg  MESG_GB 	
quit_memory: 
         popa 
         ret 
         get_memory_size endp 
         
         
         ;-----------------------------
;purpose:  display ax with form dec 
;input:ax         
        display_ax_decc  proc far 
        pusha 
        
init_to_dec:
               
        
        mov bx,10 
        mov si,4 
     
to_dec: 
         
        mov dx,0 
        div bx 
        mov [buf+si],dl 
        dec si 
        cmp ax,0 
        ja to_dec
       
output:  
        inc si 
        mov dl,[buf+si]
        add dl,30h 
        mov ah,2 
        int 21H
        cmp si,4 
        jb output 
       
        popa 
        ret 
        display_ax_decc endp
         
end 