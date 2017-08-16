# Walkthrough

## Bitstring ordering

OQaml adheres to the standard textbook ordering of the computational basis. I.e. the index of a qubit increases from left to right as opposed to the standard binary representation.

## Gates and Circuits

The application of gates $U$ represents discrete operations that bring the QVM from state $|\Psi_i\rangle$ to state $|\Psi_f\rangle$ according to the prescription

$$|\Psi_f\rangle = U |\Psi_i\rangle$$

The gates $U$ are represented by matrices. Note that the gates are not necessarily unitary as they also incorporate classical gates and projections (corresponding to measurments). A circuit is described as a composition of gates and in Kitaev ordering (time from right to left) reads as

$$|\Psi_f\rangle= U_nU_{n-1}\dots U_1 |\Psi_i\rangle$$

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

## Entanglement and Measurment

OQaml highlights the fact that a measurment is a gate operation, though it is non-unitary. In general a measurment is connected to the (partial) collapse of a wave-function. It will factorize the wave-function w.r.t. to the qubits that have been measured. To understand what is happening let us construct a circuit to create the state

$$
|\Psi\rangle \sim (|00\rangle + |11\rangle)(|0\rangle + |1\rangle)
$$

```ocaml
let tqvm = Q.apply (Q.CIRCUIT [Q.H 2; Q.CNOT (0,1); Q.H 0]) (Q.init_qvm 3);;
```

Measuring Qubit 2 
```ocaml
let cqvm = Q.apply (Q.MEASURE 2) tqvm;;

>>> {Q.num_qubits = 3;
wf = 
               C0
R0        (0, 0i)
R1 (0.707107, 0i)
R2        (0, 0i)
R3        (0, 0i)
R4        (0, 0i)
R5        (0, 0i)
R6        (0, 0i)
R7 (0.707107, 0i);

reg = [|0; 0; 1|]}
```
then collapses the state either
$$
|\Phi_0\rangle \sim (|00\rangle + |11\rangle)|0\rangle
$$
or
$$
|\Phi_1\rangle \sim (|00\rangle + |11\rangle)|1\rangle
$$
leaving an entangled bell pair behind. On the other hand measureing Qubit 0 destroys the entanglement and results in 
$$
|\tilde\Phi_0\rangle \sim |00\rangle (|0\rangle + |1\rangle)
$$
or
$$
|\tilde\Phi_1\rangle \sim |11\rangle (|0\rangle + |1\rangle)
$$
Note that the measurement gives us back a valid QVM, with the classic register being filled with the corresponding measurement outcome. Both of these tests can be confirmed using the `measure_all` functionality that let's you sample from a prepared QVM state.

```ocaml
Q.measure_all cvqm 10;;

>>> [[0; 0; 1]; [1; 1; 1]; [1; 1; 1]; [1; 1; 1]; [0; 0; 1];
     [1; 1; 1]; [1; 1; 1]; [1; 1; 1]; [0; 0; 1]; [0; 0; 1]]
```