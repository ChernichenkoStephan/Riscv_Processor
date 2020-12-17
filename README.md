# Riscv_Processor
Simple RISC-V processor project

Decoder for hex display:
  hex_decoder.v
Data memory module:
  miriscv_dm.v
Ram module:
  miriscv_ram.sv
Instructions decoder module:
  mriscv_decoder.v
ALU module:
  miriscv_alu.v
Instructions memory module:
  miriscv_im.v
Register file module:
  miriscv_rf.v
Primitive processor module (with simple instructions & without decoder):
  proto_processor.v
Simple risc-v processor module:
  miriscv_core.v
Load store unit module:
  miriscv_lsu.v
Connection module:
  miriscv_top.sv
Assembly code to run:
  task.s
