function [m]= NichingZIT1(J,N)

%% u2 es el valor mayor del objetivo dos en la poblacion actual
%% l2 es el valor menor del objetivo dos enla poblacion actual
%% u1 es el valor mayor del objetivo uno en la poblacion actual
%% l1 es el valor menor del objetivo uno enla poblacion actual
u2=max(J(2,:));
l2=min(J(2,:));
u1=max(J(1,:));
l1=min(J(1,:));

if N~=1
   sigshare=(u2-l2+u1-l1)/(N-1);
   m(1,:)=zeros(1,N);
   for i=1:N
       for j=1:N
           radio(i,j)=sqrt((J(1,i)-J(1,j))^2+(J(2,i)-J(2,j))^2);
           if radio(i,j)~=0 && radio(i,j)<=sigshare
              m(1,i)=m(1,i)+1;
           end
       end
   end
else
    m(1,1)=1;
end