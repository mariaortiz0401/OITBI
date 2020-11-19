function [dd,fren]=FPii(Jcomp,S,P,p)
  
T=0;
x=0;
JP=[Jcomp(:,1);1]  ;
JR=[Jcomp(:,2:S);2:1:S];
sizeJR=size(JR);
JRNew=JR;
sizeJRNew=size(JRNew);

while T<1

    for i=1:sizeJR(1,2);                                                                                       
        sizeJP=size(JP);
        dominaa=[];
        for j=1:sizeJP(1,2);
               AA= JP(1,j)>=JR(1,i);                    %comprueba si i domina a j
               BB= JP(2,j)>=JR(2,i);
               CC= JP(1,j)>JR(1,i);
               DD= JP(2,j)>JR(2,i);
               if (AA&&BB) && (CC|DD)         
                  dominaa(1,j)=JP(3,j) ;                %i domina a j
               end                                           
        end

        for nn=1:length(dominaa)
            for mm=1:length(JP(3,:))
                 if isequal(dominaa(1,nn),JP(3,mm))         %se eliminan las j dominadas de JP
                     JRNew(:,length(JRNew(3,:))+1)=JP(:,mm);     % se agregan a JRNew
                     JP(:,mm)=[];
                 break
                 end
            end                                            
        end
  
        if   isempty(JP)==0                      %verifica que JP no es vacío 
             for j= 1:sizeJP(1,2); 
                 JPNew=JP;
                 sizeJPNew=size(JPNew);
                 sizeJRNew=size(JRNew);
                 dominadapor=0 ;  
                   for j=1:sizeJPNew(1,2);
                         A= JR(1,i)>=JPNew(1,j);              %comprueba si i es dominada por 
                         B= JR(2,i)>=JPNew(2,j);              %alguno de los j restantes
                         C= JR(1,i)>JPNew(1,j);               
                         D= JR(2,i)>JPNew(2,j);
                             if (A&&B) && (C|D);
                             dominadapor=dominadapor+1;
                             end
                   end
             end    %aqui cierra j
                        
             if dominadapor>0
                   for ss=1:sizeJRNew(1,2)
                       if isequal(JRNew(3,ss),JR(3,i))      %si i es dominada por algun j
                          indigual=ss;                      
                       end
                   end
                     JRNew(:,indigual)=JR(:,i);                 % i permanece en JRNew
             else                                           %si i no es dominada por ningun j
                    JPNew=[JPNew JR(:,i)]  ;                    % va para JP
                        
                    for ss=1:sizeJRNew(1,2)  
                              if isequal(JRNew(3,ss),JR(3,i))      %debe ser eliminada de JRNew
                                 indigual=ss;
                              end
                    end
                     JRNew(:,indigual)=[];                        % i es eliminada de JRNew
             end
               
        else                                        %JP es vacío;
           JPNew=JR(:,i);                           %si JP queda vacío, i va para JP
                  for ss=1:sizeJRNew(1,2)  
                       if isequal(JRNew(3,ss),JR(3,i))      % i debe ser eliminada de JRNew
                         indigual=ss;
                       end
                  end
                     JRNew(:,indigual)=[];                        % i es eliminada de JRNew
                                                %i debe ser eliminada
                                                    %de JRNew
        end     %aqui cierra isempty
          
         sizeJRNew=size(JRNew);
         JP=JPNew;
         sizeJP=size(JP);
    end                       %acabo cilco i
  x=x+1; 
  y=[];

  for i= 1:length(JP(3,:))
  Jorden(:,i,x)=[y JP(:,i)];
  frenor(:,i,x)=x;
  end

  if isempty(JRNew)==0
     JP=JRNew(:,1);  
     JR=JRNew(:,2:length(JRNew(3,:)));
     sizeJR=size(JR);
     JRNew=JR;
     sizeJRNew=size(JRNew);
  else
      T=2;
  end
end

  cc=find(Jorden(3,:)~=0);
  Jordenado=Jorden(:,cc);
  frenorden=frenor(:,cc);
    for ss=1:length(Jordenado(3,:))
    bacordenadas(:,ss)=P(:,Jordenado(3,ss));
    end
     
dd=[bacordenadas; frenorden; Jordenado(3,:)] ;
fren=dd(p+1,S); %  numero de frentes 
