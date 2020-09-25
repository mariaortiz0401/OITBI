import random
import numpy as np
from numpy import asarray
from functools import reduce

def crear_poblacion_inicial(tamano_poblacion, largo_cromosoma):
    
    poblacion = np.zeros((tamano_poblacion, largo_cromosoma))
    for i in range(tamano_poblacion):
        #Cantidad de unos por fila
        unos = random.randint(0, largo_cromosoma)
        #Cambiar 0 por unos
        poblacion[i, 0:unos] = 1
        #Cambiar su orden en la fila
        np.random.shuffle(poblacion[i])
    
    return poblacion

def calcular_fitness(individuo):
   pos = np.where(individuo == 1)
   c = list(map(get_cromo_info,pos[0]))
   print("---costo array----")
   print(c)
   peso_ind = sum([pair[0] for pair in c])
   print("---peso---")
   print(peso_ind)
   profit = sum([pair[1] for pair in c])
   print("---profit---")
   print(profit)
   fitness = 0 
   if peso_ind <= capacidad_maxima:
      print("No se pasa")
      fitness = profit
   return fitness

    
def get_cromo_info(pos):
   peso = datos_problema[pos][0]
   profit = datos_problema[pos][1]
   return peso, profit 

# --------- MAIN  -------------


# Set general parameters

datos_problema = [[25,350],[35,400],[45,450],[5,20],[25,70],[3,8],[2,5],[2,5]]
largo_cromosoma = 8
tamano_poblacion = 10
maximo_generaciones = 100
capacidad_maxima = 104
best_score_progress = [] # Tracks progress


poblacion = crear_poblacion_inicial(tamano_poblacion , largo_cromosoma)
print(poblacion)
scores = list(map(calcular_fitness, poblacion))
print(scores)
#print(datos_problema)