%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bacterial Chemotaxis Multiobjective Optimization Algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%           Mar�a Alejandra Guzm�n
%% 
%%                            SCH 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc
p=2;                                                                       %% N�mero de variables
M=2;                                                                       %% N�mero de funciones objetivo
S=100;	                                                                   %% Numero de bacterias de la colonias, debe ser un n�mero par
Nveces=100;                                                                %% N�mero de iteraciones
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
P(2,:)=x2                                                                  %% Inicio aleat�rio de las variabless
P(p+1,:)=[1:1:S];                                                          %% sub�ndice
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

FACTOR=((Nveces-contador)/Nveces) ;                                        %% actualizaci�n del valor de FACTOR

%%%========================================================================
%%%          CLASIFICAR  EN FRENTES PARETO
%%%========================================================================

[FP]=Sorting(J,S,P,p);                                                     %% Clasificaci�n por no dominancia (Deb y otros)

%%%========================================================================
%%%                     BACTERIAS FUERTES
%%%========================================================================
NumFren=0;
for i=1:S
     if isempty(FP{i})==0
         NumFren=NumFren+1;                     %%%contabilizar el n�mero de frentes
     end
 end

if contador==1
    Pant(:,:)=P(:,:);
    Jant(:,:)=J(:,:);                           %%% Posici�n anterior para bacterias de la primera iteraci�n
end

FFP1=size(FP{1});
TamFP1=FFP1(1,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Comparaci�n de la posici�n anterior y la actual par alas bacterias fuertes
for i=1:TamFP1
    Jcomp(1,1)=obj1SCH(FP{1}(1:p,i));
    Jcomp(2,1)=obj2SCH(FP{1}(1:p,i));
    Jcomp(1,2)=obj1SCH(Pant(1:p,FP{1}(p+1,i)));
    Jcomp(2,2)=obj2SCH(Pant(1:p,FP{1}(p+1,i)));
    Pcomp=[FP{1}(1:p,i) Pant(1:p,FP{1}(p+1,i));1 2];
    [FPcomp]=Sorting(Jcomp,2,Pcomp,p);                      %%% Comparaci�n por no dominancia de localizaci�n actual y anterior
    FFPcomp=size(FPcomp{1});
    TamFFPcomp=FFPcomp(1,2);
%%%%%%%%% Definici�n de un vector unitario en una direcci�n aleat�ria %%%%%
    Delta(1:p,FP{1}(p+1,i))= (2*(rand(p,1))-1); 
    Deltau(:,FP{1}(p+1,i))=Delta(:,FP{1}(p+1,i))/sqrt(Delta(:,FP{1}(p+1,i))'*Delta(:,FP{1}(p+1,i)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if TamFFPcomp==1                         %%% si localizaci�n actual o anterior domina una a la otra
       if TamFP1==1

%%%%%%%%%%%%%%%%%%%%%   SHORT TUMBLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
           
           for zz=1:p
              P1(zz,FP{1}(p+1,i))=FPcomp{1}(zz,1)+(Deltau(zz,FP{1}(p+1,i))*FACTOR*1e-3);  %% si solo UNA bacteria es fuerte (no dominada)
          end
       else                                                                 %%% hay m�s de UNA bacteria fuerte
          for zz=1:p
              P1(zz,FP{1}(p+1,i))=FPcomp{1}(zz,1)+(Deltau(zz,FP{1}(p+1,i))*(max(FP{1}(zz,:))-min(FP{1}(zz,:)))*FACTOR*1e-3); %%% Short Tumble
          end
       end
    else                                                                   %%% localizaci�n anterio y actual no se dominan mutuamente
        
%%%%%%%%%%%%%%%%%%%%%% LONG TUMBLE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
       if TamFP1==1                                                         %%% si solo UNA bacteria es fuerte
          for zz=1:p
              P1(zz,FP{1}(p+1,i))=FP{1}(zz,i)+(Deltau(zz,FP{1}(p+1,i))*FACTOR*1e-2);
          end
       else                                                                 %% hay m�s de UNA bacteria fuerte
          for zz=1:p
              P1(zz,FP{1}(p+1,i))=FP{1}(zz,i)+(Deltau(zz,FP{1}(p+1,i))*(max(FP{1}(zz,:))-min(FP{1}(zz,:)))*FACTOR*1e-2);    %%% Long Tumbe
          end
       end
    end
    P1(p+1,FP{1}(p+1,i))=FP{1}(p+1,i);                                      %%% asignaci�n de los sub�ndices de cada bacteria luego del movimiento
end
  
%%%========================================================================
%%%                     BACTERIAS D�BILES
%%%========================================================================
Prest=[];
JJ=[];

for i=2:NumFren
    Prest=[Prest FP{i}(:,:)];               %%%% Encuentra y almacena las bacterias d�biles
end

for ii=1:S-TamFP1
    
    mama=round(1+(TamFP1-1)*rand);          %%% selecciona aleat�riamente una bacteria fuerte
    
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
            P1(zz,Prest(p+1,ii))= FP{1}(zz,mama)+FP{1}(zz,mama)*(-0.01+0.02*rand)+ (Delta(zz,Prest(p+1,ii))*FACTOR);  %%swim si hay m�s de una bacteria fuerte
        end
     end
     P1(p+1,Prest(p+1,ii))=Prest(p+1,ii);                                   %%% asignaci�n de los subindices de cada bacteria luego del movimiento
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
FPant{1}=FP{1};                                                            %%% actualizaci�n de las localizacionea actuales y anteriores
P(:,:)=P1(:,:);
contador=contador+1    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
end   %%%%finalizaci�n de contador
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



