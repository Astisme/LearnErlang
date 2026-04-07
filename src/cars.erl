-module(cars).

-export([listPrices/1]).


convertPriceTo(Price, Currency) ->
  case Currency of
    eur -> round(2.0*Price);
    gbp -> round(0.5*Price);
    usd -> Price
  end.

getConvertedPrices(CarPrices, Currency, []) ->
  true;
getConvertedPrices(CarPrices, Currency, [CarKey | Rest]) ->
  io:fwrite("Price for "++CarKey++" "++integer_to_list(convertPriceTo(maps:get(CarKey, CarPrices, 0), Currency))++"\n"),
  getConvertedPrices(CarPrices, Currency, Rest).

listPrices(Currency) ->
  %% Prices in $
  CarPrices = #{"bmw" => 150000, "lamb" => 500000, "ferr" => 700000},
  getConvertedPrices(CarPrices, Currency, maps:keys(CarPrices)).
