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
    
% Some examples of how to call NSGA_II and plots of the Pareto-optimal front.

% Just as a reminder, the signature of NSGA_II:
% function [ParGen, ObjVals, Ranking, SumOfViols, NmbOfFront] = ...
%   NSGA_II( nmbOfIndivs, nmbOfGens, Fct, Bounds, RandParams, Cons, ...
%   pX, etaX, pM, etaM, maxM)

%=========================================================================
%%                            SCH
%=========================================================================

clear all
clc
limites_actividades = [30 60; 300 450; 12 30; 36 66; 39 69; 39 69;60 102; 9 36; 15 42;18 45; 18 42];
limite_actividades_padre = [0 30 60; 0 300 450; 0 12 30; 0 36 66; 0 39 69; 0 39 69; 0 60 102; 0 9 36;0 15 42; 0 18 45; 0 18 42];
 [ParGen, ObjVals, Ranking, SumOfViols, NmbOfFront] = ...
   NSGA_II(100, 100, 'FINAL', limites_actividades, ...
   limite_actividades_padre, ...
   limite_actividades_padre, ...
   1, 1, .1, 1, .1);
figure(1)
clf
plot( ObjVals( 1, :), ObjVals( 2, :),'k.');

%hold on
%Indivs(1,:)=linspace(1,0,500);
%Indivs(2,:)=linspace(1,0,500);
%ObjValsop=[];
%ObjValsop(:,:)=zeros(2,500);
%for i=1:500
 %   [f1t, f2t] = zdt2(Indivs(:,i));
  %  ObjValsop(1, i) = f1t;
   % ObjValsop(2, i) = f2t;
%end
%plot( ObjValsop( 1, :), ObjValsop( 2, :),'m-');






