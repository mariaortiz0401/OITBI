function [FP]=Sorting(J,S,P,p)

% clear
% clc
% p=30;
% S=100;
% P(1:p,:)=rand(p,S);
% P(p+1,:)=[1:1:S];
% for i=1:S
%     J(1,i)=obj1ZIT1(P(:,i));                         
%     J(2,i)=obj2ZIT1(P(:,i),p);  
% end




Sp = cell(S+1,1);
FP=cell(S,1);
np(:,:)=zeros(1,S);

for i=1:S
      for j=1:S
          if (((J(1,i)<=J(1,j)) && (J(2,i)<=J(2,j))) && ...
             ((J(1,i)<J(1,j))||(J(2,i)<J(2,j))))==1
             Sp{i} =[Sp{i} P(:,j)];
          elseif (((J(1,j)<=J(1,i)) && (J(2,j)<=J(2,i))) && ...
                 ((J(1,j)<J(1,i))||(J(2,j)<J(2,i))))==1
                 np(i)=np(i)+1;
                 
          end
      end
        if np(i)==0
           FP{1}=[FP{1} P(:,i)];
        end
end
    
ii=1;
 while isempty(FP{ii})==0
       Q=[];
       NumFP=size(FP{ii});
       for i=1:NumFP(1,2)                                 %%Por cada solución en el Frente Pareto
            if isempty(Sp{FP{ii}(p+1,i)})==0
                 NumSp=size(Sp{FP{ii}(p+1,i)});
                      for j=1:NumSp(1,2)                   %%Por cada solución en Sp de cada solución en FP
                           Spind=FP{ii}(p+1,i);
                           np(Sp{Spind}(p+1,j))=np(Sp{Spind}(p+1,j))-1;
                        if np(Sp{Spind}(p+1,j))==0
                           Q=[Q P(:,Sp{Spind}(p+1,j))];
                        end
                 end
            end
       
       end
      
       ii=ii+1;
        FP{ii}=Q;
 end
      