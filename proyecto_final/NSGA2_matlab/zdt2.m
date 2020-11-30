function [f1, f2] = zdt2(x)
    x(x<0) = 0;
    x(x>1) = 1;
    f1 = x(1);
    g = 1 + (9 / (numel(x)-1) * sum (x(2:end)));
    h = 1 - (f1 / g)^2;
    f2 = g * h;
end