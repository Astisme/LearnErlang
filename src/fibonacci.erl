-module(fibonacci).
%% print the fibonacci sequence up to the number specified
%% 0 -> 0, 1 -> 1, 2 -> 1, 3 -> 2, 4 -> 3, ...

-export([seq/1]).

fibon(A, _B, 0) ->
  A;
fibon(A, B, N) ->
  fibon(A+B, A, N-1).

call(N) ->
  fibon(0, 1, N).

seq(0) ->
  [call(0)];
seq(N) ->
  lists:append(seq(N-1), [call(N)]).
