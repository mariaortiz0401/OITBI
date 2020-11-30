% The NSGA-II multi-objective genetic algorithm w/ 
% simulated binary crossover (SBX) and polynomial mutation.
%
% ARGUMENTS
%
% nmbOfIndivs - number of individuals in each generation
% nmbOfGens - number of generations for the algorithm to run
% Fct - letter code identifying which set of objective functions to optimize
% Bounds - upper and lower bounds on the objective functions
% RandParams - parameters for the random initialization of the initial 
%   (zero-th) generation (see NSGA_ParentGen0.m)
% Cons - constraints on the decision variables in the form of a permissible 
%   range for each variable
% pX - crossover probability/fraction (see NSGA_SBX.m)
% etaX - distribution parameter for simulated binary crossover 
%   (SBX; see NSGA_SBX.m)
% pM - mutation probability/fraction (see NSGA_Mutate.m)
% etaM - distribution parameter for polynomial mutation (see NSGA_Mutate.m)
% maxM - maximum mutation magnitude (see NSGA_Mutate.m)
%
% RETURN VALUES
%
% ParGen - final (parent) generation
% ObjVals - objective function values for each individual of the final 
%   generation
% Ranking - ranks of the individuals of the final generation
% SumOfViols - sum of constraint violations for each individual of the 
%   final generation
% NmbOfFront - number of pareto-optimal front for each individual of the 
%   final generation

% Copyright (C) 2004 Reiner Schulz (rschulz@cs.umd.edu)
% This file is part of the author's Matlab implementation of the NSGA-II
% multi-objective genetic algorithm with simulated binary crossover (SBX)
% and polynomial mutation operators.
%
% The algorithm was developed by Kalyanmoy Deb et al. 
% For details, refer to the following article:
% Deb, K., Pratap, A., Agarwal, S., and Meyarivan, T. 
% A fast and elitist multiobjective genetic algorithm: NSGA-II.
% in IEEE TRANSACTIONS ON EVOLUTIONARY COMPUTATION, vol. 8, pp. 182-197, 2002
%
% This implementation is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This implementation is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with This implementation; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    
function [ParGen, ObjVals, Ranking, SumOfViols, NmbOfFront] = ...
  NSGA_II( nmbOfIndivs, nmbOfGens, Fct, Bounds, RandParams, Cons, ...
  pX, etaX, pM, etaM, maxM)

% create initial (parent) generation
ParGen = NSGA_ParentGen0( nmbOfIndivs, RandParams, Cons);

% evaluate initial generation
ObjVals = NSGA_Evaluate( ParGen, Cons, Fct);
% rank individuals of initial generation
[Ranking, SumOfViols, NmbOfFront, foo] = ...
  NSGA_Rank( ParGen, Bounds, Cons, ObjVals);

% repeat for given number of generations ...
for i = 1:nmbOfGens
    fprintf( 'generation %d\n', i);
  % create child generation
  [ChildGen foo] = NSGA_ChildGen( ...
    ParGen, Ranking, Cons, pX, etaX, pM, etaM, maxM);
 
    % append children to parents
  Par_ChildGen = [ParGen ChildGen];
  disp(Par_ChildGen)
  % append objective function values of the children to those of the parents
  ObjVals = [ObjVals NSGA_Evaluate( ChildGen, Cons, Fct)];
  % rank children and parents together
  [Ranking, SumOfViols, NmbOfFront, foo] = ...
    NSGA_Rank( Par_ChildGen, Bounds, Cons, ObjVals);
  % ranks of the parents
  
  ParRanking = Ranking( 1:nmbOfIndivs);
  % elite parents that will not be replaced by children
  ElitePars = find( ParRanking <= nmbOfIndivs);
  % non-elite parents that will be replaced by children
  NonElitePars = find( ParRanking > nmbOfIndivs);
  % ranks of the children
  ChildRanking = Ranking( (nmbOfIndivs + 1):end);
  % children that will replace worse parents
  BetterChildren = find( ChildRanking <= nmbOfIndivs);
%%% CHANGED this to keep indices in sync w/ underlying directory numbers
%  % make best ranked individuals the new parent generation
%  ParGen = Par_ChildGen( :, Ranking <= nmbOfIndivs);
%  % throw away objective function values, sums of constraint violations, numbers of
%  % Pareto-optimal fronts and, finally, the ranks of the other (worse) individuals
%  ObjVals = ObjVals( :, Ranking <= nmbOfIndivs);
%  SumOfViols = SumOfViols( Ranking <= nmbOfIndivs);
%  NmbOfFront = NmbOfFront( Ranking <= nmbOfIndivs);
%  Ranking = Ranking( Ranking <= nmbOfIndivs);
  % replace non-elite parents with better children
  ParGen( :, NonElitePars) = ChildGen( :, BetterChildren);
  % use the same type of `filling-in-the-gaps-between-elite-parents' for obj. val.s etc.
  % to keep indices in sync w/ run numbers
  ChildObjVals = ObjVals( :, (nmbOfIndivs + 1):end); % children
  ObjVals = ObjVals( :, 1:nmbOfIndivs); % parents
  ObjVals( :, NonElitePars) = ChildObjVals( :, BetterChildren); % replace non-elite parents
  ChildSumOfViols = SumOfViols( (nmbOfIndivs + 1):end); % children
  SumOfViols = SumOfViols( 1:nmbOfIndivs); % parents
  SumOfViols( NonElitePars) = ChildSumOfViols( BetterChildren); % replace non-elite parents
  ChildNmbOfFront = NmbOfFront( (nmbOfIndivs + 1):end); % children
  NmbOfFront = NmbOfFront( 1:nmbOfIndivs); % parents
  NmbOfFront( NonElitePars) = ChildNmbOfFront( BetterChildren); % replace non-elite parents
  % have ChildRanking already
  Ranking = ParRanking; % parents
  Ranking( NonElitePars) = ChildRanking( BetterChildren); % replace non-elite parents

end
