function [costo] = costo_total(ind)
    num_actividades = 11;
    costo = 0;
    for act=1:num_actividades
        temp = costo_actividad(act, ind(act));
        costo = costo + temp;
    end
end