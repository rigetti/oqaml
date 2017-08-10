(** This module implements the basic functionaluty of a QASM (Quantum 
    Abstract State Machine) *)
module M = Owl.Dense.Matrix.C
module V = Owl.Dense.Vector.C

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

(** The actual QVM type as a record *)
type qvm =
  { num_qubits: int;
    wf: V.vec;
    reg: int array;
  }

(** Initializes a clean QVM *)
val init_qvm : int -> qvm

(** Applies [gate] to a [qvm] resulting in a new [qvm] state *)
val apply_gate : gate -> qvm -> qvm

(** Returns the probabilities to find the [qvm] in a certain state *)
val get_probs : qvm -> float list

(** Measures the qubit at position [int] of the [qvm] resulting in a
    new [qvm] *)
val measure: qvm -> int -> qvm

(** Measures all qubits in the [qvm] [int]-times and returns the results *)
val measure_all : qvm -> int -> int list list

(** Container type to store list of gates *)
type instruction_set = INSTRUCTIONSET of gate list

(** Appends a [gate] instrunction to an [instruction_set] *)
val append_instr : gate -> instruction_set -> instruction_set

(** Applies all gates in an [instruction_set] on a [qvm] resulting in a new 
    [qvm] state *)
val apply_instructions : instruction_set -> qvm -> qvm
