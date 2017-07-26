(** An ordered collection of bits *)
type register = REG of int list

(** Operation on a set of bits in a register *)
type instr = | NOT of int
             | AND of int * int
             | OR of int * int

(** Apply an instruction to a register to obtain a new register state *)
val apply : instr * register -> register
