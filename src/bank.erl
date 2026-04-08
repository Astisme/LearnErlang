% Introduction
% After years of filling out forms and waiting, you've finally acquired your banking license. This means you are now officially eligible to open your own bank, hurray!
% Your first priority is to get the IT systems up and running. After a day of hard work, you can already open and close accounts, as well as handle withdrawals and deposits.
% Since you couldn't be bothered writing tests, you invite some friends to help test the system. However, after just five minutes, one of your friends claims they've lost money! While you're confident your code is bug-free, you start looking through the logs to investigate.
% Ah yes, just as you suspected, your friend is at fault! They shared their test credentials with another friend, and together they conspired to make deposits and withdrawals from the same account in parallel. Who would do such a thing?
% While you argue that it's physically impossible for someone to access their account in parallel, your friend smugly notifies you that the banking rules require you to support this. Thus, no parallel banking support, no go-live signal. Sighing, you create a mental note to work on this tomorrow. This will set your launch date back at least one more day, but well...
%
% Instructions
% Your task is to implement bank accounts supporting opening/closing, withdrawals, and deposits of money.
% As bank accounts can be accessed in many different ways (internet, mobile phones, automatic charges), your bank software must allow accounts to be safely accessed from multiple threads/processes (terminology depends on your programming language) in parallel. For example, there may be many deposits and withdrawals occurring in parallel; you need to ensure there are no race conditions between when you read the account balance and set the new balance.
% It should be possible to close an account; operations against a closed account must fail.

-module(bank).
-export([start/0, account/2, loop/1]).

