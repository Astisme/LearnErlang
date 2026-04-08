% Can every number find its way to 1? It was tied to something called the Collatz Conjecture, a puzzle that has baffled thinkers for decades.
% The rules were deceptively simple. Pick any positive integer.
%     If it's even, divide it by 2.
%     If it's odd, multiply it by 3 and add 1.
% Then, repeat these steps with the result, continuing indefinitely.
% Curious, you picked number 12 to test and began the journey:
% 12 ➜ 6 ➜ 3 ➜ 10 ➜ 5 ➜ 16 ➜ 8 ➜ 4 ➜ 2 ➜ 1
% Counting from the second number (6), it took 9 steps to reach 1, and each time the rules repeated, the number kept changing. At first, the sequence seemed unpredictable — jumping up, down, and all over. Yet, the conjecture claims that no matter the starting number, we'll always end at 1.

-module(collatz).

-export([run/1]).

write(1) ->
  io:fwrite("1\n");
write(N) ->
  io:fwrite(integer_to_list(N) ++ " -> ").

run(1) ->
  write(1);
run(N) when N rem 2 == 0 -> % even
  write(N),
  run(N div 2);
run(N) -> % odd
  write(N),
  run(3*N +1).
