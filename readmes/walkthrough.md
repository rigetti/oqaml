# Walkthrough

## Quantum states and computational basis

OQaml represent the quantum states in the standard textbook ordering of the computational basis. I.e. the index of a qubit increases from left to right as opposed to the standard binary representation:

<p align="center"><img src="svgs/eae4a169bf644f525c0dcca105efe860.svg?invert_in_darkmode" align=middle width=322.46115pt height=16.438356pt/></p>

The individual qubit space is denoted by <img src="svgs/f2662eb06c89703c22cbe91038838e1c.svg?invert_in_darkmode" align=middle width=107.132025pt height=24.6576pt/>. The full quantum state of a QVM with <img src="svgs/55a049b8f161ae7cfeb0197d75aff967.svg?invert_in_darkmode" align=middle width=9.867pt height=14.15535pt/> qubits can then be represented by a vector of size <img src="svgs/f8f25e4580c418a51dc556db0d8d2b93.svg?invert_in_darkmode" align=middle width=16.34523pt height=21.8394pt/> whose entries are complex numbers. The amplitude of a given computational bais state is then given by the entry in the state-vector corresponding to the integer of the bit-string representation. E.g. the state <img src="svgs/e066fcf03f881090e3a1335e26353c45.svg?invert_in_darkmode" align=middle width=33.06072pt height=24.6576pt/> corresponds to the third entry in the four-dimensional wave-function vector containing the complex unit <img src="svgs/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode" align=middle width=5.663295pt height=21.68331pt/>.

To create the above state in OQaml you can run the following commands in `utop`

```ocaml
#require "oqaml, owl";;
module V = Owl.Dense.Vector.C;;
module Q = Oqaml;;

let tqvm = Q.init_qvm 2;;
```
The first few lines are necessary imports while the last line initializes a fresh QVM state in state <img src="svgs/7ede3903c304a52a12ae71a1a74a30f6.svg?invert_in_darkmode" align=middle width=27.397425pt height=24.6576pt/> corresponding to the vector <img src="svgs/8cdbe372b80a2ea9f2296c5475324a01.svg?invert_in_darkmode" align=middle width=77.11374pt height=27.65697pt/>. To create the state <img src="svgs/e066fcf03f881090e3a1335e26353c45.svg?invert_in_darkmode" align=middle width=33.06072pt height=24.6576pt/> we need to make a flip with a so-called <img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.19637pt height=22.46574pt/>-gate. This can be achieved by

```ocaml
Q.apply (Q.Y 0) tqvm;;
```

changing the internal wave-function vector to <img src="svgs/fc5d6ad79c18da32b2b1c072f678840b.svg?invert_in_darkmode" align=middle width=74.557725pt height=27.65697pt/>.


## Gates and Circuits

The application of gates <img src="svgs/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode" align=middle width=13.016025pt height=22.46574pt/> represents discrete operations that bring the QVM from state <img src="svgs/3496a2ba12495d21458eae9270e3b8de.svg?invert_in_darkmode" align=middle width=29.21721pt height=24.6576pt/> to state <img src="svgs/268bfaf5ccaeb209b8098f68e0f6a1bd.svg?invert_in_darkmode" align=middle width=32.266245pt height=24.6576pt/> according to the prescription

<p align="center"><img src="svgs/66d271e8d7ba31fb430a85027ecf2fbf.svg?invert_in_darkmode" align=middle width=96.416925pt height=17.03196pt/></p>

The gates <img src="svgs/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode" align=middle width=13.016025pt height=22.46574pt/> are represented by matrices. Note that the gates are not necessarily unitary as they also incorporate classical gates and projections (corresponding to measurments). A circuit is described as a composition of gates and in Kitaev ordering (time from right to left) reads as

<p align="center"><img src="svgs/ee24cfd2696b482b73aa1a593306dcfc.svg?invert_in_darkmode" align=middle width=183.8265pt height=17.03196pt/></p>

Note the operator ordering in the above expression corresponding to the Kitaev notation indicating that time flows from right to left. Due to the mathematical similarity we can define a generalized gate as

<p align="center"><img src="svgs/b4585711718e126580216be235f852cc.svg?invert_in_darkmode" align=middle width=134.445795pt height=15.0684765pt/></p>

which highlights the fact that circuits and gates are conceptually the same mathematical type. OQaml makes use of this fact by defining gates as a *recursive type*. This lets you define a gate as a simple circuit.

### Example - Phase gate

The phase gate is defined as

<p align="center"><img src="svgs/383cfb997cd358ec5e782fba1df8f24e.svg?invert_in_darkmode" align=middle width=90.022845pt height=39.45249pt/></p>

We can decompose any single qubit gate <img src="svgs/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode" align=middle width=13.016025pt height=22.46574pt/> into a sequence of defined rotations according to

