%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%          ALGORITMO NSPSO - XIAODONG LI   - 2003
%%%                            SCH  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     DATOS INICIALES
%%%========================================================================
clear all
clc
p=2;                                       %% número de variables
M=2;                                       %% número de funciones objetivos
N=100;                                     %% Numero de partículas
Nveces=100;                                %% Número de iteraciones (criterio de parada)
w2=1;                                      %% peso inercial disminuye desde 1 hasta 0.4 (autor)
w1=0.4;
lamb=1;                                     %% Factor de constricción
c1=2;                                       %% coeficiente de aceleración cognitiva                                
c2=2;                                       %% coeficiente de aceleración social
Vmax=1000;                                  %% límite máximo y mínimo de la velocidad


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                     INICIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 1) Iniciar poblacion aleatóriamente y almacenar en PSOList
PSOList(:,:)=-1000+(2000*rand(p,N));      %% posición inicial
V(:,:)=-1000+(2000*rand(p,N));            %% velocidad inicial
X(:,:)=PSOList(:,:);                      %% mejor ubicación individual inicial
%%% b) evaluar las funciones objetivo para cada partícula en la población
contador=0;                               %%%contador cuenta el número de iteraciones

for i=1:N
    J(1,i)=obj1SCH(X(:,i));
    J(2,i)=obj2SCH(X(:,i));  
end
J0(:,:)=J(:,:);




%%=========================================================================
while contador<Nveces
%%=========================================================================
%%%% 2) Aumentar contador
contador=contador+1

w=(w1-w2)*((Nveces-contador)/Nveces)+w2;            %%actualiza el peso inercial
 
P(:,:)=PSOList(:,:);                                %% Listado de Partículas Mejores Individuos
 
%%% 3) Clasificar las soluciones en Frentes Pareto
[nonDomPSOList(:,:)]=FPii(J(:,:),N,P(:,:),p);       %% Procedimiento de ordenamiento por No dominancia (Deb y otros)

%%% 4) calcular Niching para cada partícula
FR=length(find(nonDomPSOList(p+1,:)==1));
JFR=[];
m=[];
RenonDomPSOList=[];
nonDomPSOList1=[];
nonDomPSOListJFR=[];
JFR(:,:)=J(:,nonDomPSOList(p+2,1:FR));
[m]=NichingZIT1(JFR(:,:),FR);                            %% indica aglomeración  de acuerdo con indice inicial 

%%% 5) reorganizar nonDomPSOList de acuerdo con Niching
RenonDomPSOList(:,:)=[nonDomPSOList(:,1:FR);m(1:FR)];
nonDomPSOList1(:,:)=sortrows(sortrows(RenonDomPSOList(:,:)',p+3),p+1)';
nonDomPSOListJFR(:,:)=nonDomPSOList1(1:p+2,:);

%%%========================================================================
%%%                  SELECCION DE Pg
%%%========================================================================
%%% 6a) Seleccionar la mejor partícula aleatoriamente  entre el 5% mejor

elite=round(0.05*FR);
randelite=round(1+(elite-1)*rand(1, N));

for i=1:N
    if randelite(i)==0;   %%%% si solo hay una  No dominada, randelite puede ser cero, esto se corrige
       randelite(i)=1;
    end
end
Pg(:,:)=nonDomPSOListJFR(1:p,randelite(:));

%%%========================================================================
%%%          CALCULO DE NUEVA POSICION Y NUEVA VELOCIDAD
%%%========================================================================
%%% 6b) Calcula nueva V y nuevo X

for i=1:N
    for zz=1:p
        r1=rand;
        r2=rand;     
        V(zz,i)=w*V(zz,i)+c1*r1*(P(zz,i)-X(zz,i))+c2*r2*(Pg(zz,i)-X(zz,i));
        V(zz,i)=sign(V(zz,i))*min(abs(V(zz,i)),Vmax);               %%% controla valores máximo y mínimo de la velocidad
    end
end
VE(:,:)=V(:,:);
XX(:,:)=X(:,:);

for i=1:N
    for zz=1:p
        X(zz,i)=X(zz,i)+ V(zz,i);
        if     X(zz,i)<-1000
               X(zz,i)=-1000;                           %%% aplica pared absorvente
        elseif X(zz,i)>1000
               X(zz,i)=1000;
        end
    end
end
% %%%========================================================================
% %%%             ENCONTRAR LOS MEJORES UBICACIONES PERSONALES
% %%%========================================================================
%%% 6c) Formar una nueva poblacion con  P y X
nextPopList=[];
nextPopList=[X(:,:) P(:,:)];

%%% 7) Clasificar en Frentes Pareto la nueva población 2N, para ello se
%%% deben medir los objetivos para la nueva población 

for i=1:N
    JJ(1,i)=obj1SCH(nextPopList(:,i));
    JJ(2,i)=obj2SCH(nextPopList(:,i));  
end

JJ(:,N+1:2*N)=J(:,:);

[nonDomPSOListDupla(:,:)]=FPii(JJ(:,:),2*N,nextPopList(:,:),p);   %% clasificación por dominancia de Pareto (Deb y otros)
 
FP1=length(find(nonDomPSOListDupla(p+1,:)==1));

%%% 8) Limpiar PSOList
PSOList(:,:)=zeros(p,N);
PSOList2(:,:)=zeros(p+2,N);

%%% 9) Si las Partículas de nonDomPSOListElite(:,:) son más que N,
%%% seleccionar aleatóriamente de allí  para completar  PSOList, si son
%%% menos , incluírlas todas en PSOList
%%% 10) Completar PSOList si está incompleta
 

 PSOList2(:,:)=nonDomPSOListDupla(1:p+2,1:N);

 
PSOList(:,:)=PSOList2(1:p,:);
J(:,:)=JJ(:,PSOList2(p+2,:));
% 
% 
% %%=========================================================================
 end        %%%%  acaba contador=Nveces
% %%%===================================

figure(1)
clf
for i=1:N
    Jult(1,i)=obj1SCH(PSOList(:,i));
    Jult(2,i)=obj2SCH(PSOList(:,i));  
end

plot(Jult(1,:),Jult(2,:),'k.')
hold on
FAA=linspace(0,2,500);

for i=1:500
    FA(i)=obj1SCH(FAA(:,i));
    FB(i)=obj2SCH(FAA(:,i));
end
plot(FA,FB,'m-')
