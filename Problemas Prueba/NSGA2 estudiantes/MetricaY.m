function [media, varianza] = MetricaY(numIndividuos,frenteX1, frenteX2, ObjVals)

B = sortrows(ObjVals.',1).';

totaldistancias = 0;

for i=1:numIndividuos
  x1 = frenteX1(1,i);
  x2 = frenteX2(1,i);
  y1 = B(1, i);
  y2 = B(2,i);
  distanciae = sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
  totaldistancia = totaldistancias + distanciae;
end

media = totaldistancia / numIndividuos;

totalvarianza = 0

for i=1:numIndividuos
  x1 = frenteX1(1,i);
  x2 = frenteX2(1,i);
  y1 = B(1, i);
  y2 = B(2,i);
  distanciae = sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
  r = (distanciae - media) ^ 2 ;
  totalvarianza = totalvarianza + r;
end

varianza = totalvarianza / numIndividuos;

end