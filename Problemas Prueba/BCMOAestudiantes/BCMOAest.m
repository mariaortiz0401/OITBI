%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bacterial Chemotaxis Multiobjective Optimization Algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%           María Alejandra Guzmán
%% 
%%                            SCH 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc
p=2;                                                                       %% Número de variables
M=2;                                                                       %% Número de funciones objetivo
S=100;	                                                                   %% Numero de bacterias de la colonias, debe ser un número par
Nveces=100;                                                                %% Número de iteraciones
%%%========================================================================



%%%========================================================================
%%%                       INICIO ALEATORIO
%%%========================================================================
contador=1;
P=[];
P(:,:)=zeros(p,S);
J=zeros(M,S);

limitx1inf = 0
limitx1sup = 1
limitx2inf = 0
limitx2sup = 5
x1 = (limitx1sup-limitx1inf).*rand(1,S) + limitx1inf;
x2 = (limitx2sup-limitx2inf).*rand(1,S) + limitx2inf;
P(1,:)=x1;   
P(2,:)=x2                                                                  %% Inicio aleatório de las variabless
P(p+1,:)=[1:1:S];                                                          %% subíndice
P1(:,:)=zeros(p+1,S);
TamFP1=0;


while           contador<=Nveces                                           %% Criterio de parada                                   
%%%========================================================================
%%%             EVALUACION DE LAS FUNCIONES OBJETIVO
%%%========================================================================
for i=1:S
    J(1,i)=obj1SCH(P(1:p,i));
    J(2,i)=obj2SCH(P(1:p,i));
end

FACTOR=((Nveces-contador)/Nveces) ;                                        %% actualización del valor de FACTOR

%%%========================================================================
%%%          CLASIFICAR  EN FRENTES PARETO
%%%========================================================================

[FP]=Sorting(J,S,P,p);                                                     %% Clasificación por no dominancia (Deb y otros)

%%%========================================================================
%%%                     BACTERIAS FUERTES
%%%========================================================================
NumFren=0;
for i=1:S
     if isempty(FP{i})==0
         NumFren=NumFren+1;                     %%%contabilizar el número de frentes
     end
 end

if contador==1
    Pant(:,:)=P(:,:);
    Jant(:,:)=J(:,:);                           %%% Posición anterior para bacterias de la primera iteración
end

