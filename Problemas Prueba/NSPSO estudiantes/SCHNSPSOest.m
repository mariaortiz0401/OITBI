%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%          ALGORITMO NSPSO - XIAODONG LI   - 2003
%%%                            SCH  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     DATOS INICIALES
%%%========================================================================
clear all
clc
p=2;                                       %% n�mero de variables
M=2;                                       %% n�mero de funciones objetivos
N=100;                                     %% Numero de part�culas
Nveces=100;                                %% N�mero de iteraciones (criterio de parada)
w2=1;                                      %% peso inercial disminuye desde 1 hasta 0.4 (autor)
w1=0.4;
lamb=1;                                     %% Factor de constricci�n
c1=2;                                       %% coeficiente de aceleraci�n cognitiva                                
c2=2;                                       %% coeficiente de aceleraci�n social
Vmax=1000;                                  %% l�mite m�ximo y m�nimo de la velocidad


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                     INICIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 1) Iniciar poblacion aleat�riamente y almacenar en PSOList
PSOList(:,:)=-1000+(2000*rand(p,N));      %% posici�n inicial
V(:,:)=-1000+(2000*rand(p,N));            %% velocidad inicial
X(:,:)=PSOList(:,:);                      %% mejor ubicaci�n individual inicial
%%% b) evaluar las funciones objetivo para cada part�cula en la poblaci�n
contador=0;                               %%%contador cuenta el n�mero de iteraciones

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
 
P(:,:)=PSOList(:,:);                                %% Listado de Part�culas Mejores Individuos
 
%%% 3) Clasificar las soluciones en Frentes Pareto
[nonDomPSOList(:,:)]=FPii(J(:,:),N,P(:,:),p);       %% Procedimiento de ordenamiento por No dominancia (Deb y otros)

%%% 4) calcular Niching para cada part�cula
FR=length(find(nonDomPSOList(p+1,:)==1));
JFR=[];
m=[];
RenonDomPSOList=[];
nonDomPSOList1=[];
nonDomPSOListJFR=[];
JFR(:,:)=J(:,nonDomPSOList(p+2,1:FR));
[m]=NichingZIT1(JFR(:,:),FR);                            %% indica aglomeraci�n  de acuerdo con indice inicial 

%%% 5) reorganizar nonDomPSOList de acuerdo con Niching
RenonDomPSOList(:,:)=[nonDomPSOList(:,1:FR);m(1:FR)];
nonDomPSOList1(:,:)=sortrows(sortrows(RenonDomPSOList(:,:)',p+3),p+1)';
nonDomPSOListJFR(:,:)=nonDomPSOList1(1:p+2,:);

%%%========================================================================
%%%                  SELECCION DE Pg
%%%========================================================================
%%% 6a) Seleccionar la mejor part�cula aleatoriamente  entre el 5% mejor

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
        V(zz,i)=sign(V(zz,i))*min(abs(V(zz,i)),Vmax);               %%% controla valores m�ximo y m�nimo de la velocidad
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

%%% 7) Clasificar en Frentes Pareto la nueva poblaci�n 2N, para ello se
%%% deben medir los objetivos para la nueva poblaci�n 

for i=1:N
    JJ(1,i)=obj1SCH(nextPopList(:,i));
    JJ(2,i)=obj2SCH(nextPopList(:,i));  
end

JJ(:,N+1:2*N)=J(:,:);

[nonDomPSOListDupla(:,:)]=FPii(JJ(:,:),2*N,nextPopList(:,:),p);   %% clasificaci�n por dominancia de Pareto (Deb y otros)
 
FP1=length(find(nonDomPSOListDupla(p+1,:)==1));

%%% 8) Limpiar PSOList
PSOList(:,:)=zeros(p,N);
PSOList2(:,:)=zeros(p+2,N);

%%% 9) Si las Part�culas de nonDomPSOListElite(:,:) son m�s que N,
%%% seleccionar aleat�riamente de all�  para completar  PSOList, si son
%%% menos , inclu�rlas todas en PSOList
%%% 10) Completar PSOList si est� incompleta
 

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
