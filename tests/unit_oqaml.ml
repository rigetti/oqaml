module M = Owl.Dense.Matrix.C
module V = Owl.Dense.Vector.C
module Q = Oqaml
module U = Utils
module C = Complex
module P = Primitives

let kron_assert = M.of_arrays [| [|C.one; C.zero; C.zero; C.zero |];
                                 [|C.zero; C.one; C.zero; C.zero |];
                                 [|C.zero; C.zero; C.one; C.zero |];
                                 [|C.zero; C.zero; C.zero; C.one |] |]

let rotate_cnot = M.of_arrays [| [|C.zero; C.one; C.zero; C.zero |];
                                 [|C.one; C.zero; C.zero; C.zero |];
                                 [|C.zero; C.zero; C.one; C.zero |];
                                 [|C.zero; C.zero; C.zero; C.one |] |]

module To_test = struct

  let kron_up () = U.kron_up [P.id; P.id] = kron_assert

  let build_list () = U.build_gate_list 4 1 P.sx = [P.id; P.sx; P.id; P.id]

  let int_pow () = U.int_pow 2 5 = 32

  let range () = U.range 2 5 = [2;3;4]

  let bin_rep () = U.binary_rep 11 = [1;1;0;1]

  let pad_list () = U.pad_list 4 [1; 1] = [0; 0; 1; 1]

  let nn_2q_gate_list () = U.build_gate_list_with_2q_gate 3 1 P.cnot = [P.id; P.cnot]

  let swpgtr () = U.swapagator 0 2 5 = U.kron_up [P.id; P.swap; P.id; P.id]
  (* Assert can be kron as we check the correctness of kron above*)

  let swpgtr2 () = U.swapagator 0 3 5 = M.dot (U.kron_up [P.id; P.swap; P.id; P.id]) (U.kron_up [P.id; P.id; P.swap; P.id])
  (* Assert can be kron as we check the correctness of kron above and M.dot is external dep*)

  let get_2q_gt () = U.get_2q_gate 3 0 2 P.cnot = M.dot (U.swapagator 0 2 3) (M.dot (U.kron_up [P.cnot; P.id]) (U.swapagator 0 2 3))

  let apply_instr_set () = Q.apply_instructions (Q.INSTRUCTIONSET([Q.Y 2; Q.CNOT (0,1); Q.X 0])) (Q.init_qvm 3) = {Q.num_qubits=3; wf=V.mul_scalar (V.unit_basis 8 7) (C.i) |> V.transpose; reg = Array.make 3 0}

end

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

let apply_instr_set () =
  Alcotest.(check bool) "apply_instr_set" true (To_test.apply_instr_set ())

let test_set = [
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
    "Apply instruction set", `Slow, apply_instr_set;
  ]
