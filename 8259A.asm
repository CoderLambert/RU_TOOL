.MODEL  SMALL
.586

public dispaly_8259a
extrn  clear_screen:far,first_screen:far
.data
 msg_bell   db 'this is replace interrupt function',0dh,0ah,'$'
.code
dispaly_8259a:
include MACRO_zifu.MAC 
start_8259A: 
        call clear_screen 
        mov bh,0 
        mov dh,0                    ;cow number
        mov dl,0                    ;row number 
        mov ah,02h	  
        int 10h;
	    
                                     ;save old interrupt vector 
        mov al,1ch
        mov ah,35h
        int  21h
		 
        push  es
        push  bx 
        push  ds 

         		 
                                    ;set new interrupt vector
        sti 
		
        mov al,1ch 
        mov ah,25h
		 
        mov dx,seg ring 
        mov ds,dx
        mov dx,offset ring		 
        int 21h 
        pop ds                      ;restore ds 
         		 
        mov cx,10 
mmmm:		                        ;call  new interrupt vector  ten times
        int 1ch
        loop  mmmm  
		  
		
                                   ;restore old interrupt vector
        pop dx 
        pop ds 
        mov al,1ch 
        mov ah,25h
        int 21h  

NO_INPUT_8259:      
	
        mov ah,11h    
        int 16h                    ;cheack key 
        jz  NO_INPUT_8259
        mov ah,0
        int 16h           
        
        cmp ah,01h     
        jz  first_screen
        cmp al,'1'
        jz  start_8259A
		
;*********************************************
			
       jmp NO_INPUT_8259 

	   
	   ;---------------------------------------	
;dispaly meg_bell 	
	  ring proc far 
         push ds 
         push ax
         push dx 
		
       
      
        msg msg_bell

         pop   dx  
         pop   ax 
         pop   ds 
		
         iret 
ring     endp
	   
	   end 