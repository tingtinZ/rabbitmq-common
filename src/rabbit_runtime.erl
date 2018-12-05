%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2007-2018 Pivotal Software, Inc.  All rights reserved.
%%

%% This module provides access to runtime metrics that are exposed
%% via CLI tools, management UI or otherwise used by the broker.

-module(rabbit_runtime).

%%
%% API
%%

-export([guess_number_of_cpu_cores/0, get_gc_info/1, msacc_stats/1]).


-spec guess_number_of_cpu_cores() -> pos_integer().
guess_number_of_cpu_cores() ->
    case erlang:system_info(logical_processors_available) of
        unknown -> % Happens on Mac OS X.
            erlang:system_info(schedulers);
        N -> N
    end.

-spec get_gc_info(pid()) -> nonempty_list(tuple()).
get_gc_info(Pid) ->
    {garbage_collection, GC} = erlang:process_info(Pid, garbage_collection),
    case proplists:get_value(max_heap_size, GC) of
        I when is_integer(I) ->
            GC;
        undefined ->
            GC;
        Map ->
            lists:keyreplace(max_heap_size, 1, GC,
                             {max_heap_size, maps:get(size, Map)})
    end.

-spec msacc_stats(integer()) -> nonempty_list(#{atom() => any()}).
msacc_stats(TimeInMs) ->
    msacc:start(TimeInMs),
    msacc:stats().
