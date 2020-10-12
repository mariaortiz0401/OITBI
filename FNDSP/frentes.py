import random
import numpy as np
from operator import itemgetter
from functools import reduce

def buscar_puntos(pos):
	return [input[0][pos],input[1][pos]]

def imprimir_puntos_frente(pos):
	return list(map(buscar_puntos, pos))

def calc_area(pos):
	#print (pos[0], pos[1])
	return pos[0] * pos[1]

def creacion_frentes(valores_f1, valores_f2):
	#Conjunto de soluciones que p domina
    S=[[] for i in range(len(valores_f1))]
    # Arreglo de frentes
    frentes = [[]]
    # Contador de dominancia: número de soluciones que dominan a p
    n=[0 for i in range(len(valores_f1))]
    # Otra forma de ver los frentes, por su ranking de menos dominados a más dominados
    ranking = [0 for i in range(len(valores_f1))]

    # Orden O(MN^2), al comparar todos los puntos con todos.
    for p in range(len(valores_f1)):
    	#Todos los puntos arrancan con 0 y un conjunto de dominados vacío
        S[p]=[]
        n[p]=0
        for q in range(len(valores_f1)):
        	# Dominancia en todos los objetivos // Dominancia en al menos uno (f1 o f2)
            if (valores_f1[p] < valores_f1[q] and valores_f2[p] < valores_f2[q])  or (valores_f1[p] <= valores_f1[q] and valores_f2[p] < valores_f2[q]) or (valores_f1[p] < valores_f1[q] and valores_f2[p] <= valores_f2[q]):
               # P domina a q y por esto se incluye en S, si aún no se ha incluido.
               if q not in S[p]:
               	    #Cada posicion de S es un arreglo, dicho punto domina esas posiciones
                    S[p].append(q)
            elif (valores_f1[q] < valores_f1[p] and valores_f2[q] < valores_f2[p])  or (valores_f1[q] <= valores_f1[p] and valores_f2[q] < valores_f2[p]) or (valores_f1[q] < valores_f1[p] and valores_f2[q] <= valores_f2[p]):
               # q domina a p, por lo que se aumenta el contador de dominancia 
                n[p] = n[p] + 1
        # Todas las soluciones con n = 0, van al frentes 0. Puntos no dominados por ningún otro
        if n[p]==0:
            ranking[p] = 0
            if p not in frentes[0]:
                frentes[0].append(p)
 	
 	# Resultado: Arreglos de puntos dominados por cada punto p
    #print("\nArreglos de puntos dominados por cada punto p\n:",S)
    # Número de puntos que dominan a p
    #print("\nArreglo de número de putnos que dominas a p:\n",n)
    i = 0
    while(frentes[i] != []):
    	# Guarda los miembros del siguiente frentes
        Q=[]
        # Para cada solución p, con n == 0 (en frentes 0), se visita cada miembro q de su grupo y se reduce su n a 0
        for p in frentes[i]:
        	
        	# Se busca a qué puntos domina cada punto del frente 0 => [3, 10, 12, 29, 48, 50, 52, 54, 77, 95]
            for q in S[p]:

            	#Se disminuye el contador, cuando se vuelva 0, se pasa a un nuevo Q (nuevo frente)
                n[q] =n[q] - 1
                if( n[q]==0):
                    ranking[q]=i+1
                    if q not in Q:
                        Q.append(q)
        i = i+1
        frentes.append(Q)

    del frentes[len(frentes)-1]
    return frentes

# --------- MAIN  -------------

file = np.loadtxt("input1.txt", dtype='str', delimiter=' ')  #<---- Cambiar input a archivo
input = file.astype(np.float64)
print("\n---------Ejemplo Clase---------------\n")
print("Soluciones para f1:\n",input[0])
print("\nSoluciones para f2:\n",input[1])

frentes = creacion_frentes(input[0], input[1])
print("\n---------FRENTES---------------")
print(frentes)

print("\n---------PUNTOS POR CADA FRENTE---------------")
puntos = list(map(imprimir_puntos_frente,frentes))
for index, pos in enumerate(puntos):
	print("-- Frente ", index )
	print("Puntos:\n",pos)

print("\n---------  HIPERVOLUMEN  ---------------\n")
for index, pos in enumerate(puntos):
	#	print("Frente: ", str(index))
	if index == 0: #Quitar si se quiere hallar para otros frentes
		if (len(pos) != 1):
			punto_ref_x = np.amax(pos, axis=0)[0]
			punto_ref_y = np.amax(pos, axis=0)[1]
			punto_referencia = [punto_ref_x, punto_ref_y]  #Nadir, peor para ambas funciones
			print("punto de referencia:", punto_referencia)
			ordenados_por_f1 = sorted(pos)
			ordenados_por_f1.append(punto_referencia)
			rectangulos =[]
			i = 1
			while i < len(ordenados_por_f1):
				temp = [ordenados_por_f1[i][0] - ordenados_por_f1[i-1][0] , punto_ref_y - ordenados_por_f1[i-1][1]]
				rectangulos.append(temp)
				i = i+1
			areas = list(map(calc_area,rectangulos))
			hv = reduce((lambda a, b: a + b), areas)
			print("Hipervolumen: ", hv)

		else:
			punto_ref_x = pos[0][0]
			punto_ref_y = pos[0][1]
			punto_referencia = [punto_ref_x, punto_ref_y]

