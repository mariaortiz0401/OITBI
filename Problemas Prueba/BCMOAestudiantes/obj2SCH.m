function [OBJ2]=obj2SCH(P)
     x1 = P(1)
     x2 = P(2)
     g1 = x2 + 9 * x1
     g2 = -x2 + 9
     if g1 >= 6 ;
        OBJ2=((1 + P(2)) / P(1)) * 200000;
        elseif  g2 >= 1 ;;         
        OBJ2=((1 + P(2)) / P(1)) * 200000;
     end
end