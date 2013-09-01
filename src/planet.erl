-module(planet).

-export([use_genesis_device/1, death_star_it/1, raise_shields/1, ally_with/2, attack/2]).

-include("types.hrl").

-spec use_genesis_device(planet()) -> planet().
use_genesis_device(Planet) ->
  io:format("GENESIS PLANET ~p~n", [Planet]),
  Pid = spawn(fun() -> planet_loop(Planet, shields_down) end),
  register(Planet, Pid),
  Planet.

% Not required to unregister name; done when proces dies.
death_star_it(Planet) ->
  Pid = whereis(Planet),
  Pid ! fire_when_ready.

raise_shields(Planet) ->
  whereis(Planet) ! red_alert_raise_shields,
  ok.

ally_with(Planet, OtherPlanet) ->
  whereis(Planet) ! { ally_with, OtherPlanet },
  ok.

attack(Planet, Weapon) ->
  Pid = whereis(Planet),
  case Weapon of
    laser ->
      erlang:exit(Pid, Weapon);
    nuclear ->
      Pid ! nuclear_winter
  end,
  ok.

planet_loop(Planet, State) ->
  receive 
    red_alert_raise_shields ->
      process_flag(trap_exit, true),
      planet_loop(Planet, State);
    {'EXIT', _FromPid, _Reason} ->
      io:format("~p is attacked with lasers, but shields are holding~n", [Planet]),
      planet_loop(Planet, State);
    nuclear_winter ->
      io:format("Nuclear winter on ~p~n", [Planet]);
    {ally_with, OtherPlanet} ->
      link(whereis(OtherPlanet));
    Msg -> 
      io:format("UNKOWN MSG RECEIVED: ~p~n", [Msg]),
      planet_loop(Planet, State)
  end.

