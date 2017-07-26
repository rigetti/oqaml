module Q = Oqam;;

(* make testable *)
let ndarray = Alcotest.testable (fun p (x : (float, float64_elt) M.t) -> ()) M.equal

module To_test = struct

  let kron_up () = Q.kron_up [Q.id; Q.id] = 3
end

let kron_up () =
  Alcotest.(check bool) "kron_up" true (To_test kron_up ())

let test_set = [
    "kron up", `Slow, kron_up;

  ];;