FFP1=size(FP{1});
TamFP1=FFP1(1,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Comparación de la posición anterior y la actual par alas bacterias fuertes
for i=1:TamFP1
    Jcomp(1,1)=obj1SCH(FP{1}(1:p,i));
    Jcomp(2,1)=obj2SCH(FP{1}(1:p,i));
    Jcomp(1,2)=obj1SCH(Pant(1:p,FP{1}(p+1,i)));
    Jcomp(2,2)=obj2SCH(Pant(1:p,FP{1}(p+1,i)));
    Pcomp=[FP{1}(1:p,i) Pant(1:p,FP{1}(p+1,i));1 2];
    [FPcomp]=Sorting(Jcomp,2,Pcomp,p);                      %%% Comparación por no dominancia de localización actual y anterior
    FFPcomp=size(FPcomp{1});
    TamFFPcomp=FFPcomp(1,2);
%%%%%%%%% Definición de un vector unitario en una dirección aleatória %%%%%
    Delta(1:p,FP{1}(p+1,i))= (2*(rand(p,1))-1); 
    Deltau(:,FP{1}(p+1,i))=Delta(:,FP{1}(p+1,i))/sqrt(Delta(:,FP{1}(p+1,i))'*Delta(:,FP{1}(p+1,i)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if TamFFPcomp==1                         %%% si localización actual o anterior domina una a la otra
       if TamFP1==1

%%%%%%%%%%%%%%%%%%%%%   SHORT TUMBLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
           
           for zz=1:p
              P1(zz,FP{1}(p+1,i))=FPcomp{1}(zz,1)+(Deltau(zz,FP{1}(p+1,i))*FACTOR*1e-3);  %% si solo UNA bacteria es fuerte (no dominada)
          end
       else                                                                 %%% hay más de UNA bacteria fuerte
          for zz=1:p
              P1(zz,FP{1}(p+1,i))=FPcomp{1}(zz,1)+(Deltau(zz,FP{1}(p+1,i))*(max(FP{1}(zz,:))-min(FP{1}(zz,:)))*FACTOR*1e-3); %%% Short Tumble
          end
       end
    else                                                                   %%% localización anterio y actual no se dominan mutuamente
        
%%%%%%%%%%%%%%%%%%%%%% LONG TUMBLE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
       if TamFP1==1                                                         %%% si solo UNA bacteria es fuerte
          for zz=1:p
              P1(zz,FP{1}(p+1,i))=FP{1}(zz,i)+(Deltau(zz,FP{1}(p+1,i))*FACTOR*1e-2);
          end
       else                                                                 %% hay más de UNA bacteria fuerte
          for zz=1:p
              P1(zz,FP{1}(p+1,i))=FP{1}(zz,i)+(Deltau(zz,FP{1}(p+1,i))*(max(FP{1}(zz,:))-min(FP{1}(zz,:)))*FACTOR*1e-2);    %%% Long Tumbe
          end
       end
    end
    P1(p+1,FP{1}(p+1,i))=FP{1}(p+1,i);                                      %%% asignación de los subíndices de cada bacteria luego del movimiento
end
  
%%%========================================================================
%%%                     BACTERIAS DÉBILES
%%%========================================================================
Prest=[];
JJ=[];

for i=2:NumFren
    Prest=[Prest FP{i}(:,:)];               %%%% Encuentra y almacena las bacterias débiles
end

for ii=1:S-TamFP1
    
    mama=round(1+(TamFP1-1)*rand);          %%% selecciona aleatóriamente una bacteria fuerte
    
    %%%%% SWIM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    for zz=1:p
         Delta(zz,Prest(p+1,ii))=FP{1}(zz,mama)-Prest(zz,ii);
     end
     if TamFP1==1
        for zz=1:p
            P1(zz,Prest(p+1,ii))=FP{1}(zz,mama)+ FP{1}(zz,mama)*(-1+2*rand)+ rand*(Delta(zz,Prest(p+1,ii))*FACTOR);%%% si solo hay UNA bacteria fuerte  
        end
     else
        for zz=1:p
            P1(zz,Prest(p+1,ii))= FP{1}(zz,mama)+FP{1}(zz,mama)*(-0.01+0.02*rand)+ (Delta(zz,Prest(p+1,ii))*FACTOR);  %%swim si hay más de una bacteria fuerte
        end
     end
     P1(p+1,Prest(p+1,ii))=Prest(p+1,ii);                                   %%% asignación de los subindices de cada bacteria luego del movimiento
end

 %%pared absorvente x1
 
 for i=1:S
        if P1(1,i)< 0 ;
        P1(1,i)= 0 ;
        elseif  P1(1,i)> 1 ;        
        P1(1,i)=1;
        end
   
 end

 %%pared absorvente x2
 
 for i=1:S
        if P1(2,i)< 0 ;
        P1(2,i)= 0 ;
        elseif  P1(2,i)> 5 ;        
        P1(2,i)=5;
        end
   
 end
  

Pant(:,:)=P(:,:);
FPant{1}=[];
FPant{1}=FP{1};                                                            %%% actualización de las localizacionea actuales y anteriores
P(:,:)=P1(:,:);
contador=contador+1    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
end   %%%%finalización de contador
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  %%%%%                      FIGURAS
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %===============================================================
 figure(1)
% %%%========================================================================
clf

Jultimo0(:,:)=zeros(M,S);
for i=1:S
    Jultimo0(1,i)=obj1SCH(P1(1:p,i));
    Jultimo0(2,i)=obj2SCH(P1(1:p,i));
end

FAA=linspace(0,1,500);
FAA2=linspace(0,5,500);

%for i=1:500
   % p = [FAA(:,i), FAA2(:,i)];
   % FA(i)=obj1SCH(p);
   % FB(i)=obj2SCH(p);
%end

%plot(FA,FB,'k-')
%xlabel('Objective1');
%ylabel('Objective2');
%title('SHC - NONDOMINATED SOLUTIONS - BCMOA');
%hold on
plot(Jultimo0(1,:),Jultimo0(2,:),'m.');



