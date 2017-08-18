# Walkthrough

## Quantum states and computational basis

OQaml represent the quantum states in the standard textbook ordering of the computational basis. I.e. the index of a qubit increases from left to right as opposed to the standard binary representation:

$$
|\Psi\rangle= |b_0b_1...b_{n-1}\rangle = |b_0\rangle\otimes|b_1\rangle\otimes...\otimes|b_{n-1}\rangle
$$

The individual qubit space is denoted by $|b_j\rangle \in \{|0\rangle, |1\rangle\}$. The full quantum state of a QVM with $n$ qubits can then be represented by a vector of size $2^n$ whose entries are complex numbers. The amplitude of a given computational bais state is then given by the entry in the state-vector corresponding to the integer of the bit-string representation. E.g. the state $i|10\rangle$ corresponds to the third entry in the four-dimensional wave-function vector containing the complex unit $i$. To create this state in OQaml you can run the following commands in `utop`

```ocaml
#require "oqaml, owl";;
module V = Owl.Dense.Vector.C;;
module Q = Oqaml;;

let tqvm = Q.init_qvm 2;;
```
The first few lines are necessary imports while the last line initializes a fresh QVM state in state $|00\rangle$ corresponding to the vector $(1, 0, 0, 0)^T$. To create the state $i|10\rangle$ we need to make a flip with a so-called $Y$-gate. This can be achieved by

```ocaml
Q.apply (Q.Y 0) tqvm;;
```

changing the internal wave-function vector to $(0, 0, i, 0)^T$.


## Gates and Circuits

The application of gates $U$ represents discrete operations that bring the QVM from state $|\Psi_i\rangle$ to state $|\Psi_f\rangle$ according to the prescription

$$|\Psi_f\rangle = U |\Psi_i\rangle$$

In OQaml this transition operation is deeply engrained into the syntax as seen by the type definition of the `apply` function, which maps a `gate` to a `qvm` returning a `qvm`

```ocaml
val apply: gate -> qvm -> qvm
```

The gates $U$ are represented by matrices. Note that in general gates are not unitary as they also incorporate classical gates and projections (corresponding to measurements). A circuit is described as a composition of gates and in Kitaev ordering (time from right to left) reads as

$$|\Psi_f\rangle= U_nU_{n-1}\dots U_1 |\Psi_i\rangle$$

Note the operator ordering in the above expression corresponding to the Kitaev notation indicating that time flows from right to left. Due to the mathematical similarity we can define a generalized gate as

$$
G = U_nU_{n-1}\dots U_1
$$

which highlights the fact that circuits and gates are conceptually the same mathematical type. OQaml makes use of this fact by defining gates as a *recursive type* as seen in the `gate` type definition

```ocaml
type gate =
  | ...
  | CIRCUIT of gate list
  |...
```

This abstraction lets you define arbitraty gate as a circuit, ensuring that the application of this gate in extended circuits is a valid operation as any `gate` type can be used in the `apply` function defined above.

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
let pi4 = Owl.Maths.pi_4;;
let pg idx = Q.CIRCUIT [Q.PHASE (pi4); Q.RZ(pi4, idx); Q.RY (0.0, idx); Q.RZ (pi4, idx)];;

>>> val pg : int -> Q.gate = <fun>
```
There are two things worthwhile to point out:
 1. note how the above code snippet mimicks the Kitaev ordering of the corresponding Gate/Circuit definition.
 2. the type of `pg` is `int -> Q.gate` meaning it maps an integer index to a gate, indicating the recursive nature of a gate type, as discussed above.

The newly definded gate can now be used as follows

```ocaml
Q.apply (Q.CIRCUIT [pg 0; Q.X 0]) (Q.init_qvm 1);;

>>> {Q.num_qubits = 1;
wf =
        C0
R0 (0, 0i)
R1 (0, 1i);

reg = [|0|]}
```

### Example - Equivalence between SWAP and CNOT

There is a well-known identity between $\textrm{SWAP}$ and $\textrm{CNOT}$ gates:

$$
\textrm{SWAP}[i,j] = \textrm{CNOT}[i,j] \otimes \textrm{CNOT}[j,i] \otimes \textrm{CNOT}[i,j]
$$

 We can prove this equivalence quite easy with OQaml. First we define the $\textrm{SWAP}$ gate in terms of the $\textrm{CNOT}$ gates

```ocaml
let swap i j = Q.CIRCUIT [Q.CNOT (i,j); Q.CNOT (j,i); Q.CNOT (i,j)];;
```
we can then write a test to assert equivalence

```ocaml
let tqvm = Q.apply (Q.X 0) (Q.init_qvm 2);;
Q.apply (swap 0 1) tqvm = Q.apply (Q.SWAP (0,1)) tqvm;;

>>> true
```


## Entanglement and Measurement

OQaml highlights the fact that a measurement is a gate operation, despite it being non-unitary. In general a measurement is connected to the (partial) collapse of a wave-function. It will factorize the wave-function with respect to the measured qubits. To understand what is happening let us construct a circuit to create the state

$$
|\Psi\rangle \sim (|00\rangle + |11\rangle)(|0\rangle + |1\rangle)
$$

We can do this with a simple circuit

```ocaml
let tqvm = Q.apply (Q.CIRCUIT [Q.H 2; Q.CNOT (0,1); Q.H 0]) (Q.init_qvm 3);;
```

Measuring Qubit 2 with the `MEASURE` gate
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
then collapses the state to either
$$
|\Phi_0\rangle \sim (|00\rangle + |11\rangle)|0\rangle
$$
or
$$
|\Phi_1\rangle \sim (|00\rangle + |11\rangle)|1\rangle
$$
leaving an entangled bell pair behind. On the other hand measuring Qubit 0 destroys the entanglement and results in
$$
|\tilde\Phi_0\rangle \sim |00\rangle (|0\rangle + |1\rangle)
$$
or
$$
|\tilde\Phi_1\rangle \sim |11\rangle (|0\rangle + |1\rangle)
$$
Note that the measurement returns a valid QVM, with the classic register being filled with the corresponding measurement outcome. The validity is guaranteed by the type definition of `MEASURE` and the type signature of the `apply` function. Both of the measurement tests described above can be confirmed using the `measure_all` functionality that let's you sample from a prepared QVM state:

```ocaml
Q.measure_all cvqm 10;;

>>> [[0; 0; 1]; [1; 1; 1]; [1; 1; 1]; [1; 1; 1]; [0; 0; 1];
     [1; 1; 1]; [1; 1; 1]; [1; 1; 1]; [0; 0; 1]; [0; 0; 1]]
```

In this example we prepared the QVM in the `cqvm` state above and asked the system to sample 10 individual bitstrings from `cqvm`. This enables you to now do statistical analysis on these strings and infer information about the quantum system; one notable fact is that the first two bits are always identical hinting at the presence of entanglement.
