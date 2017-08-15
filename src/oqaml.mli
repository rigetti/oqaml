(** This module implements the basic functionaluty of a QASM (Quantum
    Abstract State Machine) *)
module M = Owl.Dense.Matrix.C
module V = Owl.Dense.Vector.C


(** Gate operations on a qvm containing a classical bit register and a quantum
    state both indexed by integers. *)
type gate =
  | I of int
  | X of int
  | Y of int
  | Z of int
  | H of int
  | RX of float * int
  | RY of float * int
  | RZ of float * int
  | CNOT of int * int
  | SWAP of int * int
  | CIRCUIT of gate list
  | MEASURE of int
  | NOT of int
  | AND of int * int
  | OR of int * int
  | XOR of int * int

(** The actual QVM type as a record *)
type qvm =
  { num_qubits: int;
    wf: V.vec;
    reg: int array;
  }

(** Initializes a QVM with a classical register of [reg_size] bist and [int]
    qubits in their ground-states*)
val init_qvm : ?reg_size:int -> int -> qvm

(** Applies [gate] to a [qvm] resulting in a new [qvm] state *)
val apply : gate -> qvm -> qvm

(** Returns the probabilities to find the [qvm] in a certain quantum state *)
val get_probs : qvm -> float list

(** Measures all qubits in the [qvm] [int]-times and returns the results *)
val measure_all : qvm -> int -> int list list
