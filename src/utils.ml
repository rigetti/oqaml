module M = Owl.Dense.Matrix.C
open Primitives

let kron_up =
  List.fold_left M.kron (M.ones 1 1)

let int_pow base exp = (float_of_int base) ** (float_of_int exp) |> int_of_float

let rec binary_rep x =
  let rem = x mod 2 in
  if x > 0 then rem::(binary_rep (x / 2))
  else []

let rec pad_list n l =
  let pl = [0]@l in
  if List.length(pl) <= n then pad_list n pl
  else l

let rec range i j =
  if i < j then i :: (range (i+1) j)
  else []

let build_gate_list n q g =
  let rec _buildList i n q g =
    let x = i+1 in
    if (i != q) && (i < n) then id::(_buildList x n q g)
    else if (i == q) && (i < n) then g::(_buildList x n q g)
    else [] in
  _buildList 0 n q g


(* This method construct a list of identies and a single two-qubit gate [g]
 * between a control qubit [ql] and its target at position (ql+1) on a qubit
 * register of length [n]. The value [i] is used for recursion purposes only *)
let build_gate_list_with_2q_gate n ql g =
  let rec _build_nn_2q_gate_list i n ql g =
    let x = i+1 in
    if ql < n-1 then
      if (i != ql) && (i < n) then id::(_build_nn_2q_gate_list x n ql g)
      else if (i == ql) && (i < n-1) then g::(_build_nn_2q_gate_list (x+1) n ql g)
      else []
    else
      if (i != (n-2)) && (i < n-1) then id::(_build_nn_2q_gate_list x n ql g)
      else if (i == (n-2)) && (i < n) then g::[]
      else [] in
  _build_nn_2q_gate_list 0 n ql g

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


let get_1q_gate n q g =
  kron_up (build_gate_list n q g)

(* Currently this only support control qubits left of the target subits. The
 * implementation of reverse is merely a 180 degree rotation of the resulting
 * matrix. Howver, I need to double check this to make sure of that. *)
let get_2q_gate n ctrl trgt g=
  let swpgtr = swapagator ctrl trgt n in
  let gt = kron_up (build_gate_list_with_2q_gate n ctrl g) in
  M.dot swpgtr (M.dot gt swpgtr)