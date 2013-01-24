%% -----------------------------------------------------------------------------
%%
%% Hamcrest Erlang.
%%
%% Copyright (c) 2013 Tim Watson (watson.timothy@gmail.com)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% -----------------------------------------------------------------------------
%% @author Tim Watson <watson.timothy@gmail.com>
%% @copyright 2000 - 2013 Tim Watson.
%% @doc Rebar Dependency Inheritance Plugin
%% -----------------------------------------------------------------------------
-module(rebar_inheritable_deps).

-type name()       :: atom().
-type version()    :: string().
-type scm()        :: atom().
-type location()   :: string().
-type rev()        :: {atom(), string()} |
                      string().
-type source()     :: {scm(), location()} |
                      {scm(), location(), rev()} |
                      'undefined'.
-type dependency() :: {name(), version(), source()}.

-record(state, {
    recorded :: [dependency()]
}).

-define(CONFIG_KEY, ?MODULE).

-export([preprocess/2]).
         %% 'pre_get-deps'/2,
         %% 'pre_check-deps'/2,
         %% 'pre_list-deps'/2]).

preprocess(Config, _) ->
    Deps = get_deps(Config),
    Config2 = set_state(Deps, Config),
    {ok, Config2, []}.

get_deps(Config) ->
    rebar_config:get_local(Config, deps, []).

set_state([],   Config) ->
    Config;
set_state(Deps, Config) ->
    State = get_state(Config),
    Updated = apply_overrides(Deps, State),
    NewState = State#state{ recorded=Updated },
    Config2 = rebar_config:set_xconf(Config, ?CONFIG_KEY, NewState),
    rebar_config:set(Config2, deps, Updated).

%% If a dependency is 'known' then ignore the supplied version,
%% otherwise append it to the list of 'known' dependencies.
%% Once a dependency is 'known', it will override subsequent
%% declarations, whether they're child *or* sibling nodes of
%% the current working directory.
apply_overrides(Deps, State) ->
    lists:foldl(fun(E={App, _, _}, Acc) ->
                        case lists:keymember(App, 1, Acc) of
                            true  -> Acc;
                            false -> log_replace(E), [E|Acc]
                        end
                end, State#state.recorded, Deps).

log_replace(E) ->
    rebar_log:log(debug, "ignore/override dependency ~p~n", [E]).

get_state(Config) ->
    rebar_config:get_xconf(Config, ?CONFIG_KEY, new_state()).

new_state() -> #state{ recorded = [] }.

