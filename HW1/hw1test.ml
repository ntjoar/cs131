(* Test 1 *)
let subset_test = subset [3;2;1] [1;2;3]

(* Test 2 *)
let equal_sets_test = equal_sets [3;5] [5;5;5;3;5;3]

(* Test 3 *)
let set_union_test = equal_sets (set_union [4;5;6] [1;2;3]) [1;2;3;4;5;6]

(* Test 4 *)
let set_intersection_test = equal_sets (set_intersection [3;5;7] [1;2;3]) [3]

(* Test 5 *)
let set_diff_test = equal_sets (set_diff [1;3] [1;4;5;2]) [3]

(* Test 6 *)
let computed_fixed_point_test =
  computed_fixed_point (=) (fun x -> x *. x) 1. = 1.

(* Test 7 *)
type awksub_nonterminals =
  | Expr | Lvalue | Incrop | Binop | Num
let rules =
   []

let awksub_test = 
    filter_reachable (Expr, rules) = (Expr, rules);;
  
