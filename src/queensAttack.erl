% Given the position of two queens on a chess board, indicate whether or not they are positioned so that they can attack each other.
% In the game of chess, a queen can attack pieces which are on the same row, column, or diagonal.
% A chessboard can be represented by an 8 by 8 array.
% So if you are told the white queen is at c5 (zero-indexed at column 2, row 3) and the black queen at f2 (zero-indexed at column 5, row 6), then you know that the set-up is like
% You are also able to answer whether the queens can attack each other. In this case, that answer would be yes, they can, because both pieces share a diagonal.
%   0 1 2 3 4 5 6 7
%   a b c d e f g h
% 7 8
% 6 7
% 5 6
% 4 5     x
% 3 4
% 2 3
% 1 2           x
% 0 1

-module(queensAttack).
-export([run/2]).

printRow([]) ->
    io:fwrite("~n");
printRow([Cell | Rest]) ->
    io:fwrite("~p ", [Cell]),
    printRow(Rest).

printBoard([]) ->
  done;
printBoard([Row | Rest]) ->
  printRow(Row),
  printBoard(Rest).

makeBoard() ->
  [
   [e, e, e, e, e, e, e, e],
   [e, e, e, e, e, e, e, e],
   [e, e, e, e, e, e, e, e],
   [e, e, e, e, e, e, e, e],
   [e, e, e, e, e, e, e, e],
   [e, e, e, e, e, e, e, e],
   [e, e, e, e, e, e, e, e],
   [e, e, e, e, e, e, e, e]
  ].

replace(List, Index, Value) ->
    lists:sublist(List, Index-1) ++ [Value] ++ lists:nthtail(Index, List).

placeQueens(Board, []) ->
  Board;
placeQueens(Board, [QMap | R]) ->
    Col = maps:get(col, QMap),
    Row = maps:get(row, QMap),
    ColumnList = lists:nth(Col, Board),
    NewCol = replace(ColumnList, Row, q),
    NewBoard = replace(Board, Col, NewCol),
    placeQueens(NewBoard, R).

placeQueens(Queens) ->
  placeQueens(makeBoard(), Queens).

getQueenColRow(Q) ->
    [Col, Row] = Q,
    ColIndex = Col - $a +1,
    RowIndex = Row - $0,
    #{
      col => ColIndex,
      row => RowIndex
     }.

run(Q1, Q2) ->
  Q1Map = getQueenColRow(Q1),
  Q2Map = getQueenColRow(Q2),
  Col1 = maps:get(col, Q1Map),
  Row1 = maps:get(row, Q1Map),
  Col2 = maps:get(col, Q2Map),
  Row2 = maps:get(row, Q2Map),
  Attack = (
    (Col1 == Col2) or % vertical attack
    (Row1 == Row2) or % horizontal attack
    (abs(Col1 - Col2) == abs(Row1 - Row2)) % diagonal attack
   ),
  Board = placeQueens([Q1Map, Q2Map]),
  printBoard(Board),
  Attack.
