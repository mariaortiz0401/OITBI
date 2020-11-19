% Creates a new generation from pairs of parent individuals selected from
% the parent generation. A set fraction of the `genomes' of the parents undergo
% decision-variable-wise simulated binary crossover (SBX).
% Assuming the two parent individuals are feasible solution (all decision 
% variables are within their respective permissible range), the individuals
% resulting from a crossover between the parents' genome will be feasible also. 
% This is achieved by calculating the range of values for the
% random parameter u that guarantees the feasibility of the offspring,
% based on the decision variable values of the parent individuals in relation
% to the constraints for those variables.
%
% ARGUMENTS
%
% Indivs - parent generation
%   MxN array where M = number of decision variables and N = number of 
%   individuals
% Cons - constraints on the decision variables in the form of a permissible 
%   range for each variable.
%   MxN array where M = number of decision variables and N = 2 (1st column =
%   lower bound, 2nd column = upper bound).
%   something like [-inf inf] is allowed and means that there are no 
%   constraints on the respective decision variable
% Pars - the pair of parents for each prospective child individual
%   Mx2 array where M = number of individuals; contains indices into 'Indivs'
% pX - crossover probability, i.e., the fraction of parent pairs that undergo 
%   crossover
% etaX - distribution parameter for simulated binary crossover (the larger, 
%   the closer the offspring individuals will be, on average, to their parent 
%   individuals)
%
% RETURN VALUES
%
% XIndivs - the new generation
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
    
function XIndivs = NSGA_SBX( Indivs, Cons, Pars, pX, etaX)
[nmbOfVars nmbOfIndivs] = size( Indivs);
if rem( nmbOfIndivs, 2) ~= 0
  warning( 'Number of individuals is ODD ?!');
end
[nmbOfPairs foo] = size( Pars);
if nmbOfPairs ~= floor( nmbOfIndivs / 2)
  warning( 'Number of pairs of parent individuals is NOT half the number of all individuals ?!');
end

% find violations of assumption that all individuals are feasible solutions
foo = repmat( Cons( :, 2), 1, nmbOfIndivs) - Indivs;
bar = Indivs - repmat( Cons( :, 1), 1, nmbOfIndivs);
if ismember( 1, [foo bar] < 0)
  error( 'NSGA_SBX (prior to crossover): not all individuals are feasible solutions');
end

% mark parent pairs for crossover
% pX is the (fixed) fraction of parent pairs that undergo crossover
X = randperm( nmbOfPairs);
X = X( 1:ceil( pX * length( X)));
% for now, pretend all pairs undergo crossover
% randomly chose crossover direction; D == 0 (1) => contracting (expanding)
Dir = rand( [nmbOfVars nmbOfPairs]) > .5;
% for now, pretend all crossovers are expanding
% find variable pairs (p,q) that need to be swapped because p >= q
ParP = Indivs( :, Pars( :, 1));
ParQ = Indivs( :, Pars( :, 2));
Swap = ParP >= ParQ;
% swap them
Temp = ParP;
ParP( Swap) = ParQ( Swap);
ParQ( Swap) = Temp( Swap);
%EqTst = find( EqTst( :));
%for i = 1:length( EqTst)
%  [var par] = ind2sub( size( ParP), EqTst( i));
%  warning( sprintf( 'parent pair %d agrees on variable %d', par, var));
%end
%EqTst = find( ismember( ParP', ParQ', 'rows'));
%for i = 1:length( EqTst)
%  warning( sprintf( 'parents in pair %d are identical', EqTst( i)));
%end
warning off
% compute upper bounds of u for 1st children (left of ParP)
U_up1st = 1 - 1 ./ (2 * ((2 * repmat( Cons( :, 1), 1, nmbOfPairs) ...
  - ParP - ParQ) ./ (ParP - ParQ)).^(etaX + 1));
% compute upper bounds of u for 2nd children (right of ParQ)
U_up2nd = 1 - 1 ./ (2 * ((2 * repmat( Cons( :, 2), 1, nmbOfPairs) ...
  - ParP - ParQ) ./ (ParQ - ParP)).^(etaX + 1));
warning on
% test for equality of parent variables to clean up results of divisions by zero
EqTst = ParP == ParQ;
U_up1st( EqTst) = 1;
U_up2nd( EqTst) = 1;
% determine values for random parameter u
% first, the simple case of contracting crossover where u in [0, .5]
U_contract = .5 * rand( nmbOfVars, nmbOfPairs);
% next, expanding crossover
% use same but differenly scaled u for both children
Temp = rand( nmbOfVars, nmbOfPairs); 
% 1st children where u in [.5, U_up1st]
U_expand1st = .5 + (U_up1st - .5) .* Temp;
% 2nd children where u in [.5, U_up2nd]
U_expand2nd = .5 + (U_up2nd - .5) .* Temp;
% compute parameter beta
Beta_contract = (2 * U_contract).^(1/(etaX + 1));
Beta_expand1st = (1./(2 * (1 - U_expand1st))).^(1/(etaX + 1));
Beta_expand2nd = (1./(2 * (1 - U_expand2nd))).^(1/(etaX + 1));
% create children
% first, via contracting crossover
ChildA_contract = .5 * ((1 + Beta_contract) .* ParP ...
  + (1 - Beta_contract) .* ParQ);
ChildB_contract = .5 * ((1 - Beta_contract) .* ParP ...
  + (1 + Beta_contract) .* ParQ);
% next, via expanding crossover
ChildA_expand = .5 * ((1 + Beta_expand1st) .* ParP ...
  + (1 - Beta_expand1st) .* ParQ);
ChildB_expand = .5 * ((1 - Beta_expand2nd) .* ParP ...
  + (1 + Beta_expand2nd) .* ParQ);
% select children, based on which kind of crossover was (randomly) chosen
ChildA = ChildA_contract;
ChildA( Dir) = ChildA_expand( Dir);   %%%% OJO, ESTO LO CAMBIE YO
ChildB = ChildB_contract;
ChildB( Dir) = ChildB_expand( Dir);    %%%OJO ESTO LO CAMBIE YO
% form the actual population that is returned, i.e., replace parents destined
% for crossover w/ their children
ParP( :, X) = ChildA( :, X);
ParQ( :, X) = ChildB( :, X);
XIndivs = [ParP ParQ];

% find violations of assumption that all individuals are feasible solutions
foo = repmat( Cons( :, 2), 1, nmbOfIndivs) - XIndivs;
bar = XIndivs - repmat( Cons( :, 1), 1, nmbOfIndivs);
if ismember( 1, [foo bar] < 0)
  warning( sprintf( 'NSGA_SBX (after crossover): not all individuals are feasible solutions\n  largest violation is of size %g\n  small values are likely due to numeric instabilities and can be ignored\n since individuals will be forced within bounds ...', max( -[min( foo( :)) min( bar( :))])));
  XIndivs = min( repmat( Cons( :, 2), 1, nmbOfIndivs), XIndivs);
  XIndivs = max( repmat( Cons( :, 1), 1, nmbOfIndivs), XIndivs);
end
