% Breath First Search


-module(bfs).
-export([run/0, run/1]).


%%% list of visited nodes in BFS order
bfs(Graph, StartNode) ->
    Visited = sets:new(),       %% empty set to track visited nodes
    Queue = queue:in(StartNode, queue:new()), %% empty queue to process nodes
    bfs_loop(Graph, Queue, Visited, []).

enqueueList([], Queue) ->
  Queue;
enqueueList([First | Rest], Queue) ->
  NewQueue = queue:in(First, Queue),
  enqueueList(Rest, NewQueue).

%%% final BFS order
bfs_loop(Graph, Queue, Visited, Acc) ->
  case queue:out(Queue) of
    {empty, _} ->
      lists:reverse(Acc);  %% finished, return accumulated BFS order
    {{value, Node}, QueueRest} ->
      %% check if Node is visited
      case sets:is_element(Node, Visited) of
        false ->
          %% add Node to visited
          NewVisited = sets:add_element(Node, Visited),
          NewAcc = [Node | Acc],
          %% enqueue neighbors
          NewQueue = enqueueList(
                        maps:get(Node, Graph),
                        QueueRest
                       ),
          %% recursive call with updated Queue, Visited, and Acc
          bfs_loop(Graph, NewQueue, NewVisited, NewAcc);
        true ->
          bfs_loop(Graph, QueueRest, Visited, Acc)
      end
  end.


checkEndpointsAvailable(Graph, From) ->
  Keys = maps:keys(Graph),
  lists:member(From, Keys).


run({Graph, From}) ->
  if
    not is_map(Graph) -> "ko, did not send a graph";
    true ->
      case checkEndpointsAvailable(Graph, From) of
        true ->
          bfs(Graph, From);
        false -> "ko, endpoint not in graph"
      end
  end;
run(Atom) when is_atom(Atom) ->
  run({getGraph(), Atom}).

getGraph() ->
   #{
      a => [b, c],
      b => [e, d],
      c => [e],
      d => [e, f],
      e => [b, d],
      f => [b]
    }.

run() ->
  % run with standard Graph
  run({getGraph(), a}).
