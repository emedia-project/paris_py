-module(plugin_sample).

-export([start/0]).

start() ->
  {ok, _} = application:ensure_all_started(lager),
  {ok, _} = application:ensure_all_started(cowboy),
  ok = application:start(mimetypes),
  ok = application:start(plugin_sample).
