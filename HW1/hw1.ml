(* Check if i is in a *)
let rec contains i a = match a with 
    | [] -> false
    | h::t -> (if i = h then true else contains i t);;

(* Remove an element *)

(* Assignment 1, number 1 *)
(* Check if a is a subset of b *)
let rec subset a b = match a with
    | [] -> true
    | h::t -> (if not (contains h b) then false else subset t b);;

(* Assignment 1, number 2 *)
(* Check if a and b are equal sets - including extra matches meaning identical *)
let equal_sets a b =  if subset a b && subset b a then true else false;;

(* Assignment 1, number 3 *)
(* Return the union of set a and b *)
let set_union a b = List.append a b;;

(* Assignment 1, number 4 *)
(* Return the intersection of set a and b *)
let rec set_intersection a b = 
	if subset a b then a 
    else if subset b a then b
	else (match a with 
	| [] -> []
	| h::t -> if contains h b then set_intersection (t@[h]) b 
		    else set_intersection t b);;

(* Assignment 1, number 5 *)
(* Return members of the set of all members of a that are not also members of b *)
let rec set_diff a b = 
	if set_intersection a b = [] then a
    else (match a with
    | [] -> []
    | h::t -> if not (contains h b) then set_diff (t@[h]) b
            else set_diff t b);;

(* Assignment 1, number 6 *)
(* Return the computed fixed point for f with respect to x *)
let rec computed_fixed_point eq f x =
    if (eq x (f x)) then x 
    else computed_fixed_point eq f (f x);;

(* Assignment 1, number 7 *)
(* Lol missed this at first *)
type ('nonterminal, 'terminal) symbol = | N of 'nonterminal | T of 'terminal

(* Find labels that are terminal that are really nonterminal *)
let rec false_term t = match t with
    | [] -> []
    | T _ :: t -> false_term t
    | N x :: t -> x :: false_term t;;

(* Recursively check reachablity*)
let rec reachablity n r  = n :: (match r with
    | [] -> []
    | h::t -> match h with
        | a,b -> if a = n then (false_term b)@(reachablity n t)
            else (reachablity n t));;

(* Append List *)
let rec append l r =
l @ (match l with
    | [] -> []
    | h::t -> (reachablity h r) @ (append t r));;

(* List.filter*)
let filter e r = List.filter(fun (x, y) -> List.mem x e) r;;

(* Find and return all unreachable nodes *)
let rec filter_reachable g = 
(fst g), (filter 
	(computed_fixed_point 
		equal_sets 
			(fun x -> (append x (snd g))) 
			[fst g]
		) 
(snd g));;