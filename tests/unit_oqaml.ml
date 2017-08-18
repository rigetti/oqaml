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
module M = Owl.Dense.Matrix.C
module V = Owl.Dense.Vector.C
module Q = Oqaml
module U = Utils
module C = Complex
module P = Primitives
module Math = Owl.Maths

let float_tol = 1e-6

let kron_assert = M.of_arrays [| [|C.one; C.zero; C.zero; C.zero |];
                                 [|C.zero; C.one; C.zero; C.zero |];
                                 [|C.zero; C.zero; C.one; C.zero |];
                                 [|C.zero; C.zero; C.zero; C.one |] |]

let rotate_cnot = M.of_arrays [| [|C.zero; C.one; C.zero; C.zero |];
                                 [|C.one; C.zero; C.zero; C.zero |];
                                 [|C.zero; C.zero; C.one; C.zero |];
                                 [|C.zero; C.zero; C.zero; C.one |] |]

let inv_sqrt_two = C.sqrt {C.re=0.5; im=0.0}

module To_test = struct

  let flip () = U.flip 1 [|0; 0; 0|] = [|0; 1; 0|]

  let cand () = U.cand 1 2 [|0; 1; 1|] = [|0; 1; 1|]

  let cand_2 () = U.cand 1 2 [|0; 0; 0|] = [|0; 0; 0|]

  let cor () = U.cor 1 2 [|0; 1; 0|] = [|0; 1; 1|]

  let cor_2 () = U.cor 1 2 [|0; 0; 0|] = [|0; 0; 0|]

  let xor () = U.xor 1 2 [|0; 1; 0|] = [|0; 1; 1|]

  let xor_2 () = U.xor 1 2 [|0; 1; 1|] = [|0; 1; 0|]

  let kron_up () = U.kron_up [P.id; P.id] = kron_assert

  let build_list () = U.build_gate_list 4 1 P.sx = [P.id; P.sx; P.id; P.id]

  let int_pow () = U.int_pow 2 5 = 32

  let range () = U.range 2 5 = [2;3;4]

  let bin_rep () = U.binary_rep 11 = [1;1;0;1]

  let pad_list () = U.pad_list 4 [1; 1] = [1; 1; 0; 0]

  let nn_2q_gate_list () =
    U.build_gate_list_with_2q_gate 3 1 P.cnot = [P.id; P.cnot]

  let swpgtr () = U.swapagator 0 2 5 = U.kron_up [P.id; P.swap; P.id; P.id]

  let swpgtr2 () =
    U.swapagator 0 3 5 = M.dot (U.kron_up [P.id; P.swap; P.id; P.id])
                               (U.kron_up [P.id; P.id; P.swap; P.id])

  let get_2q_gt () =
    U.get_2q_gate 3 0 2 P.cnot = M.dot (U.swapagator 0 2 3)
                                       (M.dot (U.kron_up [P.cnot; P.id])
                                              (U.swapagator 0 2 3))

  let apply_cnot () =
    let actual = [List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(0, 1); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(0, 3); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(0, 4); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(1, 3); Q.X 1])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(3, 5); Q.X 3])
                                      (Q.init_qvm 6)) 1) 0;
                 ] in
    let expected = [[1; 1; 0; 0; 0; 0];
                    [1; 0; 0; 1; 0; 0];
                    [1; 0; 0; 0; 1; 0];
                    [0; 1; 0; 1; 0; 0];
                    [0; 0; 0; 1; 0; 1]
                   ] in
    List.for_all2 (fun x y -> x = y) actual expected

  let apply_reverse_cnot () =
    let actual = [List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(1, 0); Q.X 1])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(3, 0); Q.X 3])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(4, 0); Q.X 4])
                                      (Q.init_qvm 6)) 1) 0;

                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(3, 1); Q.X 3])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.CNOT(5, 3); Q.X 5])
                                      (Q.init_qvm 6)) 1) 0;
                 ] in
    let expected = [[1; 1; 0; 0; 0; 0];
                    [1; 0; 0; 1; 0; 0];
                    [1; 0; 0; 0; 1; 0];
                    [0; 1; 0; 1; 0; 0];
                    [0; 0; 0; 1; 0; 1]
                   ] in
    List.for_all2 (fun x y -> x = y) actual expected

  let apply_swap () =
    let actual = [List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(0, 1); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(0, 3); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(0, 4); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(1, 3); Q.X 1])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(3, 5); Q.X 3])
                                      (Q.init_qvm 6)) 1) 0;
                 ] in
    let expected = [[0; 1; 0; 0; 0; 0];
                    [0; 0; 0; 1; 0; 0];
                    [0; 0; 0; 0; 1; 0];
                    [0; 0; 0; 1; 0; 0];
                    [0; 0; 0; 0; 0; 1]
                   ] in
    List.for_all2 (fun x y -> x = y) actual expected

  let apply_reverse_swap () =
    let actual = [List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(1, 0); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(3, 0); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(4, 0); Q.X 0])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(3, 1); Q.X 1])
                                      (Q.init_qvm 6)) 1) 0;
                  List.nth (Q.measure_all
                             (Q.apply (Q.CIRCUIT [Q.SWAP(5, 3); Q.X 3])
                                      (Q.init_qvm 6)) 1) 0;
                 ] in
    let expected = [[0; 1; 0; 0; 0; 0];
                    [0; 0; 0; 1; 0; 0];
                    [0; 0; 0; 0; 1; 0];
                    [0; 0; 0; 1; 0; 0];
                    [0; 0; 0; 0; 0; 1]
                   ] in
    List.for_all2 (fun x y -> x = y) actual expected

  let apply_h () = Q.apply (Q.H 0) (Q.init_qvm 1) =
                     {Q.num_qubits = 1;
                      wf = (V.of_array [|inv_sqrt_two; inv_sqrt_two|])
                           |> V.transpose;
                      reg=[|0|]}

  let apply_y () = Q.apply (Q.Y 1) (Q.init_qvm 2) =
                     {Q.num_qubits = 2;
                      wf = (V.of_array [|C.zero; C.i; C.zero; C.zero|])
                           |> V.transpose;
                      reg = [|0; 0|]}

  let apply_ry_2 () = Q.apply (Q.RY (3.141592653 /. 2.0, 0)) (Q.init_qvm 1) =
                        Q.apply (Q.H 0) (Q.init_qvm 1)

  let apply_rx_2 () = Q.apply (Q.RX (3.141592653 /. 2.0, 0)) (Q.init_qvm 1) =
                        {Q.num_qubits = 1;
                         wf = (V.of_array [|inv_sqrt_two; C.mul C.i inv_sqrt_two
                              |> C.neg|]) |> V.transpose;
                         reg = [|0|]}

  let apply_rz_2 () =
    Q.apply (Q.RZ (3.141592653 /. 2.0, 0)) (Q.init_qvm 1) =
      {Q.num_qubits = 1;
      wf = [|C.mul {C.re=1.0; im=0. -. 1.} inv_sqrt_two; C.zero|]
           |> V.of_array |> V.transpose;
      reg=[|0|]}

  let apply_phase () =
    let tqvm = Q.apply (Q.CIRCUIT ([Q.H 1; Q.H 0])) (Q.init_qvm 2) in
    Q.apply (Q.PHASE Math.pi_2) tqvm =
      {Q.num_qubits = tqvm.num_qubits;
       wf = V.mul_scalar tqvm.wf (C.polar 1. Math.pi_2);
       reg = tqvm.reg}

  let apply_circuit () =
    Q.apply (Q.CIRCUIT([Q.Y 2; Q.CNOT (0,1); Q.X 0])) (Q.init_qvm 3) =
      {Q.num_qubits = 3;
       wf = V.mul_scalar (V.unit_basis 8 7) (C.i) |> V.transpose;
       reg = Array.make 3 0}

  let apply_circuit_2 () =
    Q.apply (Q.CIRCUIT ([Q.XOR (0, 2); Q.NOT 0])) (Q.init_qvm 0 ~reg_size:3) =
      {Q.num_qubits = 0;
       wf = V.unit_basis 1 0;
       reg = [|1; 0; 1|]}

  let measure_qvm () =
    Q.apply (Q.MEASURE 1) (Q.apply (Q.CIRCUIT [Q.X 1; Q.H 0]) (Q.init_qvm 2)) =
      {Q.num_qubits = 2;
       wf = [|C.zero; inv_sqrt_two; C.zero; inv_sqrt_two;|]
            |> V.of_array |> V.transpose;
       reg = [|0; 1|]}

  let measure_all_qvm () =
    Q.measure_all (Q.apply (Q.CIRCUIT [Q.X 1; Q.X 0]) (Q.init_qvm 2)) 2 =
      [[1; 1]; [1; 1]]

  let get_probs_qvm () =
    let meas_prob = Q.get_probs (Q.apply (Q.CIRCUIT [Q.X 1; Q.H 0])
                                         (Q.init_qvm 2)) in
    let expected_prob = [0.0; 0.5; 0.0; 0.5] in
    List.for_all2 (fun a e -> (abs_float (a -. e) < float_tol)) meas_prob
                                                                expected_prob;;

