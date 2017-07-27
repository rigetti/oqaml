module M = Owl.Dense.Matrix.C;;
module Q = Oqam;;
module U = Utils;;
module C = Complex;;

let kron_assert = M.of_arrays [| [|C.one; C.zero; C.zero; C.zero |];
                          [|C.zero; C.one; C.zero; C.zero |];
                          [|C.zero; C.zero; C.one; C.zero |];
                          [|C.zero; C.zero; C.zero; C.one |] |];;

module To_test = struct

  let kron_up () = Q._kron_up [Q.id; Q.id] = kron_assert

  let build_list () = U._buildList 0 4 1 Q.sx = [Q.id; Q.sx; Q.id; Q.id]

end

let kron_up () =
  Alcotest.(check bool) "kron_up" true (To_test.kron_up ())

let build_list () =
  Alcotest.(check bool) "build_list" true (To_test.build_list ())

let test_set = [
    "kron up", `Slow, kron_up;
    "build list", `Slow, build_list;
  ];;
