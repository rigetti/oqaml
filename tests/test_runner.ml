let () = begin
  Alcotest.run "OQaml" [
    "OQAM", Unit_oqam.test_set;
  ]
end