end

let flip () =
  Alcotest.(check bool) "flip" true (To_test.flip ())

let cand () =
  Alcotest.(check bool) "cand" true (To_test.cand ())

let cand_2 () =
  Alcotest.(check bool) "cand_2" true (To_test.cand_2 ())

let cor () =
  Alcotest.(check bool) "cor" true (To_test.cor ())

let cor_2 () =
  Alcotest.(check bool) "cor_2" true (To_test.cor_2 ())

let xor () =
  Alcotest.(check bool) "xor" true (To_test.xor ())

let xor_2 () =
  Alcotest.(check bool) "xor_2" true (To_test.xor_2 ())

let kron_up () =
  Alcotest.(check bool) "kron_up" true (To_test.kron_up ())

let build_list () =
  Alcotest.(check bool) "build_list" true (To_test.build_list ())

let int_pow () =
  Alcotest.(check bool) "int_pow" true (To_test.int_pow ())

let range () =
  Alcotest.(check bool) "range" true (To_test.range ())

let bin_rep () =
  Alcotest.(check bool) "bin_rep" true (To_test.bin_rep ())

let pad_list () =
  Alcotest.(check bool) "pad_list" true (To_test.pad_list ())

let nn_2q_gate_list () =
  Alcotest.(check bool) "nn_2q_gate_list" true (To_test.nn_2q_gate_list ())

