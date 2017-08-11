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

(** builds a list of length [int] which at position [int] contains
    matrix [M.mat] for a two-qubit gate *)
val build_gate_list_with_2q_gate : int -> int -> M.mat -> M.mat list

(** constructs the full swap-matrix for move the qubits [int] and [int]
    in a qvm with [int] qubits next to each other *)
val swapagator : int -> int -> int -> M.mat

(** creates the full gate operator for a qvm with [int] qubits with single
    qubit gate [M.mat] at position [int] *)
val get_1q_gate : int -> int -> M.mat -> M.mat

(** creates the full gate operator for a qvm with [int] qubits with two
    qubit gate [M.mat] for qubits position [int] and [int] *)
val get_2q_gate : int -> int -> int -> M.mat -> M.mat
