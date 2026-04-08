% If you know the person's name (e.g. if they're named Do-yun), then you will say:
% One for Do-yun, one for me.
% If you don't know the person's name, you will say you instead.
% One for you, one for me.

-module(twofer).

-export([run/1, run/0]).

write(A) ->
  "One for "++A++", one for me.".

run() ->
  run("").

run("") ->
  write("you");
run(A) ->
  write(A).
