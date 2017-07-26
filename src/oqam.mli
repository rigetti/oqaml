module M = Owl.Dense.Matrix.C;;
module C = Complex;;
module V = Owl.Dense.Vector.C;;

(** An ordered collection of bits *)
type register = REG of int list

(** Operation on a set of bits in a register *)
type instr = | NOT of int
             | AND of int * int
             | OR of int * int

(** Apply an instruction to a register to obtain a new register state *)
val apply : instr * register -> register

val tensor_up_single_q_gate : int -> int -> M.mat -> M.mat

val _kron_up : M.mat list -> M.mat

(** Single-Qubit Gates *)
val id : M.mat
val sx : M.mat
val sy : M.mat
val sy : M.mat

(** Single-Qubit Parametric Gates *)
val rx : float -> M.mat
val ry : float -> M.mat
val rz : float -> M.mat

(** Two-Qubit Gates *)
val cnot: M.mat
val swap: M.mat

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

(** Wavefunction type as a list of complex numbers *)
type wavefunc = WF of C.t list

(** The actual QVM type as a record *)
type qvm
val create_qvm : int -> qvm
val apply_gate : gate -> qvm -> qvm
val get_probs : qvm -> float list
val measure : qvm -> n -> int list list
