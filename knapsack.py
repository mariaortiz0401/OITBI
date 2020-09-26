import random
import numpy as np
import matplotlib.pyplot as plt

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
   #print("---costo array----")
   #print(c)
   peso_ind = sum([pair[0] for pair in c])
   #print("---peso---")
   #print(peso_ind)
   profit = sum([pair[1] for pair in c])
   #print("---profit---")
   #print(profit)
   fitness = 0 
   if peso_ind <= capacidad_maxima:
      #print("No se pasa")
      fitness = profit
   return fitness

    
def get_cromo_info(pos):
   peso = datos_problema[pos][0]
   profit = datos_problema[pos][1]
   return peso, profit 


def seleccion_por_torneo(poblacion, scores):
    
    tam_poblacion = len(scores)
    
    cont_1 = random.randint(0, tam_poblacion-1)
    cont_2 = random.randint(0, tam_poblacion-1)
    
    cont_1_fitness = scores[cont_1]
    cont_2_fitness = scores[cont_2]
    
    if cont_1_fitness >= cont_2_fitness:
       ganador = cont_1
    else:
       ganador = cont_2

    return poblacion[ganador, :]

def cruzamiento(padre_1, padre_2):
    
    punto_cruce = random.randint(1,largo_cromosoma-1)
    
    #Crear un nuevo array con el punto de cruce y a
    #partir de los padres
    hijo_1 = np.hstack((padre_1[0:punto_cruce],
                        padre_2[punto_cruce:]))
    
    hijo_2 = np.hstack((padre_1[0:punto_cruce],
                        padre_2[punto_cruce:]))
    
    return hijo_1, hijo_2


def mutacion_random(poblacion, prob_mutacion):
    
    #Valor aleatorio de 0.1 a 1
    ar_mutacion = np.random.random(size=(poblacion.shape)) #8x10
    #print("ar_mutacion")
    #print(ar_mutacion)

    #Se evalúa si el valor aleatorio es menor a parámetro de mutacion
    #Si lo es, arrojará un TRUE
    es_menor =  ar_mutacion <= prob_mutacion
    #print("es menor")
    #print(es_menor)
    #Si es TRUE, se cambia el valor.
    poblacion[es_menor] = np.logical_not(poblacion[es_menor])

    return poblacion

def mutacion_flip(poblacion):
    
    pob = list(map(flip_array,poblacion))
    return poblacion

def flip_array(pos):
    return [int(not i) for i in pos]
# --------- MAIN  -------------


# Set general parameters

datos_problema = [[25,350],[35,400],[45,450],[5,20],[25,70],[3,8],[2,5],[2,5]]
largo_cromosoma = 8
tamano_poblacion = 10
maximo_generaciones = 200
capacidad_maxima = 104
progreso = []
progreso_scores = [];

poblacion = crear_poblacion_inicial(tamano_poblacion , largo_cromosoma)
print(poblacion)
scores = list(map(calcular_fitness, poblacion))
print(scores)
mejor_score = np.max(scores)
pos_mejor_score = np.argmax(scores)
progreso.append((poblacion[pos_mejor_score],mejor_score))
progreso_scores.append(mejor_score)


for generacion in range(maximo_generaciones):

    print("-----GENERACIÓN----", generacion)
    nueva_pob = []
    
    for i in range(int(tamano_poblacion/2)):
        padre_1 = seleccion_por_torneo(poblacion, scores)
        padre_2 = seleccion_por_torneo(poblacion, scores)
        hijo_1, hijo_2 = cruzamiento(padre_1, padre_2)
        nueva_pob.append(hijo_1)
        nueva_pob.append(hijo_2)
    

    poblacion = np.array(nueva_pob)
    #print("Nueva población para generación - ", generacion)
    #print(poblacion)

    tasa_mutacion = 0.02
    poblacion = mutacion_random(poblacion, tasa_mutacion)
    #poblacion = mutacion_flip(poblacion)
    #print("Poblacion mutada para generacion - ", generacion)
    #print(poblacion)

    scores = list(map(calcular_fitness, poblacion))
    mejor_score = np.max(scores)
    pos_mejor_score = np.argmax(scores)
    print("El mejor para esta generacion fue: ", poblacion[pos_mejor_score], "con profit: ", mejor_score)
    progreso.append((poblacion[pos_mejor_score],mejor_score))
    progreso_scores.append(mejor_score)

mejor_ind  = max(progreso, key = lambda i : i[1])[0] 
mejor_profit  = max(progreso, key = lambda i : i[1])[1] 
print ('El mayor profit es: ', mejor_profit)
print ('Para el individuo: ', mejor_ind)

nombre_archivo = "Comportamiento-"+str(maximo_generaciones)+"-g.png"
plt.plot(progreso_scores)
plt.xlabel('Generacion')
plt.ylabel('Profit')
plt.savefig(nombre_archivo)