module M = Owl.Dense.Matrix.C

val kron_up : M.mat list -> M.mat
val int_pow : int -> int -> int
val binary_rep : int -> int list
val pad_list : int -> int list -> int list
val range : int -> int -> int list
val _buildList : int -> int -> int -> M.mat -> M.mat list
val _build_nn_2q_gate_list : int -> int -> int -> M.mat -> M.mat list