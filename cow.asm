.model small
.586
.data 
  mesg_text db 'hello word',08h,'a','$'
  .code
  .startup
 include MACRO_zifu.MAC 
 msg mesg_text
 jmp $ 
  
  
  
  .exit
  end 