-module(calculadora).
-import(string, [strip/3]).
-export([start/0]).

start() ->
    SOMA = strip(io:get_line("Informe o servidor de soma: "), right, $\n),
    % SUBTRACAO = io:get_line("Informe o servidor de subtração: "),
    % MULTIPLICACAO = io:get_line("Informe o servidor de multiplicação: "),
    % DIVISAO = io:get_line("Informe o servidor de divisão: "),

    put("soma", list_to_atom(SOMA)),
    % put("subtracao", SUBTRACAO),
    % put("multiplicacao", MULTIPLICACAO),
    % put("divisao", DIVISAO),

    rpc:call(get("soma"), soma, soma, [45, 2])
    .