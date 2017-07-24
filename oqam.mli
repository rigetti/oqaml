(** An ordered collection of bits *)
type register = REG of bit list

(** Operation on a set of bits in a register *)
type instr = | NOT of bit
             | AND of (bit * bit)
             | OR of (bit * bit)

(** Apply an instruction to a register to obtain a new register state *)
val apply : instr * register -> register
