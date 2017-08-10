module Math = Owl.Maths
module V = Owl.Dense.Vector.C
module C = Complex
open C
include Utils
module A = Array
open Primitives

(** QVM supporting ProtoQuil *)
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

type qvm =
  { num_qubits: int;
    wf : V.vec;
    reg: int array;
  }

let state_list qvm =
  let r = range 0 (int_pow 2 qvm.num_qubits) in
  List.map (fun x -> pad_list qvm.num_qubits (binary_rep x)) r

let init_qvm num_qubits =
  let _wf =((int_pow 2 num_qubits) |> V.unit_basis) 0 |> V.transpose in
  let _reg = A.make num_qubits 0 in
  {num_qubits = num_qubits;
   wf = _wf;
   reg = _reg;
  }

let get_1q_gate n q g =
  kron_up (build_gate_list n q g)


(* This constructs the full swapagator to bring a target qubit [trgt] next to
 * the control qubit [ctrl]. We first construct a padding of identities to
 * the left of [ctrl] then build the swapagator kernel of distance
 * (trgt - ctrl) and finally pad more identities to the right of [trgt] to
 * fill up to the number of qubits in the qvm. Finally we kron up the
 * resulting list to get the full swapagator. *)
let swapagator ctrl trgt nqubit =
  (* multiply all individual nearest neighbor SWAPs to propagate a qubit state
   * over a distance [dist]*)
  let _swapagator_kernel dist =
    let _multi_dot dim = List.fold_left M.dot (M.eye (int_pow 2 dim)) in
    let rec _swapagator_sub_kernels i dist =
      let x = i+1 in
      (* We need to account for the fact that we have a 2-Qubit gate already.
       * Hence when constructing the list of propagators we make the distance
       * short by one as we already have a lifted gate. E.g. a given swapagator
       * for 4 particles is:
       *        [(kron swap id id) * (kron id swap id) * (kron id id swap)],
       * which is of dimension 16. We can construct the individual lists by using
       * the buildList func where the qubit indicates the position of the pair,
       * leading to the reduction by 1 in length of the lists.*)
      if i < dist-1 then (kron_up (build_gate_list (dist-1) i swap)) ::
                           (_swapagator_sub_kernels x dist)
      else [] in
    _multi_dot dist (_swapagator_sub_kernels 0 dist) in
  kron_up ((build_gate_list (ctrl+1) ctrl id)
             @[(_swapagator_kernel (trgt-ctrl))]
             @(build_gate_list (nqubit-trgt-1) trgt id))

(* Currently this only support control qubits left of the target subits. The
 * implementation of reverse is merely a 180 degree rotation of the resulting
 * matrix. Howver, I need to double check this to make sure of that. *)
let get_2q_gate n ctrl trgt g=
  let swpgtr = swapagator ctrl trgt n in
  let gt = kron_up (_build_nn_2q_gate_list 0 n ctrl g) in
  M.dot swpgtr (M.dot gt swpgtr)

let apply_gate i qvm =
  match i with
  | I(x) -> {num_qubits=qvm.num_qubits;
             wf = V.dot (get_1q_gate qvm.num_qubits x id) qvm.wf;
             reg = qvm.reg}
  | X(x) -> {num_qubits=qvm.num_qubits;
             wf = V.dot (get_1q_gate qvm.num_qubits x sx) qvm.wf;
             reg = qvm.reg}
  | Y(x) -> {num_qubits=qvm.num_qubits;
             wf = V.dot (get_1q_gate qvm.num_qubits x sy) qvm.wf;
             reg = qvm.reg}
  | Z(x) -> {num_qubits=qvm.num_qubits;
             wf = V.dot (get_1q_gate qvm.num_qubits x sz) qvm.wf;
             reg = qvm.reg}
  | H(x) -> {num_qubits=qvm.num_qubits;
             wf = V.dot (get_1q_gate qvm.num_qubits x h) qvm.wf;
             reg = qvm.reg}
  | RX(t,x) -> {num_qubits=qvm.num_qubits;
                wf = V.dot (get_1q_gate qvm.num_qubits x (rx t)) qvm.wf;
                reg = qvm.reg}
  | RY(t,x) -> {num_qubits=qvm.num_qubits;
                wf = V.dot (get_1q_gate qvm.num_qubits x (ry t)) qvm.wf;
                reg = qvm.reg}
  | RZ(t,x) -> {num_qubits=qvm.num_qubits;
                wf = V.dot (get_1q_gate qvm.num_qubits x (rz t)) qvm.wf;
                reg = qvm.reg}
  | CNOT(x,y) -> {num_qubits=qvm.num_qubits;
                  wf = V.dot (get_2q_gate qvm.num_qubits x y cnot) qvm.wf;
                  reg = qvm.reg}
  | SWAP(x,y) -> {num_qubits=qvm.num_qubits;
                  wf = V.dot (get_2q_gate qvm.num_qubits x y swap) qvm.wf;
                  reg = qvm.reg}

