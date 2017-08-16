# Walkthrough

## Bitstring ordering

OQaml adheres to the standard textbook ordering of the computational basis. I.e. the index of a qubit increases from left to right as opposed to the standard binary representation.

## Gates and Circuits

The application of gates <img src="svgs/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode" align=middle width=13.016025pt height=22.46574pt/> represents discrete operations that bring the QVM from state <img src="svgs/3496a2ba12495d21458eae9270e3b8de.svg?invert_in_darkmode" align=middle width=29.21721pt height=24.6576pt/> to state <img src="svgs/268bfaf5ccaeb209b8098f68e0f6a1bd.svg?invert_in_darkmode" align=middle width=32.266245pt height=24.6576pt/> according to the prescription

<p align="center"><img src="svgs/66d271e8d7ba31fb430a85027ecf2fbf.svg?invert_in_darkmode" align=middle width=96.416925pt height=17.03196pt/></p>

The gates <img src="svgs/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode" align=middle width=13.016025pt height=22.46574pt/> are represented by matrices. Note that the gates are not necessarily unitary as they also incorporate classical gates and projections (corresponding to measurments). A circuit is described as a composition of gates and in Kitaev ordering (time from right to left) reads as

<p align="center"><img src="svgs/75a46c538b2de094afe8a0c1e40cf7a5.svg?invert_in_darkmode" align=middle width=183.8265pt height=17.03196pt/></p>

Due to the mathematical similarity we can define a generalized gate as

<p align="center"><img src="svgs/031ef0cd4ce0306a1c4e62de05577659.svg?invert_in_darkmode" align=middle width=134.445795pt height=15.0684765pt/></p>

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
```

We can then use it as follows

```ocaml
Q.apply (Q.CIRCUIT [pg 0; Q.X 0]) (Q.init_qvm 1);;
```

Note how the above lines correspond to the Kitaev notation, i.e. the operations flow from right to left on the initial state.