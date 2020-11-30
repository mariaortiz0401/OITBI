% The polynomial mutation operator.
% Assuming an individual is a feasible solution (all decision variables are
% within their respective permissible range), the mutated individual will be
% feasible also. This is achieved by calculating the range of values for the
% random parameter u that guarantees the feasibility of the mutated individual,
% based on the decision variable values of the original individual in relation
% to the constraints for those variables.
%
% ARGUMENTS
%
% Indivs - individuals to be mutated
%   MxN array where M = number of decision variables and N = number of 
%   individuals
% Cons - constraints on the decision variables in the form of a permissible 
%   range for each variable.
%   MxN array where M = number of decision variables and N = 2 (1st column =
%   lower bound, 2nd column = upper bound).
%   something like [-inf inf] is allowed and means that there are no 
%   constraints on the respective decision variable
% pM - mutation probability (fraction of `genes', i.e., decision variable 
%   values that will be mutated where the pool of genes is made up of all
%   the individuals)
% etaM - distribution parameter for polynomial mutation (the larger, the 
%   closer will the mutated individual be, on average, to the original 
%   individual)
% maxM - maximum mutation magnitude, i.e., the maximum amount added or 
%   subtracted from a decision variable value due to mutation
%
% RETURN VALUES
%
% MIndivs - the mutated individuals
%   MxN array where M = number of decision variables and N = number of 
%   individuals

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
    
function MIndivs = NSGA_Mutate( Indivs, Cons, pM, etaM, maxM);

[nmbOfVars nmbOfIndivs] = size( Indivs);
% find violations of assumption that all individuals are feasible solutions
foo = repmat( Cons( :, 2), 1, nmbOfIndivs) - Indivs;
bar = Indivs - repmat( Cons( :, 1), 1, nmbOfIndivs);
if ismember( 1, [foo bar] < 0)
  error( 'NSGA_Mutate (prior to mutation): not all individuals are feasible solutions');
end

% randomly chose mutation direction; D == 0 (1) => negative (positive)
Dir = rand( size( Indivs)) > .5;
% for negative mutations, compute lower bounds for random parameter u
% zero is the lowest lower bound; .5 is the upper bound
U_low = max( 0, -bar ./ maxM + 1).^(etaM + 1) / 2;
% for positive mutations, compute upper bounds for random parameter u
% one is the maximum upper bound; .5 is the lower bound
U_up = 1 - max( 0, 1 - foo ./ maxM).^(etaM + 1) / 2;
% determine values for random parameter u
U = rand( size( Indivs));
U( ~Dir) = U_low( ~Dir) + (.5 - U_low( ~Dir)) .* U( ~Dir);
U( Dir) = .5 + (U_up( Dir) - .5) .* U( Dir);
% compute perturbance factor delta for negative mutations
DeltaNeg = (2 * U).^(1/(etaM + 1)) - 1;
% compute perturbance factor delta for positive mutations
DeltaPos = 1 - (2 * (1 - U)).^(1/(etaM + 1));
% combine cases
Delta = zeros( size( U));
Delta( ~Dir) = DeltaNeg( ~Dir);
Delta( Dir) = DeltaPos( Dir);
% mark `genes' (variables across all individuals) for mutation
% pM is the (fixed) fraction of genes that are mutated
M = randperm( prod( size( Indivs)));
M = M( 1:ceil( pM * length( M)));
% add perturbance factor times max. allowed mutation size to variables marked for mutation
MIndivs = Indivs;
MIndivs( M) = Indivs( M) + maxM * Delta( M);

foo = repmat( Cons( :, 2), 1, nmbOfIndivs) - MIndivs;
bar = MIndivs - repmat( Cons( :, 1), 1, nmbOfIndivs);
if ismember( 1, [foo bar] < 0)
  warning( sprintf( 'NSGA_SBX (after crossover): not all individuals are feasible solutions\n  largest violation is of size %g\n  small values are likely due to numeric instabilities and can be ignored\n since individuals will be forced within bounds ...', max( -[min( foo( :)) min( bar( :))])));
  MIndivs = min( repmat( Cons( :, 2), 1, nmbOfIndivs), MIndivs);
  MIndivs = max( repmat( Cons( :, 1), 1, nmbOfIndivs), MIndivs);
end
