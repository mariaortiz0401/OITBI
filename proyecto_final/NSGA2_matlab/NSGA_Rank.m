% Ranks the individuals according to their degree of constraint violation 
% (1st sort key), the number of their Pareto-optimal front (2nd sort key) 
% and the degree to which they are `crowded' by other individuals 
% (3rd sort key).
%
% ARGUMENTS
%
% Indivs - individuals to be ranked
%   MxN array where M = number of decision variables and N = number of 
%   individuals
% Bounds - upper and lower bounds on the objective functions
%   Mx2 array where M = number of objectives; 1st column = lower bound; 
%   2nd column = upper bound; this is used for normalizing crowding distances 
%   so that if the true bounds are unknown, a range of [0 1] can be chosen 
%   which corresponds to no normalization taking place.
% Cons - constraints on the decision variables in the form of a permissible 
%   range for each variable.
%   MxN array where M = number of decision variables and N = 2 (1st column =
%   lower bound, 2nd column = upper bound).
%   something like [-inf inf] is allowed and means that there are no 
%   constraints on the respective decision variable
% ObjVals - objective function values for each individuals.
%   MxN array where M = number of decision variables and N = number of 
%   individuals
%
% RETURN VALUES
%
% Ranking - the rank for each individual
% SumOfViols - sum of constraint violations for each individual
% NmbOfFront - number of pareto-optimal front for each individual
% CrowdDist - crowding distance for each individuals
% 
% all of the above return values are 1D arrays of length = number of 
% individuals

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
    
function [Ranking, SumOfViols, NmbOfFront, CrowdDist] = ...
  NSGA_Rank( Indivs, Bounds, Cons, ObjVals);

[nmbOfVars nmbOfIndivs] = size( Indivs);
[nmbOfObjs foo] = size( ObjVals);

% sum of absolute constraint violations for each individual; highest priority sorting key
SumOfViols = sum( ...
  abs( min( 0, Indivs - repmat( Cons( :, 1), 1, nmbOfIndivs))) + ...
  abs( max( 0, Indivs - repmat( Cons( :, 2), 1, nmbOfIndivs))), 1)';

% Pareto-optimal fronts
Front = {[]};
% number of Pareto-optimal front for each individual; 2nd highest priority sorting key
NmbOfFront = zeros( nmbOfIndivs, 1);
% set of individuals a particular individual dominates
Dominated = cell( nmbOfIndivs, 1);
% number of individuals by which a particular individual is dominated
NmbOfDominating = zeros( nmbOfIndivs, 1);
for p = 1:nmbOfIndivs
  for q = 1:nmbOfIndivs
    if (sum( ObjVals( :, p) <= ObjVals( :, q)) == nmbOfObjs) & ...
      (sum( ObjVals( :, p) < ObjVals( :, q)) > 0)
      Dominated{ p}(end + 1) = q;
    elseif (sum( ObjVals( :, q) <= ObjVals( :, p)) == nmbOfObjs) & ...
      (sum( ObjVals( :, q) < ObjVals( :, p)) > 0)
      NmbOfDominating( p) = NmbOfDominating( p) + 1;
    end
  end
  if NmbOfDominating( p) == 0
    NmbOfFront( p) = 1;
    Front{ 1}(end + 1) = p;
  end
end
i = 1;
while ~isempty( Front{ i})
  NextFront = [];
  for k = 1:length( Front{ i})
    p = Front{ i}( k);
    for l = 1:length( Dominated{ p})
      q = Dominated{ p}( l);
      NmbOfDominating( q) = NmbOfDominating( q) - 1;
      if NmbOfDominating( q) == 0
	NmbOfFront( q) = i + 1;
	NextFront( end + 1) = q;
      end
    end
  end
  i = i + 1;
  Front{ end + 1} = NextFront;
end
      
% crowding distance for each individual; 3rd highest priority sorting key
CrowdDist = zeros( nmbOfIndivs, 1);
for i = 1:nmbOfObjs
  [ObjValsSorted SortIdx] = sort( ObjVals( i, :));
  % individuals w/ extreme objective function values are assigned a negative
  % infinite crowding distance so that their rank is always lower than the rank
  % of other individuals which are otherwise of the same rank (same degree of
  % constraint violation; same Pareto-Front)
  CrowdDist( SortIdx( 1)) = -inf;
  CrowdDist( SortIdx( nmbOfIndivs)) = -inf;
  for j = 2:(nmbOfIndivs - 1)
    %%% introduced normalization by the absolute range of the 
    %%% objective function; a range of [0 1] is equivalent to no normalization
    % add negative of the distance between the nearest other two individuals
    % to the overall crowding distance
      CrowdDist( SortIdx( j)) = CrowdDist( SortIdx( j)) - ...
      (ObjValsSorted( j + 1) - ObjValsSorted( j - 1)) / ...
      (Bounds( i, 2) - Bounds( i, 1));
  end
end

% rank of each individual
[foo SortIdx] = sortrows( [SumOfViols NmbOfFront CrowdDist]);
Ranking = zeros( nmbOfIndivs, 1);
for i = 1:nmbOfIndivs
  Ranking( i) = find( SortIdx == i);
end
