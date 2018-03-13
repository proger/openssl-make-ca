-module(httpsd).
-compile(export_all).

start() ->
    ok = ssl:start(),
    ok = inets:start(),
    Cacertfile = get_argument(cacertfile, throw),
    Port = to_integer(get_argument(port, "8080")),
    SSL = [{certfile, get_argument(certfile, throw)},
           {keyfile, get_argument(keyfile, throw)},
           {cacertfile, Cacertfile}],
    Args = [{port, Port},
            {server_name,"httpsd"},
            {server_root,"."},
            {document_root,"."},
            {bind_address, "0.0.0.0"},
            {socket_type, {essl, SSL}},
            {modules, [mod_dir, mod_get, mod_range, mod_head, mod_alias]},
            {mime_types,[{"html","text/html"},
                         {"css","text/css"},
                         {"js","application/x-javascript"}]}],
    {ok, _Pid} = inets:start(httpd, Args),

    timer:apply_after(2000, io, format, ["curl -v --cacert ~p https://localhost:~p/README.md~n", [Cacertfile, Port]]).


to_integer(X) -> {I, _} = string:to_integer(X), I.

get_argument(Flag, Default) ->
    case init:get_argument(Flag) of
        error -> case Default of
                     throw -> throw({missing_argument, Flag});
                     _ -> Default end;
        {ok, [[A|_]|_]} -> A
    end.
