%  Transpose matrix
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
    lists_firsts_rests(Ms, Ts, Ms1),
    transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
    lists_firsts_rests(Rest, Fs, Oss).

check_row([], Count, X, _) :-
    X = Count.
check_row([H|T], Count, X, Prev) :-
    (Prev < H ->
        Y is X + 1,
        check_row(T, Count, Y, H);
        check_row(T, Count, X, Prev)
    ).

set_constraints(_, []).
set_constraints(Num, [Head|Tail]) :-
    length(Head, Num),
    fd_domain(Head, 1, Num),
    fd_all_different(Head),
    set_constraints(Num, Tail).

check_tower([], []).
check_tower([Row|R], [Cnt|C]) :-
    check_row(Row, Cnt, 0, 0),
    check_tower(R, C).

check_counts(Tn, T_tr, T, B, L, R) :-
    check_tower(Tn, L),

    maplist(reverse, Tn, T_rev),
    check_tower(T_rev, R),

    check_tower(T_tr, T),

    maplist(reverse, T_tr, T_tr_rev),
    check_tower(T_tr_rev, B).

%  Tower Implementation
tower(N, T, C) :-
    length(T, N),
    set_constraints(N, T),
    transpose(T, T_tr),
    set_constraints(N, T_tr),

    C = counts(Top, B, L, R),
    length(Top, N),
    length(B, N),
    length(L, N),
    length(R, N),

    maplist(fd_labeling, T),

    check_counts(T, T_tr, Top, B, L, R).

elements_between(R, Min, Max) :-
    maplist(between(Min, Max), R).

all_unique([]).
all_unique([Head|Tail]) :- member(Head, Tail), !, fail.
all_unique([_|Tail]) :- all_unique(Tail).

unique_row(N, R) :-
    length(R, N),
    elements_between(R, 1, N),
    all_unique(R).

set_constraints_plain(T, N) :-
    maplist(unique_row(N), T).

plain_tower(Num, Tn, C) :-
    length(Tn, Num),
    set_constraints_plain(Tn, Num),
    transpose(T, T_tr),
    set_constraints_plain(T_tr, Num),

    C = counts(Top, B, L, R),
    length(Top, Num),
    length(B, Num),
    length(L, Num),
    length(R, Num),

    check_counts(T, T_tr, Top, B, L, R).

stats_tower(Tr) :-
  statistics(cpu_time, [S|_]),
  tower(4, _, counts([4,3,2,1],[1,2,2,2],[4,3,2,1],[1,2,2,2])),
  statistics(cpu_time, [E|_]),
  Tr is E - S + 1.

stats_plain_tower(Tr) :-
  statistics(cpu_time, [S|_]),
  plain_tower(4, _, counts([4,3,2,1],[1,2,2,2],[4,3,2,1],[1,2,2,2])),
  statistics(cpu_time, [E|_]),
  Tr is E - S.

ambiguous(Num, Cnt, T0, T1) :-
  tower(Num, T0, Cnt),
  tower(Num, T1, Cnt),
  T0 \= T1.

speedup(Rat) :-
    stats_tower(T),
    stats_plain_tower(P),
    Rat is P / T.