function [OBJ2]=obj2SCH(P)
P(P < -pi) = -pi;
P(P > pi) = pi;
A1 = 0.5 * sin(1) - 2 * cos(1) + sin(2) - 1.5 * cos(2);
A2 = 1.5 * sin(1) - cos(1) + 2 * sin(2) - 0.5 * cos(2);
B1 = 0.5 * sin(P(1)) - 2 * cos(P(1)) + sin(P(2)) - 1.5 * cos(P(2));
B2 = 1.5 * sin(P(1)) - cos(P(1)) + 2 * sin(P(2)) - 0.5 * cos(P(2));

OBJ2= (P(1) + 3)^2 + (P(2)+1)^2;

end