let get_probs qvm =
  qvm.wf |> V.to_array |> Array.to_list
  |> (List.map (fun x -> (C.norm x) ** 2.0))

let measure_all qvm n =
  let module S = Core_extended.Sampler in
  let smplr = S.create (List.map2 (fun x y -> (x, y))
                                  (state_list qvm)
                                  (get_probs qvm)) in
  let rec sample_state smplr n i =
    let j = i+1 in
    if j < n then S.sample(smplr)::(sample_state smplr n j)
    else [] in
  sample_state smplr n 0

let measure qvm idx =
  let p0 = get_1q_gate qvm.num_qubits idx proj_0 in
  let p1 = get_1q_gate qvm.num_qubits idx proj_1 in
  let exp_val = V.dot (V.map C.conj qvm.wf |> V.transpose) (V.dot p0 qvm.wf) in
  let prob_0 = Array.get (V.to_array exp_val) 0 |> (fun x -> x.re) in
  let module R = Random in
  let rejection_prob = R.float 1. in
  if rejection_prob < prob_0 then
    let _reg = qvm.reg in
    A.set _reg idx 0;
    {num_qubits=qvm.num_qubits;
     wf = V.div_scalar (V.dot p0 qvm.wf) ({C.re=Math.sqrt prob_0; im=0.});
     reg = _reg}
  else
    let _reg = qvm.reg in
    A.set _reg idx 1;
    {num_qubits=qvm.num_qubits;
     wf = V.div_scalar (M.dot p1 qvm.wf) ({C.re=Math.sqrt (1. -. prob_0); im=0.});
     reg = _reg}

type instruction_set = INSTRUCTIONSET of gate list
let append_instr g is =
  match is with
  | INSTRUCTIONSET([]) -> INSTRUCTIONSET([g])
  | INSTRUCTIONSET(x)  -> INSTRUCTIONSET([g]@x)

let rec apply_instructions is qvm =
  match is with
  | INSTRUCTIONSET([]) -> qvm
  | INSTRUCTIONSET(x) -> List.fold_right (fun z y -> apply_gate z y ) x qvm


(** Classical Bit Register *)
type instr =
  NOT of int
  | AND of int * int
  | OR of int * int

type register = REG of int list

let bool_of_int i = if i==1 then true else false
let int_of_bool b = if b then 1 else 0

let get_reg_vals reg =
    match reg with
    | REG(lst) -> Array.of_list lst

let bit_flip b = (1 - b)
let bit_and ctr tar = if (ctr == 1 && tar == 1) then 1 else 0
let bit_or ctr tar = if (ctr == 1 || tar == 1) then 1 else 0

let flip x arr =
  arr.(x) <- bit_flip arr.(x);
  arr

let cand x y arr =
  arr.(y) <-  bit_and arr.(x) arr.(y);
  arr

let cor x y arr =
  arr.(y) <- bit_or arr.(x) arr.(y);
  arr

let apply i r =
  match i with
  | NOT(x) -> REG(Array.to_list(flip x (get_reg_vals r)))
  | AND(x, y) -> REG(Array.to_list(cand x y (get_reg_vals r)))
  | OR(x, y) -> REG(Array.to_list(cor x y (get_reg_vals r)))
