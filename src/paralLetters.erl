% Count the frequency of letters in texts using parallel computation.
% Parallelism is about doing things in parallel that can also be done sequentially. A common example is counting the frequency of letters. Employ parallelism to calculate the total frequency of each letter in a list of texts.


-module(paralLetters).
-export([run/1, count/2]).

countFromMap([], LettersMap) ->
  LettersMap;
countFromMap([FirstLetter | Rest], LettersMap) ->
  NewMap = case maps:get(FirstLetter, LettersMap, undefined) of
    undefined ->
      maps:put(FirstLetter, 1, LettersMap);
    Value ->
      maps:update(FirstLetter, Value + 1, LettersMap)
  end,
  countFromMap(Rest, NewMap).

count(Text, Pid) ->
  Pid ! countFromMap(Text, #{}).


printKeyValues([], _) ->
  io:fwrite("-----\n");
printKeyValues([Key | Rest], Map) ->
  Value = maps:get(Key, Map),
  io:fwrite([Key] ++" -> "++ integer_to_list(Value) ++"\n"),
  printKeyValues(Rest, Map).

printMapValues(Map) ->
  case maps:keys(Map) of
    [] -> ok;
    Keys ->
      printKeyValues(Keys, Map)
  end.

listen() ->
  receive
    Map -> 
      printMapValues(Map)
  end.

run([]) ->
  done;
run([TextList | Rest]) ->
  spawn(paralLetters, count, [TextList, self()]),
  listen(),
  run(Rest).
