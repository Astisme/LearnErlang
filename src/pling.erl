% Your task is to convert a number into its corresponding raindrop sounds.
% If a given number:
%     is divisible by 3, add "Pling" to the result.
%     is divisible by 5, add "Plang" to the result.
%     is divisible by 7, add "Plong" to the result.
%     is not divisible by 3, 5, or 7, the result should be the number as a string.

-module(pling).
-export([run/1]).

add(1, Res) ->
  Res;
add(N, Res) ->
  if
    N rem 3 == 0 -> 
      NN = N div 3,
      Result = Res ++ "Pling";
    N rem 5 == 0 -> 
      NN = N div 5,
      Result = Res ++ "Plang";
    N rem 7 == 0 -> 
      NN = N div 7,
      Result = Res ++ "Plong";
    true -> 
      NN = 1,
      Result = Res ++ integer_to_list(N)
  end,
  add(NN, Result).


run(N) ->
  add(N, "").
