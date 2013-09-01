%% @doc
%% Implementation module for the galactic battle simulator.
%% The following example shows the expected behavior of the simulator:
%%
%% Planets=[mercury,uranus,venus, earth]
%% Shields=[mercury,uranus]
%% Alliances=[{mercury, uranus}, {venus, earth}]
%% Actions=[{nuclear,mercury},{laser,venus}, {laser, uranus}]
%%
%% ExpectedSurvivors = [uranus]
%% In order to produce this expected results, the following calls will be tested:
%% * ok = setup_universe(Planets, Shields, Alliances)
%% * [uranus] = simulate_attack(Planets, Actions)
%% * ok = teardown_universe(Planets)
%%
%% All the 3 calls will be tested in order to check they produce the expected
%% side effects (setup_universe/3 creates a process per planet, etc)
%% @end

-module(galaxy_game).

-include_lib("eunit/include/eunit.hrl").
-include("types.hrl").

-export([setup_universe/3, teardown_universe/1, simulate_attack/2]).

%% @doc Set up a universe described by the input.
%% The imput is asumed to be minimal and non redundant (i.e. if there is an
%% alliance {a, b} there won't be an alliance {b, a}).
%% Once this function returns, the universe is expected to be fully ready,
%% shields, alliances and all.
-spec setup_universe([planet()], [shield()], [alliance()]) -> ok.
%% @end
setup_universe(Planets, Shields, Alliances) ->
  % Create planets
  lists:foreach(fun(Planet) ->
    planet:use_genesis_device(Planet)
  end, Planets),
  % Add shields to planets
  lists:foreach(fun(ShieldedPlanet) ->
    planet:raise_shields(ShieldedPlanet)
  end, Shields),
  % Forge alliances.
  lists:foreach(fun({Planet, OtherPlanet}) ->
    planet:ally_with(Planet, OtherPlanet)
  end, Alliances),
  ok.

%% @doc Clean up a universe simulation.
%% This function will only be called after calling setup_universe/3 with the
%% same set of planets.
%% Once this function returns, all the processes spawned by the simulation
%% should be gone.
-spec teardown_universe([planet()]) -> ok.
%% @end
teardown_universe(Planets) ->
  lists:foreach(fun(Planet) ->
    planet:death_star_it(Planet)
  end, Planets),
  ok.

%% @doc Simulate an attack.
%% This function will only be called after setting up a universe with the same
%% set of planets.
%% It returns the list of planets that have survived the attack
-spec simulate_attack([planet()], [attack()]) -> Survivors::[planet()].
%% @end
simulate_attack(Planets, Actions) ->
  lists:foreach(fun({Weapon, Planet}) ->
    planet:attack(Planet, Weapon)
  end, Actions),
  lists:filter(fun(Planet) ->
    whereis(Planet) /= undefined
  end, Planets).