%% @doc Starts the bank process and registers it.
start() ->
    case whereis(bank) of
        undefined -> ok;
        _ -> unregister(bank)
    end,
    register(bank, spawn(bank, loop, [#{}])).

%% @doc Updates a single field in a nested map entry identified by Key.
updateSingleInMap(Key, Field, Value, Accounts) ->
    Existing = maps:get(Key, Accounts),
    maps:update(Key, maps:update(Field, Value, Existing), Accounts).

getAccount(Name, Accounts) ->
    Existing = maps:get(Name, Accounts, undefined),
    case Existing of
        undefined ->
            {{ko, "Account "++Name++" does not exist"}, Accounts};
        #{status := closed} ->
            {{ko, "Account is closed"}, Accounts};
        _ ->
            {{ok, Existing}, Accounts}
    end.

openAccount(Name, Accounts) ->
    case getAccount(Name, Accounts) of
        {{ko, "Account is closed"}, _A1} ->
            {{ok, "Account "++Name++" reopened"}, updateSingleInMap(Name, status, open, Accounts)};
        {{ko, _R}, _A2} ->
            {{ok, "Account "++Name++" created"}, maps:put(Name, #{name => Name, status => open, balance => 0}, Accounts)};
        {{ok, _Existing}, _A} ->
            {{ko, "Account "++Name++" is already open"}, Accounts}
    end.

closeAccount(Name, Accounts) ->
    case getAccount(Name, Accounts) of
        {{ko, R}, A} -> {{ko, R}, A};
        {{ok, _Existing}, _A} ->
            {{ok, "Account "++Name++" closed"}, updateSingleInMap(Name, status, closed, Accounts)}
    end.

deposit(Name, Amount, Accounts) ->
    case getAccount(Name, Accounts) of
        {{ko, R}, A} -> {{ko, R}, A};
        {{ok, Existing}, _A} ->
            Balance = maps:get(balance, Existing, 0),
            NewBalance = Balance + Amount,
            {{ok, NewBalance}, updateSingleInMap(Name, balance, NewBalance, Accounts)}
    end.

withdraw(Name, Amount, Accounts) ->
    case getAccount(Name, Accounts) of
        {{ko, R}, A} -> {{ko, R}, A};
        {{ok, Existing}, _A} ->
            Balance = maps:get(balance, Existing, 0),
            if
              Balance < Amount -> {{ko, "Amount exceeds Balance"}, Accounts};
              true ->
                NewBalance = Balance - Amount,
                {{ok, NewBalance}, updateSingleInMap(Name, balance, NewBalance, Accounts)}
            end
    end.

sendAmount(NameFrom, NameTo, Amount, Accounts) ->
    case getAccount(NameFrom, Accounts) of
        {{ko, R}, A} -> {{ko, R}, A};
        {{ok, _ExistingFrom}, _A1} ->
          case getAccount(NameTo, Accounts) of
              {{ko, R}, A} -> {{ko, R}, A};
              {{ok, _ExistingTo}, _A2} ->
                case withdraw(NameFrom, Amount, Accounts) of
                  {{ko, R}, N} -> {{ko, R}, N};
                  {_R, MiddleAccounts} ->
                    deposit(NameTo, Amount, MiddleAccounts)
                end
          end
    end.

%% @doc Main loop holding the accounts state.
loop(Accounts) ->
  {Result, NewAccounts, FromPid} = receive
        {get, Name, From} ->
            {R, N} = getAccount(Name, Accounts),
            {R, N, From};
        {open, Name, From} ->
            {R, N} = openAccount(Name, Accounts),
            {R, N, From};
        {close, Name, From} ->
            {R, N} = closeAccount(Name, Accounts),
            {R, N, From};
        {withdraw, Name, Amount, From} ->
            {R, N} = withdraw(Name, Amount, Accounts),
            {R, N, From};
        {deposit, Name, Amount, From} ->
            {R, N} = deposit(Name, Amount, Accounts),
            {R, N, From};
        {send, NameFrom, NameTo, Amount, From} -> 
            {R, N} = sendAmount(NameFrom, NameTo, Amount, Accounts),
            {R, N, From}
    end,
    FromPid ! Result,
    loop(NewAccounts).

error_missing_name() ->
  io:fwrite("Please provide a valid name\n").

receive_messages() ->
  receive
    N -> N
  end.

%% @doc Opens a new account for Name.
open_account("") ->
  error_missing_name();
open_account(Name) ->
  bank ! {open, Name, self()},
  receive_messages().

%% @doc Closes the account for Name.
close_account("") ->
  error_missing_name();
close_account(Name) ->
  bank ! {close, Name, self()},
  receive_messages().

get_account("") ->
  error_missing_name();
get_account(Name) ->
  bank ! {get, Name, self()},
  receive_messages().

withdraw_bank(Name, Amount) ->
  bank ! {withdraw, Name, Amount, self()},
  receive_messages().

withdraw_from(_Name, Amount) when Amount =< 0 ->
  io:fwrite("Cannot withdraw 0 or less\n");
withdraw_from("", _Amount) ->
  error_missing_name();
withdraw_from(Name, Amount) ->
  Account = get_account(Name), % check that the Account exists
  if
    Account == ko -> io:fwrite("Account "++Name++" does not exist\n");
    true ->
      withdraw_bank(Name, Amount)
  end.

deposit_bank(Name, Amount) ->
  bank ! {deposit, Name, Amount, self()},
  receive_messages().

deposit_to(_Name, Amount) when Amount =< 0 ->
  io:fwrite("Cannot deposit 0 or less\n");
deposit_to("", _Amount) ->
  error_missing_name();
deposit_to(Name, Amount) ->
  Account = get_account(Name),
  if
    Account == ko -> io:fwrite("Account "++Name++" does not exist\n");
    true ->
      deposit_bank(Name, Amount)
  end.

send_bank(NameFrom, NameTo, Amount) ->
  bank ! {send, NameFrom, NameTo, Amount, self()},
  receive_messages().

send_to(_NameFrom, _NameTo, Amount) when Amount =< 0 ->
  io:fwrite("Cannot send 0 or less\n");
send_to(NameFrom, NameTo, _Amount) when NameFrom == "" orelse NameTo == "" ->
  error_missing_name();
send_to(NameFrom, NameTo, Amount) ->
  send_bank(NameFrom, NameTo, Amount).

account(open, Name) ->
  open_account(Name);
account(close, Name) ->
  close_account(Name);
account(get, Name) ->
  get_account(Name);
account(withdraw, { Name, Amount }) ->
  withdraw_from(Name, Amount);
account(deposit, { Name, Amount }) ->
  deposit_to(Name, Amount);
account(send, { NameFrom, NameTo, Amount }) ->
  send_to(NameFrom, NameTo, Amount).
