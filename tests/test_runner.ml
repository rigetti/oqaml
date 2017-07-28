let () = begin
  Alcotest.run "OQaml" [
    "OQAML", Unit_oqaml.test_set;
  ]
end
