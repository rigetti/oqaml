module Ma = Owl.Dense.Matrix.C;;
module Co = Complex;;

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

let id = Ma.of_arrays [| [|Co.one; Co.zero|]; [|Co.zero; Co.one|]|];;

let rec _buildList i n q g =
  let x = i+1 in
  if (i != q) && (i < n) then id::(_buildList x n q g)
  else if (i == q) && (i < n) then g::(_buildList x n q g)
  else [];;
