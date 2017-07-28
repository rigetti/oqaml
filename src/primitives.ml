module M = Owl.Dense.Matrix.C;;
module Math = Owl.Maths;;
module C = Complex;;

let id = M.of_arrays [| [|C.one;C.zero|];
                        [|C.zero;C.one|]|];;
let sx = M.of_arrays [| [|C.zero;C.one|];
                        [|C.one;C.zero|]|];;
let sy = M.of_arrays [| [|C.zero;C.conj C.i|];
                        [|C.i;C.zero|]|];;
let sz = M.of_arrays [| [|C.one;C.zero|];
                        [|C.zero;C.neg C.one|]|];;
let h = (M.of_arrays [| [|C.one; C.one|];
                        [|C.one; C.neg C.one|] |] |> M.div_scalar) (C.sqrt{C.re=2.0; im=0.0});;

let ct t = {C.re=Math.cos (t /. 2.0); im=0.0};;
let ist t = {C.re=0.0; im=(Math.sin (t /. 2.0))};;

let rx t = M.add (M.scalar_mul (ct t) id)  (M.scalar_mul (ist t |> C.conj) sx);;
let ry t = M.add (M.scalar_mul (ct t) id)  (M.scalar_mul (ist t |> C.conj) sy);;
let rz t = M.add (M.scalar_mul (ct t) id)  (M.scalar_mul (ist t |> C.conj) sz);;

let swap = M.of_arrays [| [|C.one; C.zero; C.zero; C.zero |];
                          [|C.zero; C.zero; C.one; C.zero |];
                          [|C.zero; C.one; C.zero; C.zero |];
                          [|C.zero; C.zero; C.zero; C.one |] |];;
let cnot = M.of_arrays [| [|C.one; C.zero; C.zero; C.zero |];
                          [|C.zero; C.one; C.zero; C.zero |];
                          [|C.zero; C.zero; C.zero; C.one |];
                          [|C.zero; C.zero; C.one; C.zero |] |];;
