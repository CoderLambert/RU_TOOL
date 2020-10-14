del *.exe
del *.OBJ
pause
C:\masm615\ml.exe MAIN.asm
C:\masm615\ml.exe memory.asm
C:\masm615\ml.exe IOzi.asm
C:\masm615\ml.exe ISA.asm
C:\masm615\ml.exe PCI.asm
C:\masm615\ml.exe BEEP.asm
C:\masm615\ml.exe KEY.asm
C:\masm615\ml.exe A20.asm
C:\masm615\ml.exe E820.asm
C:\masm615\ml.exe 8259A.asm
C:\masm615\ml.exe CPUID.asm
C:\masm615\ml.exe Shadow.asm
C:\masm615\ml.exe CMOS.asm
C:\masm615\ml.exe option.asm
C:\masm615\ml.exe sio.asm
C:\masm615\ml.exe smbus.asm
C:\masm615\ml.exe BDA.asm
C:\masm615\ml.exe public_fuc.asm
C:\masm615\link.exe  MAIN.obj   memory.obj  public_fuc.obj  IOzi.obj   ISA.OBJ  PCI.OBJ BEEP.OBJ  KEY.OBJ  A20.OBJ  E820.OBJ  8259A.OBJ CPUID.OBJ Shadow.obj CMOS.OBJ option.obj sio.obj SMBUS.obj BDA.OBJ
pause