-module(cron_ffi).

-export([unix/0]).

unix() ->
  os:system_time(seconds).
