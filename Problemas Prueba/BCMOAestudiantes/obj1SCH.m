function [OBJ1]=obj1SCH(P)
     x1 = P(1);
     x2 = P(2);
     g1 = x2 + 9 * x1;
     g2 = -x2 + 9 * x1;
     if g1 < 6 ;
        OBJ1=P(1) * 200;
        elseif  g2 < 1 ;        
        OBJ1=P(1) * 200;
     else
         OBJ1=P(1);
     end
end