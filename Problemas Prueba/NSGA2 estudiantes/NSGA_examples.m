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
 [ParGen, ObjVals, Ranking, SumOfViols, NmbOfFront] = ...
   NSGA_II(500, 100, 'ZDT2', [0 1; 0 1], ...
   repmat( [0 0 1; 0 0 1], 1, 1), repmat( [0 1; 0 1], 1, 1), ...
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

%Frente óptimo
numInd = 500
x1=linspace(0,1,numInd);
x2 = 1 - x1(1, :).^2;
metricaY(:,:)=zeros(10,2);
metricaDelta(:,:)=zeros(10,2);

% Métricas
for i=1:10
   [ParGen, ObjVals, Ranking, SumOfViols, NmbOfFront] = ...
   NSGA_II( numInd, 100, 'ZDT2', [0 1; 0 1], ...
   repmat( [0 0 1; 0 0 1], 1, 1), repmat( [0 1; 0 1], 1, 1), ...
   1, 1, .1, 1, .1);
   
   metricaY(i,1)=i;
   [media,] = MetricaY(numInd, x1, x2, ObjVals);
   metricaY(i,2)=media;
   
   metricaDelta(i,1)=i;
   [delta] = MetricaDelta(numInd, x1, x2, ObjVals);
   metricaDelta(i,2)=delta;
   
   
end


