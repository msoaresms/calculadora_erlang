-module(divisao).
-export([divisao/2]).

divisao(_, 0) -> division_by_zero;

divisao(A, B) -> A / B.