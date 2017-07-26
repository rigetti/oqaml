module M = Owl.Dense.Matrix.C;;
module Q = Oqam;;
module C = Complex;;

(* make testable *)
(* ndarray = Alcotest.testable (fun p (x : (float, float64_elt) M.t) -> ()) M.equal*)



let kron_assert = M.of_arrays [| [|C.one; C.zero; C.zero; C.zero |];
                          [|C.zero; C.one; C.zero; C.zero |];
                          [|C.zero; C.zero; C.one; C.zero |];
                          [|C.zero; C.zero; C.zero; C.one |] |];;

module To_test = struct

  let kron_up () = Q._kron_up [Q.id; Q.id] = kron_assert

end

let kron_up () =
  Alcotest.(check bool) "kron_up" true (To_test.kron_up ())

let test_set = [
    "kron up", `Slow, kron_up;

  ];;
