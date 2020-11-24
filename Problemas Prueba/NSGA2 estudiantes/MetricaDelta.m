function [delta] = MetricaDelta(numIndividuos,frenteX1, frenteX2, ObjVals)

B = sortrows(ObjVals.',1).';

totaldi = 0

for i=1:numIndividuos - 1
  x2 = B(1, i+1);
  y2 = B(2,i+1);
  x1 = B(1, i);
  y1 = B(2,i);
  di = sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
  totaldi = totaldi + di;
end

media = totaldi / numIndividuos

totalsumatoria = 0

for i=1:numIndividuos - 1
  x2 = B(1, i+1);
  y2 = B(2,i+1);
  x1 = B(1, i);
  y1 = B(2,i);
  di = sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
  dif = abs(di - media)
  totalsumatoria = totalsumatoria + dif;
end

extremo1x = frenteX1(1)
extremo1y = frenteX2(1)
extremo2x = frenteX1(numIndividuos)
extremo2y = frenteX1(numIndividuos)

d1X = B(1,1);
d1Y = B(2,1);
dnX = B(1, numIndividuos)
dnY = B(1, numIndividuos)

df =  sqrt((d1X - extremo1x) ^ 2 + (d1Y - extremo1y) ^ 2);
dl =  sqrt((dnX - extremo2x) ^ 2 + (dnY - extremo2y) ^ 2);

delta = (df + dl + totalsumatoria) / (df + dl + (numIndividuos - 1) * totalsumatoria)