let swpgtr () =
  Alcotest.(check bool) "swpgtr" true (To_test.swpgtr ())

let swpgtr2 () =
  Alcotest.(check bool) "swpgtr" true (To_test.swpgtr2 ())

let get_2q_gt () =
  Alcotest.(check bool) "get_2q_gt" true (To_test.get_2q_gt ())

let apply_cnot () =
  Alcotest.(check bool) "apply_cnot" true (To_test.apply_cnot ())

let apply_reverse_cnot () =
  Alcotest.(check bool) "apply_reverse_cnot" true (To_test.apply_reverse_cnot ())

let apply_swap () =
  Alcotest.(check bool) "apply_swap" true (To_test.apply_swap ())

let apply_reverse_swap () =
  Alcotest.(check bool) "apply_reverse_swap" true (To_test.apply_reverse_swap ())

let apply_h () =
  Alcotest.(check bool) "apply_h" true (To_test.apply_h ())

let apply_y () =
  Alcotest.(check bool) "apply_y" true (To_test.apply_y ())

let apply_ry_2 () =
  Alcotest.(check bool) "apply_ry_2" true (To_test.apply_ry_2 ())

let apply_rx_2 () =
  Alcotest.(check bool) "apply_rx_2" true (To_test.apply_rx_2 ())

let apply_rz_2 () =
  Alcotest.(check bool) "apply_rz_2" true (To_test.apply_rz_2 ())

let apply_phase () =
  Alcotest.(check bool) "apply_phase" true (To_test.apply_phase ())

let apply_circuit () =
  Alcotest.(check bool) "apply_circuit" true (To_test.apply_circuit ())

let apply_circuit_2 () =
  Alcotest.(check bool) "apply_circuit_2" true (To_test.apply_circuit_2 ())

let measure_qvm () =
  Alcotest.(check bool) "measure_qvm" true (To_test.measure_qvm ())

let measure_all_qvm () =
  Alcotest.(check bool) "measure_all_qvm" true (To_test.measure_all_qvm ())

let get_probs_qvm () =
  Alcotest.(check bool) "get_probs_qvm" true (To_test.get_probs_qvm ())

let test_set = [
    "flip", `Slow, flip;
    "classical AND", `Slow, cand;
    "classical AND 2", `Slow, cand_2;
    "classical OR", `Slow, cor;
    "classical OR 2", `Slow, cor_2;
    "classical XOR", `Slow, xor;
    "classical XOR 2", `Slow, xor_2;
    "kron up", `Slow, kron_up;
    "build list", `Slow, build_list;
    "integer power", `Slow, int_pow;
    "range", `Slow, range;
    "bit string", `Slow, bin_rep;
    "list padding", `Slow, pad_list;
    "2Q NN gate list", `Slow, nn_2q_gate_list;
    "Dist-2 Swapagator", `Slow, swpgtr;
    "Dist-3 Swapagator", `Slow, swpgtr2;
    "Dist-2 CNOT gate", `Slow, get_2q_gt;
    "Apply CNOT", `Slow, apply_cnot;
    "Apply reverse CNOT", `Slow, apply_reverse_cnot;
    "Apply SWAP", `Slow, apply_swap;
    "Apply reverse SWAP", `Slow, apply_reverse_swap;
    "Apply Hadamard", `Slow, apply_h;
    "Apply Y", `Slow, apply_y;
    "Apply RX[PI/2]", `Slow, apply_rx_2;
    "Apply RY[PI/2]", `Slow, apply_ry_2;
    "Apply RZ[PI/2]", `Slow, apply_rz_2;
    "Apply Global Phase", `Slow, apply_phase;
    "Apply CIRCUIT gate", `Slow, apply_circuit;
    "Apply classic CIRCUIT gate", `Slow, apply_circuit_2;
    "Measure QVM", `Slow, measure_qvm;
    "Measure full QVM", `Slow, measure_all_qvm;
    "Get QVM Probabilities", `Slow, get_probs_qvm;
  ]
