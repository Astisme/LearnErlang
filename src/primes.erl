% Compute the prime factors of a given natural number.
% A prime number is only evenly divisible by itself and 1.
% Note that 1 is not a prime number.

-module(primes).
-export([run/1, divide/2, print/0]).


print() ->
  receive
    D -> io:fwrite(integer_to_list(D)++"\n")
  end,
  print().


%divide(_N, _D) when _N == _D ->
divide(N, D) when N == D ->
  print ! D;
divide(N, D) ->
  if
    N rem D == 0 -> 
      print ! D,
      divide(N div D, D);
    true -> divide(N, D+1)
  end.


run(1) ->
  1;
run(N) when N < 1 ->
  error;
run(N) ->
  register(divide, spawn(primes, divide, [N, 2])),
  register(print, spawn(primes, print, [])),
  registered.
