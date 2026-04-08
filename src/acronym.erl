% Convert a phrase to its acronym.
% Techies love their TLA (Three Letter Acronyms)!
% Help generate some jargon by writing a program that converts a long name like Portable Network Graphics to its acronym (PNG).
% Punctuation is handled as follows: hyphens are word separators (like whitespace); all other punctuation can be removed from the input.

-module(acronym).
-export([run/1]).

printFirstLetter([]) ->
  io:fwrite("\n");
printFirstLetter([A | R]) ->
  FirstLetter = lists:nth(1, A),
  io:fwrite(string:to_upper([FirstLetter])),
  printFirstLetter(R).

splitPhrase("") ->
  [];
splitPhrase(Phrase) ->
  string:tokens(Phrase, " -").

run(Phrase) ->
  PhraseList = splitPhrase(Phrase),
  printFirstLetter(PhraseList).
