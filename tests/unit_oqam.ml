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

  let int_pow () = U.int_pow 2 5 = 32

  let range () = U.range 2 5 = [2;3;4]

  let bin_rep () = U._reverse_bin_rep 11 = [1;1;0;1]

  let pad_list () = U.pad_list 4 [1; 1] = [0; 0; 1; 1]

end

let kron_up () =
  Alcotest.(check bool) "kron_up" true (To_test.kron_up ())

let build_list () =
  Alcotest.(check bool) "build_list" true (To_test.build_list ())

let int_pow () =
  Alcotest.(check bool) "int_pow" true (To_test.int_pow ())

let range () =
  Alcotest.(check bool) "range" true (To_test.range ())

let bin_rep () =
  Alcotest.(check bool) "bin_rep" true (To_test.bin_rep ())

let pad_list () =
  Alcotest.(check bool) "pad_list" true (To_test.pad_list ())

let test_set = [
    "kron up", `Slow, kron_up;
    "build list", `Slow, build_list;
    "integer power", `Slow, int_pow;
    "range", `Slow, range;
    "bit string", `Slow, bin_rep;
    "list padding", `Slow, pad_list;
  ];;