<p align="center"><img src="svgs/d9f46c357b11466d8c281a1edabb8756.svg?invert_in_darkmode" align=middle width=182.62695pt height=19.104525pt/></p>

and with a bit of algebra we find that to decompose <img src="svgs/e257acd1ccbe7fcb654708f1a866bfe9.svg?invert_in_darkmode" align=middle width=11.027445pt height=22.46574pt/> we have <img src="svgs/edad3500d9f7368f82c110d98051b30b.svg?invert_in_darkmode" align=middle width=39.56073pt height=21.18732pt/> and <img src="svgs/cff54eb79a3dbe3fa7e283c25b807932.svg?invert_in_darkmode" align=middle width=120.82158pt height=24.6576pt/>. In OQaml we can now define a gate according to

```ocaml
module Q = Oqaml;;
let pi4 = Owl.Maths.pi_4;;
let pg idx = Q.CIRCUIT [Q.PHASE (pi4); Q.RZ(pi4, idx); Q.RY (0.0, idx); Q.RZ (pi4, idx)];;

>>> val pg : int -> Q.gate = <fun>
```
There are two things worthwhile to point out:
 1. note how the above code snippet mimicks the Kitaev ordering of the corresponding Gate/Circuit definition.
 2. the type of `pg` is `int -> Q.gate` meaning it maps an integer index to a gate, just as we discussed above indicating the recursive nature of a gate type

We can use the newly definded gat as follows

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

There is a well-known identity between <img src="svgs/7de2e863a1bdea96569f901e67683ba1.svg?invert_in_darkmode" align=middle width=47.71701pt height=22.46574pt/> and <img src="svgs/443f9e1eba72ecafb96c1180a2d3ade0.svg?invert_in_darkmode" align=middle width=48.858645pt height=22.46574pt/> gates:

<p align="center"><img src="svgs/1067678fc5d072c57cc5015fd43861bc.svg?invert_in_darkmode" align=middle width=374.72655pt height=16.438356pt/></p>

 We can prove this equivalence quite easy with OQaml. First we define the <img src="svgs/7de2e863a1bdea96569f901e67683ba1.svg?invert_in_darkmode" align=middle width=47.71701pt height=22.46574pt/> gate in terms of the <img src="svgs/443f9e1eba72ecafb96c1180a2d3ade0.svg?invert_in_darkmode" align=middle width=48.858645pt height=22.46574pt/> gates

```ocaml
let swap i j = Q.CIRCUIT [Q.CNOT (i,j); Q.CNOT (j,i); Q.CNOT (i,j)];;
```
we can then write a test to assert equivalence

```ocaml
let tqvm = Q.apply (Q.X 0) (Q.init_qvm 2);;
Q.apply (swap 0 1) tqvm = Q.apply (Q.SWAP (0,1)) tqvm;;

>>> true
```


## Entanglement and Measurment

OQaml highlights the fact that a measurment is a gate operation, though it is non-unitary. In general a measurment is connected to the (partial) collapse of a wave-function. It will factorize the wave-function w.r.t. to the qubits that have been measured. To understand what is happening let us construct a circuit to create the state

<p align="center"><img src="svgs/5efd49e23c03e3611f5c570d73206c99.svg?invert_in_darkmode" align=middle width=204.567pt height=16.438356pt/></p>

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
<p align="center"><img src="svgs/3d5a1e6c7d2ebefc7bbf8c9210b22233.svg?invert_in_darkmode" align=middle width=158.972715pt height=16.438356pt/></p>
or
<p align="center"><img src="svgs/68c164a747b4d059a9b9a5d0cc78e912.svg?invert_in_darkmode" align=middle width=158.972715pt height=16.438356pt/></p>
leaving an entangled bell pair behind. On the other hand measureing Qubit 0 destroys the entanglement and results in
<p align="center"><img src="svgs/b2d182b77b130a9c3e32f91f35f837d9.svg?invert_in_darkmode" align=middle width=150.753405pt height=19.24329pt/></p>
or
<p align="center"><img src="svgs/33a3b073ff70009a0611eabd0915eac2.svg?invert_in_darkmode" align=middle width=150.753405pt height=19.24329pt/></p>
Note that the measurement gives us back a valid QVM, with the classic register being filled with the corresponding measurement outcome. Both of these tests can be confirmed using the `measure_all` functionality that let's you sample from a prepared QVM state.

```ocaml
Q.measure_all cvqm 10;;

>>> [[0; 0; 1]; [1; 1; 1]; [1; 1; 1]; [1; 1; 1]; [0; 0; 1];
     [1; 1; 1]; [1; 1; 1]; [1; 1; 1]; [0; 0; 1]; [0; 0; 1]]
```