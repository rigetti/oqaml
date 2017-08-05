module M = Owl.Dense.Matrix.C;;
module C = Complex;;
module V = Owl.Dense.Vector.C;;
module A = Array;;

(** An ordered collection of bits *)
type register = REG of int list

(** Operation on a set of bits in a register *)
type instr = | NOT of int
             | AND of int * int
             | OR of int * int

(** Apply an instruction to a register to obtain a new register state *)
val apply : instr -> register -> register

(** Gate operations on Qubits with integer index *)
type gate =
  I of int
  | X of int
  | Y of int
  | Z of int
  | H of int
  | RX of float * int
  | RY of float * int
  | RZ of float * int
  | CNOT of int*int
  | SWAP of int*int

(** The actual QVM type as a record *)
type qvm =
  { num_qubits: int;
    wf: V.vec;
    reg: int array;
  }
val create_qvm_in_state : int -> V.vec option -> qvm
val init_qvm : int -> qvm
val apply_gate : gate -> qvm -> qvm
val get_probs : qvm -> float list
val measure: qvm -> int -> qvm
val measure_all : qvm -> int -> int list list
val swapagator : int -> int -> int -> M.mat
val get_2q_gate : int -> int -> int -> M.mat -> M.mat

type instruction_set = INSTRUCTIONSET of gate list
val append_instr : gate -> instruction_set -> instruction_set
val apply_instructions : instruction_set -> qvm -> qvm
