type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

(* Problem 1: convert_grammar *)
(* Function to retrieve the alternative list for a given nonterminal symbol using partial application *)
let rec get_alternative_list rules_list nonterminal = match rules_list with
| [] -> []
| h::t -> if (fst h) = nonterminal then (snd h)::(get_alternative_list t nonterminal)
                else get_alternative_list t nonterminal;;

let convert_grammar gram1 =  
  let root_sym = fst gram1 in
  let gram_rules = snd gram1 in
  let prod_func = get_alternative_list gram_rules in
  (root_sym, prod_func);;

(* Problem 2: parse_tree_leaves *)
let rec parse_tree_list list = match list with
  | [] -> []
  | h::t -> match h with 
    | Leaf l -> l::(parse_tree_list t)
    | Node (nonterminal, subtree) -> (parse_tree_list subtree) @ (parse_tree_list t);;

let parse_tree_leaves tree = parse_tree_list [tree];;

(* Problem 3: make_matcher *)
let empty_match accept frag = accept frag;;
let no_match accept frag = None;;

let rec matcher prod_func root_sym = function 
  | [] -> no_match
  | h::t ->
    fun accept frag -> 
    let h_m = cur_rule_it prod_func h accept frag 
    and t_m = matcher prod_func root_sym t 
    in match h_m with
      | None -> t_m accept frag
      | _ -> h_m
and cur_rule_it prod_func = function 
  | [] -> empty_match
  (* Current rule head is nonterminal symbol -- DFS this symbol to try to find prefix match *)
  | (N nonterminal)::t -> 
  let rules = prod_func nonterminal 
  in fun accept frag ->
    let new_acc = cur_rule_it prod_func t accept
    in matcher prod_func nonterminal rules new_acc frag
  | (T terminal)::t -> (fun accept -> function
    | [] -> None
    | f_h::f_t -> 
      if f_h = terminal then cur_rule_it prod_func t accept f_t 
      else None);;

let make_matcher gram = 
  let root_sym = fst gram in
  let prod_func = snd gram in
  let rules = prod_func root_sym in
  fun accept frag ->
  matcher prod_func root_sym rules accept frag;;

(* Problem 4: make_parser *)
let empty_match_parser accept derivation frag = accept derivation frag;;
let no_match_parser accept derivation frag = None;;
let accept derivation suffix = Some (derivation, suffix);;

let rec matcher_parser prod_func root_sym = function 
  | [] -> no_match_parser
  | r_h::r_t -> 
    fun accept derivation frag ->
      let head_matcher = current_rule_iterator_parser prod_func r_h accept (derivation @ [(root_sym, r_h)]) frag 
      and tail_matcher = matcher_parser prod_func root_sym r_t 
      in match head_matcher with
        | None -> tail_matcher accept derivation frag
        | _ -> head_matcher
(* Helper function to match current rule (i.e. prefix) with frag by performing a linear scan *)
and current_rule_iterator_parser prod_func = function 
  | [] -> empty_match_parser
  | (N nonterminal)::r_t -> 
    let rules = prod_func nonterminal 
    in fun accept derivation frag ->
      let new_accept = current_rule_iterator_parser prod_func r_t accept
      in matcher_parser prod_func nonterminal rules new_accept derivation frag
  | (T terminal)::r_t -> (fun accept derivation -> function
      | [] -> None
      | frag_head::frag_tail -> 
        if frag_head = terminal then current_rule_iterator_parser prod_func r_t accept derivation frag_tail 
        else None);;

let rec make_parse_tree = function
  | (nonterminal, rule)::derivation_tail -> 
    begin
    let paths = dfs_current_node derivation_tail rule 
    in match paths with 
      | (rem_der, curr_to_leaves) ->
        let node = Node (nonterminal, curr_to_leaves) in
        rem_der, node
    end
and dfs_current_node rem_der = function 
  | [] -> rem_der, []
  | (N nonterminal)::r_t -> 
    (* Build out parse subtree from current elem of rules list *)
    (let curr_to_leaves = make_parse_tree rem_der 
    in match curr_to_leaves with
      | (rem_der_1, curr_paths) ->
        let other_rules_to_leaves = dfs_current_node rem_der_1 r_t 
        in match other_rules_to_leaves with
          | (rem_der_2, other_rules_paths) ->
            let all_paths = (curr_paths::other_rules_paths) in
            rem_der_2, all_paths)
  | (T terminal)::r_t -> 
    (let subtrees = dfs_current_node rem_der r_t
    in match subtrees with
      | (rem_der_1, additional_paths) ->
        let leaf = ((Leaf terminal)::additional_paths) in
        rem_der_1, leaf);;

let make_parser gram = 
  let root_sym = fst gram in
  let prod_func = snd gram in
  let rules = prod_func root_sym in
  fun frag -> 
    let derivation = matcher_parser prod_func root_sym rules accept [] frag
    in match derivation with
      | None -> None
      | Some (prefix, suffix) ->
        if suffix != [] then None
        else 
          let parse_tree = make_parse_tree prefix
          in match parse_tree with
            | (_, tree) -> Some tree;; 
