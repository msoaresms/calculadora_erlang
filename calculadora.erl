-module(calculadora).
-import(string, [strip/3]).
-import(net_adm, [ping/1]).
-export([start/0]).

check_connection(PID) ->
    case ping(get("soma")) of
        pong -> PID ! soma_on;
        pang -> io:fwrite("SOMA OFF\n"), exit(PID, server_down)
    end,

    case ping(get("subtracao")) of
        pong -> PID ! subtracao_on;
        pang -> io:fwrite("SUBTRAÇÃO OFF\n"), exit(PID, server_down)
    end,

    case ping(get("multiplicacao")) of
        pong -> PID ! multiplicacao_on;
        pang -> io:fwrite("MULTIPLICAÇÃO OFF\n"), exit(PID, server_down)
    end,

    case ping(get("divisao")) of
        pong -> PID ! divisao_on;
        pang -> io:fwrite("DIVISÃO OFF\n"), exit(PID, server_down)
    end.

start() ->
    io:fwrite("\n"),
    SOMA = strip(io:get_line("Informe o servidor de soma: "), right, $\n),
    SUBTRACAO = strip(io:get_line("Informe o servidor de subtração: "), right, $\n),
    MULTIPLICACAO = strip(io:get_line("Informe o servidor de multiplicação: "), right, $\n),
    DIVISAO = strip(io:get_line("Informe o servidor de divisão: "), right, $\n),
    io:fwrite("\n"),

    put("soma", list_to_atom(SOMA)),
    put("subtracao", list_to_atom(SUBTRACAO)),
    put("multiplicacao", list_to_atom(MULTIPLICACAO)),
    put("divisao", list_to_atom(DIVISAO)),

    check_connection(self()),

    [
        receive soma_on -> io:fwrite("SOMA ON\n") end,
        receive subtracao_on -> io:fwrite("SUBTRAÇÃO ON\n") end,
        receive multiplicacao_on -> io:fwrite("MULTIPLICAÇÃO ON\n") end,
        receive divisao_on -> io:fwrite("DIVISÃO ON\n") end
    ],

    rpc:call(get("soma"), soma, soma, [45, 2]).