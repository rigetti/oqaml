module Ma = Owl.Dense.Matrix.C;;
module Co = Complex;;
open Primitives;;

let int_pow base exp = (float_of_int base) ** (float_of_int exp) |> int_of_float;;

let rec _reverse_bin_rep x =
  let rem = x mod 2 in
  if x > 0 then rem::(_reverse_bin_rep (x / 2))
  else [];;

let rec pad_list n l =
  let pl = [0]@l in
  if List.length(pl) <= n then pad_list n pl
  else l;;

let rec range i j =
  if i < j then i :: (range (i+1) j)
  else [];;

let rec _buildList i n q g =
  let x = i+1 in
  if (i != q) && (i < n) then id::(_buildList x n q g)
  else if (i == q) && (i < n) then g::(_buildList x n q g)
  else [];;

let rec _build_nn_2q_gate_list i n ql g =
  (**This method construct a list of identies and a single two-qubit gate [g] between a control qubit [ql] and
   its target at position (ql+1) on a qubit register of length [n]. The value [i] is used for recursion purposes only*)
  let x = i+1 in
  if ql < n-1 then
    if (i != ql) && (i < n) then id::(_build_nn_2q_gate_list x n ql g)
    else if (i == ql) && (i < n-1) then g::(_build_nn_2q_gate_list (x+1) n ql g)
    else []
  else
    if (i != (n-2)) && (i < n-1) then id::(_build_nn_2q_gate_list x n ql g)
    else if (i == (n-2)) && (i < n) then g::[]
    else [];;
