function [calidad] = calidad_total(ind)
    num_actividades = 11;
    calidad = 0;
    for act=1:num_actividades
        temp = calidad_actividad(act, ind(act));
        calidad = calidad + temp;
    end
    calidad = calidad / num_actividades
end