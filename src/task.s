
#  int b = 0;
#  int a = 0;
#  int result = 0;

#  while (b != 0) {
# 	 if (b & 0x1 == 0x1)
# 		 result += a;

# 	 b >> = 1;
# 	 a << = 1;
#  }8

# ----------------------------------- full task -------------------------------------

.globl __start

.text
__start:
  addi x12, x0, 1
  addi x7, x0, 260
  addi x16, x0, 272
  addi x15, x0, 284

  lw  x14, -4(x7)     #               || Load size
  call mult           # mult(a, b)    || Calling function
return:
  addi x15, x0, 32    #                 || Put res address
  lw x9, 0(x15)       #                 || Get res[0]
  lw x10, 4(x15)      #                 || Get res[1]
  lw x11, 8(x15)      #                 || Get res[2]
  nop                 #                 || finish the programm
  jal Exit            #                 || exit programm

mult:
  while2_start:
      beq x14, x0, while2_end # while (i != 0)    || Check if (i != 0)
      addi x11, x0, 0         #                   || Make reg 11 accumulator of result
      lw x9, 0(x7)            #                   || Get a[i]
      lw x10, 0(x16)          #                   || Get b[i]
  while_start:                # {                 || start of while loop
      beq x10, x0, while_end  # while (b != 0)    || Check if (b != 0)
      and x13, x10, x12       # x13 = b & 0x1     || Prepear b to compearations
      bne x13, x12, if        # if (x13 == 0x1){  || Check if b is even
      add x11, x11, x9        # result += a;      || Accumulating of result
  if:                         # }                 || If's skip
      srl x10, x10, x12       # b >> = 1;         || Dividing b by 2
      sll x9, x9, x12         # a << = 1;         || Multiplying a by 2
      j while_start           #                   || While's go to
  while_end:                  # }                 || While close bracket
      sw x11, 0(x15)          #                   || Store res[i]
      addi x7, x7,   4        #                   || a memory slide
      addi x16, x16, 4        #                   || b memory slide
      addi x15, x15, 4        #                   || Res memory slide
      sub x14, x14, x12       #                   || i--
      j while2_start          #                   || While's go to
  while2_end:
      ret                     #                   || Returning to main func

Exit:
  nop
  tail Exit

# ----------------------------------- test -------------------------------------

.globl __start

.text
__start:
		addi x7, x0, 4      #                 || Define a address
		addi x8, x0, 8      #                 || Define b address
		lw x9, 0(x7)        #                 || Load a
		lw x10, 0(x8)       #                 || Load b
    sw x11, 0(x7)       # output          || Store a
    sw x12, 0(x8)       # output          || Store b
		nop                 #                 || finish the programm
		jal Exit            #                 || exit programm

Exit:
	nop
  tail Exit
