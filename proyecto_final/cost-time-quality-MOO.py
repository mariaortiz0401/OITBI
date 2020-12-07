# Program Name: NSGA-II.py
# Description: This is a python implementation of Prof. Kalyanmoy Deb's popular NSGA-II algorithm
# Author: Haris Ali Khan 
# Supervisor: Prof. Manoj Kumar Tiwari

#Importing required modules
import math
import random
import matplotlib.pyplot as plt
import numpy as np

def tiempo_total(pop):
    total_tiempo = []
    for i in range(len(pop)):
        temp = 0
        for j in range(num_actividades):
            temp = temp + pop[i][j]
        total_tiempo.append(temp)    
    return total_tiempo

def costo_actividad(act, tiempo):
    costo_crash = actividades[act][1][1]
    costo_normal = actividades[act][1][0] # Normal es menor, por eso está en 0
    tiempo_crash = actividades[act][0][0]
    tiempo_normal = actividades[act][0][1]
    numA = costo_crash - costo_normal
    denA= ((tiempo_crash ** 2) - (tiempo_normal ** 2))
    a =  numA / denA
    numB = ((costo_normal * (tiempo_crash ** 2)) - (costo_crash * (tiempo_normal ** 2)))
    denB = (tiempo_crash ** 2 - (tiempo_normal**2)) 
    b =  numB /denB
    costo = a * (tiempo ** 2) + b
    return costo

def costo_total(pop):
    total_costo = []
    for i in range(len(pop)):
        temp = 0
        for j in range(num_actividades):
            c = costo_actividad(j, pop[i][j])
            temp = temp + c
        total_costo.append(temp)    
    return total_costo

def calidad_actividad(act, tiempo):
    tiempo_crash = actividades[act][0][0]
    tiempo_normal = actividades[act][0][1]
    calidad_crash = actividades[act][2][0]
    calidad_normal = actividades[act][2][1]
    m = (calidad_crash - calidad_normal) / (tiempo_crash  - tiempo_normal) 
    n = ((calidad_normal * tiempo_crash) - (calidad_crash * (tiempo_normal))) / (tiempo_crash - (tiempo_normal)) 
    calidad = -1 * (m * (tiempo) + n)
    return calidad

def calidad_total(pop):
    total_calidad = []
    for i in range(len(pop)):
        temp = 0
        for j in range(num_actividades):
            c = calidad_actividad(j, pop[i][j])
            temp = temp + c
        temp = temp / num_actividades   
        total_calidad.append(temp)    
    return total_calidad

#Function to find index of list
def index_of(a,list):
    for i in range(0,len(list)):
        if list[i] == a:
            return i
    return -1

#Function to sort by values
def sort_by_values(list1, values):
    sorted_list = []
    while(len(sorted_list)!=len(list1)):
        if index_of(min(values),values) in list1:
            sorted_list.append(index_of(min(values),values))
        values[index_of(min(values),values)] = math.inf
    return sorted_list

#Function to carry out NSGA-II's fast non dominated sort
def fast_non_dominated_sort(values1, values2):
    S=[[] for i in range(0,len(values1))]
    front = [[]]
    n=[0 for i in range(0,len(values1))]
    rank = [0 for i in range(0, len(values1))]

    for p in range(0,len(values1)):
        S[p]=[]
        n[p]=0
        for q in range(0, len(values1)):
            if (values1[p] > values1[q] and values2[p] > values2[q]) or (values1[p] >= values1[q] and values2[p] > values2[q]) or (values1[p] > values1[q] and values2[p] >= values2[q]):
                if q not in S[p]:
                    S[p].append(q)
            elif (values1[q] > values1[p] and values2[q] > values2[p]) or (values1[q] >= values1[p] and values2[q] > values2[p]) or (values1[q] > values1[p] and values2[q] >= values2[p]):
                n[p] = n[p] + 1
        if n[p]==0:
            rank[p] = 0
            if p not in front[0]:
                front[0].append(p)

    i = 0
    while(front[i] != []):
        Q=[]
        for p in front[i]:
            for q in S[p]:
                n[q] =n[q] - 1
                if( n[q]==0):
                    rank[q]=i+1
                    if q not in Q:
                        Q.append(q)
        i = i+1
        front.append(Q)

    del front[len(front)-1]
    return front

#Function to calculate crowding distance
def crowding_distance(values1, values2, front):
    distance = [0 for i in range(0,len(front))]
    sorted1 = sort_by_values(front, values1[:])
    sorted2 = sort_by_values(front, values2[:])
    distance[0] = 4444444444444444
    distance[len(front) - 1] = 4444444444444444
    for k in range(1,len(front)-1):
        distance[k] = distance[k]+ (values1[sorted1[k+1]] - values2[sorted1[k-1]])/(max(values1)-min(values1))
    for k in range(1,len(front)-1):
        distance[k] = distance[k]+ (values1[sorted2[k+1]] - values2[sorted2[k-1]])/(max(values2)-min(values2))
    return distance

