% Evaluates each individual by computing its objective function values.
%
% ARGUMENTS
%
% Indivs - individuals to be evaluated
%   MxN array where M = number of decision variables and N = number of 
%   individuals
% Cons - constraints on the decision variables in the form of a permissible 
%   range for each variable.
%   MxN array where M = number of decision variables and N = 2 (1st column =
%   lower bound, 2nd column = upper bound).
%   something like [-inf inf] is allowed and means that there are no 
%   constraints on the respective decision variable
% Fct - letter code identifying which set of objective functions to use.
%   so far, the following multi-objective functions have been implemented:
%   'SCH' - Schaffer's function for x in [-1000 1000]
%   'KUR' - Kursawe's function for x in [-5 5]
%   'ZDT1' - Zitzler's 1st function for x in [0 1]
%   'ZDT2' - Zitzler's 2nd function for x in [0 1]
%   'ZDT4' - Zitzler's 4th function for x_1 in [0 1] and x_i>1 in [-5 5]
%
% RETURN VALUES
%
% ObjVals - objective function values for each individuals.
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
    
function ObjVals = NSGA_Evaluate( Indivs, Cons, Fct)

[nmbOfVars nmbOfIndivs] = size( Indivs);
ObjVals = zeros( 2, nmbOfIndivs);
switch Fct
    case 'ZDT2'
        [f1, f2] = zdt2(Indivs(:,1));
        ObjVals( 1, :) = f1;
        ObjVals( 2, :) = f2; 
    case 'SCH'
      % Schaffer's function for x in [-1000 1000]
        ObjVals( 1, :) = Indivs(1, :).^2;
        ObjVals( 2, :) = (Indivs(1, :) - 2).^2;
                
end