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