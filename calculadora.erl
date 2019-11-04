-module(calculadora).
-import(string, [strip/3, split/3]).
-import(net_adm, [ping/1]).
-export([start/0]).

read_input() -> strip(io:get_line("Informe a expressão: "), right, $\n).

% https://stackoverflow.com/questions/17438727/in-erlang-how-to-return-a-string-when-you-use-recursion/17439656
parse(Str) ->
    {ok, Tokens, _} = erl_scan:string(Str ++ "."),
    {ok, [E]} = erl_parse:parse_exprs(Tokens),
    E.

rpn({op, _, What, LS, RS}) ->
    io_lib:format("~s ~s ~s", [rpn(LS), rpn(RS), atom_to_list(What)]);
rpn({integer, _, N}) ->
    io_lib:format("~b", [N]).

p(Str) ->
    Tree = parse(Str),
    lists:flatten(rpn(Tree)).

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

evaluate_aux(Elem) ->
    if
        Elem == "+" ->
            Stack = get("stack"),
            A = lists:last(Stack),
            ListaA = lists:droplast(Stack),
            B = lists:last(ListaA),
            ListaB = lists:droplast(ListaA),
            put("stack", ListaB ++ [rpc:call(get("soma"), soma, soma, [B, A])]);
        Elem == "-" ->
            Stack = get("stack"),
            A = lists:last(Stack),
            ListaA = lists:droplast(Stack),
            B = lists:last(ListaA),
            ListaB = lists:droplast(ListaA),
            put("stack", ListaB ++ [rpc:call(get("subtracao"), subtracao, subtracao, [B, A])]);
        Elem == "*" ->
            Stack = get("stack"),
            A = lists:last(Stack),
            ListaA = lists:droplast(Stack),
            B = lists:last(ListaA),
            ListaB = lists:droplast(ListaA),
            put("stack", ListaB ++ [rpc:call(get("multiplicacao"), multiplicacao, multiplicação, [B - A])]);
        Elem == "/" ->
            Stack = get("stack"),
            A = lists:last(Stack),
            ListaA = lists:droplast(Stack),
            B = lists:last(ListaA),
            ListaB = lists:droplast(ListaA),
            put("stack", ListaB ++ [rpc:call(get("divisao"), divisao, divisao, [B - A])]);
        true ->
            {Num, Error} = string:to_integer(Elem),
            put("stack", get("stack") ++ [Num])
    end.

evaluate([]) -> ok;
evaluate([H|T]) ->
    evaluate_aux(H),
    evaluate(T).

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

    put("stack", []),
    ENTRADA = p(read_input()),
    Entrada_f = split(ENTRADA, " ", all),
    evaluate(Entrada_f),
    io:write(get("stack")).