#Function to carry out the crossover

def cruzamiento(padre_1, padre_2):
    
    punto_cruce = random.randint(1,num_actividades-1)
    r=random.random()
    if r>p_crossover:
        temp_actividad = []
        for i in range(punto_cruce):
            temp_actividad.append(padre_1[i])
        for j in range(punto_cruce, num_actividades):
            temp_actividad.append(padre_2[j])
        return mutation(temp_actividad)
    else:
        temp_actividad = []
        for i in range(num_actividades):
            temp = np.random.uniform(low=actividades[i][0][0], high=actividades[i][0][1])
            temp_actividad.append(temp)
        return mutation(temp_actividad)

#Function to carry out the mutation operator
def mutation(solution):
    mutation_prob = random.random()
    if mutation_prob <p_mutation:
        solution = []
        for j in range(num_actividades):
            tiempo = np.random.uniform(low=actividades[j][0][0], high=actividades[j][0][1])
            costo = costo_actividad(j, tiempo)        
            calidad = calidad_actividad(j, tiempo)
            solution.append(tiempo)
    return solution

#Main program starts here
pop_size = 100
max_gen = 200
num_variables = 3
num_actividades = 11
solution = []
p_crossover = 0.8
p_mutation = 0.5

# Limites de cada una de las actividades en orden Tiempo, Costo y calidad
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
               [[18,42],[8782.17, 8789.79], [-0.9,-1]]]

for i in range(pop_size):
    sol = []
    for j in range(num_actividades):
        tiempo = np.random.uniform(low=actividades[j][0][0], high=actividades[j][0][1])
        sol.append(tiempo)
    solution.append(sol)

gen_no=0
while(gen_no<max_gen):
    function1_values = tiempo_total(solution)
    function2_values = costo_total(solution)
    function3_values = calidad_total(solution)
    non_dominated_sorted_solution = fast_non_dominated_sort(function2_values[:],function3_values[:])
    crowding_distance_values=[]
    for i in range(0,len(non_dominated_sorted_solution)):
        crowding_distance_values.append(crowding_distance(function2_values[:],function3_values[:],non_dominated_sorted_solution[i][:]))
    solution2= solution[:]
    #Generating offsprings
    while(len(solution2)!=2*pop_size):
        a1 = random.randint(0,pop_size-1)
        b1 = random.randint(0,pop_size-1)
        solution2.append(cruzamiento(solution[a1],solution[b1]))
    function1_values2 = tiempo_total(solution2)
    function2_values2 = costo_total(solution2)
    function3_values2 = calidad_total(solution2)
    non_dominated_sorted_solution2 = fast_non_dominated_sort(function2_values2[:],function3_values2[:])
    crowding_distance_values2=[]
    for i in range(0,len(non_dominated_sorted_solution2)):
        crowding_distance_values2.append(crowding_distance(function2_values2[:],function3_values2[:],non_dominated_sorted_solution2[i][:]))
    new_solution= []
    for i in range(0,len(non_dominated_sorted_solution2)):
        non_dominated_sorted_solution2_1 = [index_of(non_dominated_sorted_solution2[i][j],non_dominated_sorted_solution2[i] ) for j in range(0,len(non_dominated_sorted_solution2[i]))]
        front22 = sort_by_values(non_dominated_sorted_solution2_1[:], crowding_distance_values2[i][:])
        front = [non_dominated_sorted_solution2[i][front22[j]] for j in range(0,len(non_dominated_sorted_solution2[i]))]
        front.reverse()
        for value in front:
            new_solution.append(value)
            if(len(new_solution)==pop_size):
                break
        if (len(new_solution) == pop_size):
            break
    solution = [solution2[i] for i in new_solution]
    gen_no = gen_no + 1

#Lets plot the final front now
function1_values = tiempo_total(solution)
function2_values = costo_total(solution)
function3_values = calidad_total(solution)

function1 = [h for h in function1_values]
function2 = [i for i in function2_values]
function3 = [j for j in function3_values]

# Frente pareto
f1frente = []
f2frente = []
f3frente = []

for valuez in non_dominated_sorted_solution[0]:
        val = [solution[valuez]]
        print(val)
        f1 = tiempo_total(val)
        f1frente.append(f1)
        f2 = costo_total(val)
        f2frente.append(f2)
        f3 =  calidad_total(val)
        f3frente.append(f3)


plt.xlabel('Costo', fontsize=15)
plt.ylabel('Calidad', fontsize=15)
plt.scatter(function2, function3)

#plt.xlabel('Costo', fontsize=15)
#plt.ylabel('Calidad', fontsize=15)
#plt.scatter(function2, function3)

# ---- Gráfica 2d
#fig = plt.figure()
#ax = fig.add_subplot(111, projection='3d')
#ax.scatter(function1, function2, function3)

#ax.set_xlabel('Tiempo')
#ax.set_ylabel('Costo')
#ax.set_zlabel('Calidad')

plt.show()