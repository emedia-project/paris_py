-module(paris_py).

-export([
  type/0,
  call/3
  ]).

type() -> controller.

call(Controller, Fun, Params) when is_atom(Controller), is_atom(Fun), is_list(Params) ->
  ok = application:ensure_started(paris_py),
  case get_controller_file(Controller) of
    {ok, ControllerFile} ->
      [_|ExtWithoutDot] = string:to_lower(filename:extension(ControllerFile)),
      case ExtWithoutDot of
        "py" -> execute_python_template(ControllerFile, Fun, Params);
        _ -> {error, "Not a python file"}
      end;
    _ -> {error, "Controller not found"}
  end.

execute_python_template(ScriptFile, Fun, Params) ->
  ModuleName = filename:basename(ScriptFile, ".py"),
  {ok, R} = python:start([{python_path, get_python_lib(ScriptFile)}]),
  try
    CallResult = python:call(R, list_to_atom(ModuleName), Fun, Params),
    {python:stop(R), CallResult}
  catch
    _:{python, ExceptionClass, Message, _} -> 
      python:stop(R), 
      {error, {python, ExceptionClass, Message}}
  end.

get_python_lib(ScriptFile) ->
  PrivPython = filename:join([paris:priv_dir(), "python"]),
  [
    filename:dirname(ScriptFile), 
    get_helper_path()
  ] ++ case filelib:is_dir(PrivPython) of
    true -> [PrivPython];
    false -> []
  end.

get_controller_file(Controller) ->
  ControllerMatch = efile:normalize_path(
      filename:join(
        [paris:priv_dir(), "..", "src", "controllers", atom_to_list(Controller) ++ ".*"])),
  case filelib:wildcard(ControllerMatch) of
    [ControllerFile|_] -> {ok, ControllerFile};
    _ -> {error, not_found}
  end.

get_helper_path() ->
  PrivDir = case code:priv_dir(paris_py) of
    {error, bad_name} ->
      Ebin = filename:dirname(code:which(?MODULE)),
      filename:join(filename:dirname(Ebin), "priv");
    Path -> Path
  end,
  filename:join([PrivDir, "helpers"]).

