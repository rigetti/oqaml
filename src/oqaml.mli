(* Copyright 2017 Rigetti Computing, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

(** This module implements the basic functionality of the
    {b O}Caml
    {b Q}uantum
    {b A}bastract
    {b M}achine
    {b L}anguange,
    a QASM (Quantum Abstract State Machine) *)
module M = Owl.Dense.Matrix.C
module V = Owl.Dense.Vector.C

(** The QVM is a record type containing the number of qubits, a wave-function
    connected to the quantum state of the quibits and a classical register that
    can be used to read out the qubits into classical bits *)
type qvm =
  { num_qubits: int;
    wf: V.vec;
    reg: int array;
  }

(** Gate operations on a qvm containing operations on the classical bit register
    and the quantum state. The target qubits and bits are indexed by integers
    denoting their position in the wave-function and classical register. *)
type gate =
  | I of int (** Reversible quantum operation on the wave-function*)
  | X of int (** Reversible quantum operation on the wave-function*)
  | Y of int (** Reversible quantum operation on the wave-function*)
  | Z of int (** Reversible quantum operation on the wave-function*)
  | H of int (** Reversible quantum operation on the wave-function*)
  | PHASE of float (** Reversible quantum operation on the wave-function*)
  | RX of float * int (** Reversible quantum operation on the wave-function*)
  | RY of float * int (** Reversible quantum operation on the wave-function*)
  | RZ of float * int (** Reversible quantum operation on the wave-function*)
  | CNOT of int * int (** Reversible quantum operation on the wave-function*)
  | SWAP of int * int (** Reversible quantum operation on the wave-function*)
  | CIRCUIT of gate list (** Recursive type for circuits *)
  | MEASURE of int (** Projective measurement gate *)
  | NOT of int (** Classic operation on the bit register *)
  | AND of int * int (** Classic operation on the bit register *)
  | OR of int * int (** Classic operation on the bit register *)
  | XOR of int * int (** Classic operation on the bit register *)

(** Initializes a QVM with a classical register of [reg_size] bist and [int]
    qubits in their ground-states*)
val init_qvm : ?reg_size:int -> int -> qvm

(** Applies [gate] to a [qvm] resulting in a new [qvm] state *)
val apply : gate -> qvm -> qvm

(** Returns the probabilities to find the [qvm] in a certain quantum state *)
val get_probs : qvm -> float list

(** Measures all qubits in the [qvm] [int]-times and returns the results in a
    [list] of [int list]*)
val measure_all : qvm -> int -> int list list
