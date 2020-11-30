

function [costo_actividad] = costo_actividad(act, tiempo)
actividades = [[[30,60],[6432.20, 6752.10], [-0.9,-1]],
               [[300,450],[2842, 4197], [-0.7,-1]],
               [[12,30],[2335.95, 2352.18 ], [-0.8,-1]],
               [[36,66],[10398.44, 10538.24], [-0.8,-1]],
               [[39,69],[15701.35, 15716.85], [-0.7,-1]],
               [[39,69],[1964.82, 1972.42], [-0.7,-1]],
               [[60,102],[6776.74, 6831.20], [-0.3,-1]],
               [[9,36],[11625.70, 11637.42], [-0.75,-1]],
               [[15,42],[6744.78, 6746.85], [-0.4,-1]],
               [[18,45],[1090.29, 1091.32], [-0.5,-1]],
               [[18,42],[8782.17, 8789.79], [-0.9,-1]]];

num_actividades = length(actividades);
      
        actividad = actividades(act,:);   
        disp(actividad);
        costo_crash = actividad(4);
        costo_normal = actividad(3); 
        tiempo_crash = actividad(1);
        tiempo_normal = actividad(2);
        a = costo_crash - costo_normal / (tiempo_crash ^ 2 - (tiempo_normal ^ 2));
        b = ((costo_normal * (tiempo_crash ^ 2) ) - (costo_crash * (tiempo_normal ^ 2))) / (tiempo_crash ^ 2 - (tiempo_normal^2)); 
        costo_actividad = a * (tiempo) + b;
end