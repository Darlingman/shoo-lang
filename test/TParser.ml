open OUnit2
open Ast

let parse input =
  let lexbuf = Lexing.from_string input in
  Parser.program Scanner.token lexbuf

let empty_prog test_ctxt = assert_equal [] (parse "")

let int_lit test_ctxt = assert_equal [Expr(IntLit(5))] (parse "5;")

let mandatory_semi test_ctxt =
  let f = fun () -> parse "5" in
  assert_raises Parsing.Parse_error f

let comment_test1 test_ctxt = assert_equal [Expr(IntLit(5)); Expr(IntLit(6))] (parse "5;/* this is a \n5; multiline \n comment */6;")

let comment_test2 test_ctxt = assert_equal [Expr(IntLit(5)); Expr(IntLit(6))] (parse "5;/* this is a /* once \n 5; nested */ multiline \n comment */6;")

let comment_test3 test_ctxt = assert_equal [Expr(IntLit(5)); Expr(IntLit(6))] (parse "5;/* this is a /* /* twice \n 5; */ \n nested */ multiline \n comment */6;")

let linec_test test_ctxt = assert_equal [Expr(IntLit(5)); Expr(IntLit(6))] (parse "5; // this is a comment \n 6;")

let comment_tests =
  "Comments" >:::
  [
    "Should accept multiline comment" >:: comment_test1;
    "Should accept once nested multiline comment" >:: comment_test2;
    "Should accept twice nested multiline comment" >:: comment_test3;
    "Should handle single line comment" >:: linec_test;
  ]

let float_test1 test_ctxt = assert_equal [Expr(FloatLit(0.1234))] (parse "0.1234;")
let float_test2 test_ctxt = assert_equal [Expr(FloatLit(0.1234))] (parse ".1234;")

let float_tests =
  "Floating point numbers" >:::
  [
    "Should accept positive with leading 0" >:: float_test1;
    "Should accept positive with leading 0 omitted" >:: float_test2;
  ]

let int_dec text_ctxt = assert_equal [VDecl(Int, "x")] (parse "int x;")
let int_def text_ctxt = assert_equal [VDef(Int, "x", IntLit(5))] (parse "int x = 5;")
let vdec_tests =
  "Variable declarations and definitions" >:::
  [
    "Should handle declaration of int" >:: int_dec;
    "Should handle definition of int" >:: int_def;
  ]


let if_only text_ctxt = 
  assert_equal [If(BoolLit(true),[VDecl(Int, "x")],[])] (parse "if(true){int x;}")
let if_else text_ctxt = 
  assert_equal [If(BoolLit(false),[VDecl(Int, "x")],[VDecl(Int, "y")])] 
  (parse "if(false){int x;}else{int y;}")
let if_elif1 text_ctxt = 
  assert_equal [If(BoolLit(false),[VDecl(Int, "x")],[If(BoolLit(true),[VDecl(Int, "y")],[])])] 
  (parse "if(false){int x;}elif(true){int y;}")
let if_elif1_else text_ctxt = 
  assert_equal [If(BoolLit(false),[VDecl(Int, "x")],[If(BoolLit(false),[VDecl(Int, "y")],[VDecl(Int, "z")])])] 
  (parse "if(false){int x;}elif(false){int y;}else{int z;}")
let if_elif2_else text_ctxt = 
  assert_equal [If(BoolLit(false),[VDecl(Int, "x")],[If(BoolLit(false),[VDecl(Int, "y")],[If(BoolLit(false),[VDecl(Int, "w")],[VDecl(Int, "z")])])])] 
  (parse "if(false){int x;}elif(false){int y;}elif(false){int w;}else{int z;}")
let if_else_tests =
  "If else tests" >:::
  [
    "Should handle if statement by itself" >:: if_only;
    "Should handle if statement with else" >:: if_else;
    "Should handle if statement with elif" >:: if_elif1;
    "Should handle if statement with elif and else" >:: if_elif1_else;
    "Should handle if statement with 2 elifs and else" >:: if_elif2_else;
  ]

let tests =
  "Parser" >:::
  [
    "Should accept empty program" >:: empty_prog;
    "Should accept int literal" >:: int_lit;
    "Semicolon should be mandatory" >:: mandatory_semi;
    comment_tests;
    float_tests;
    vdec_tests;
    if_else_tests;
  ]
