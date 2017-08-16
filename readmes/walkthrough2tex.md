# Walkthrough

## Bitstring ordering

OQaml adheres to the standard textbook ordering of the computational basis. I.e. the index of a qubit increases from left to right as opposed to the standard binary representation.

## Gates and Circuits

The application of gates $U$ represents discrete operations that bring the QVM from state $|\Psi_i\rangle$ to state $|\Psi_f\rangle$ according to the prescription

$$|\Psi_f\rangle = U |\Psi_i\rangle$$

The gates $U$ are represented by matrices. Note that the gates are not necessarily unitary as they also incorporate classical gates and projections (corresponding to measurments). A circuit is described as a composition of gates and in Kitaev ordering (time from right to left) reads as

$$|\Psi_f\rangle = U_nU_{n-1}\dots U_1 |\Psi_i\rangle$$

Due to the mathematical similarity we can define a generalized gate as

$$
G = U_nU_{n-1}\dots U_1 
$$

which highlights the fact that circuits and gates are conceptually the same mathematical type. OQaml makes use of this fact by defining gates as a *recursive type*. This lets you define a gate as a simple circuit.

### Example - Phase gate

The phase gate is defined as

$$
S = \begin{pmatrix} 1 & 0 \\ 0 & i \end{pmatrix}
$$

We can decompose any single qubit gate $U$ into a sequence of defined rotations according to

$$
U = \textrm{e}^{i\alpha} R_z(\beta)R_y(\gamma)R_z(\delta)
$$

and with a bit of algebra we find that to decompose $S$ we have $\gamma = 0$ and $\alpha = \beta=\delta = \pi/4$. In OQaml we can now define a gate according to

```ocaml
module Q = Oqaml;;
let pi4 = Owl.Maths.pi_4;;
let pg idx = Q.CIRCUIT [Q.PHASE (pi4); Q.RZ(pi4, idx); Q.RY (0.0, idx); Q.RZ (pi4, idx)];;
```

We can then use it as follows

```ocaml
Q.apply (Q.CIRCUIT [pg 0; Q.X 0]) (Q.init_qvm 1);;
```

Note how the above lines correspond to the Kitaev notation, i.e. the operations flow from right to left on the initial state.