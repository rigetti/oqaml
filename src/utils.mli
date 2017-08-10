module M = Owl.Dense.Matrix.C

(** recursive kron to "tensor up" a list of matrices *)
val kron_up : M.mat list -> M.mat

(** b^e for integer values b and e *)
val int_pow : int -> int -> int

(** creates a binary representation of an integer in reverse order, i.e 
    a[0] * 2^0 + a[1] * 2^1 + a[2] * 2^2 + ... where the exponent is the
    position in the list a *)
val binary_rep : int -> int list

(** padding a list with n integers of equal value *)
val pad_list : int -> int list -> int list

(** creates a range of integers *)
val range : int -> int -> int list

(** builds a list of length [int] which at position [int] contains
    matrix [M.mat] *)
val build_gate_list : int -> int -> M.mat -> M.mat list

(** *)
val _build_nn_2q_gate_list : int -> int -> int -> M.mat -> M.mat list