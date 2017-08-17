(** This module defines the necessary primitive matrix representations that are
    needed to represent and construct arbitrary one- and two-qubit gates used
    in {!module:Oqaml} *)
module M = Owl.Dense.Matrix.C

(** Identiy operator for single qubit *)
val id : M.mat

(** Ground state |0> projector for single qubit *)
val proj_0 : M.mat

(** Excited state |1> projector for single qubit *)
val proj_1 : M.mat

(** X operator for single qubit *)
val sx : M.mat

(** Y operator for single qubit *)
val sy : M.mat

(** Z operator for single qubit *)
val sz : M.mat

(** Hadamard operator for single qubit *)
val h : M.mat

(** RX(t) operator for single qubit *)
val rx : float -> M.mat

(** RY(t) operator for single qubit *)
val ry : float -> M.mat

(** RZ(t) operator for single qubit *)
val rz : float -> M.mat

(** SWAP operator for two qubit *)
val swap : M.mat

(** CNOT operator for two qubit *)
val cnot : M.mat