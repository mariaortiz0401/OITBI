# Bacterial Foraging Optimization Algorithm
# (c) Copyright 2013 Max Nanis [max@maxnanis.com].

import random
import math
import numpy as np

def evaluar_esfuerzo(D, d, r):
  factor_concentracion = [[2, 1.015, -0.3000], [1.5, 1, -0.282], [1.20, 0.963, -0.255], [1.05, 1.005, -0.171],[1.01, 0.984, -0.105]]
  diferencias = []
  diametros = D / d
  for i in range(len(factor_concentracion)):
    diferencias.append(factor_concentracion[i][0] - (diametros))
  if diametros >= 2:
    diff = 0
  else:
    diff = diferencias.index(min([i for i in diferencias if i > 0]))
  B = factor_concentracion[diff][1]
  a = factor_concentracion[diff][2]
  kt = B * ((r / d) ** a)
  d_en_m = d / 1000
  esfuerzo = kt * ((4*150000)/ (np.pi * (d_en_m * d_en_m))) 
  return esfuerzo

class BFOA():

  def __init__(self, pop_size, problem_size, search_space, elim_disp_steps, repro_steps, chem_steps, swim_l, factor_penalizacion):
    self.step_index = 0
    
    # problem configuration
    self.problem_size = problem_size
    self.search_space = search_space
    self.factor_penalizacion = factor_penalizacion
    # algorithm configuration
    self.pop_size = pop_size
    self.step_size = 0.1 # Ci

    self.elim_disp_steps = elim_disp_steps # Ned, number of elimination-dispersal steps
    self.repro_steps = repro_steps # Nre, number of reproduction steps

    self.chem_steps = chem_steps # Nc, number of chemotaxis steps
    self.swim_length = swim_l # Ns, number of swim steps for a given cell
    self.p_eliminate = 0.25 # Ped

    self.d_attr = 0.1 # attraction coefficients
    self.w_attr = 0.2
    self.h_rep = self.d_attr # repulsion coefficients
    self.w_rep = 10

    # Generage the new randomly positioned population
    for x in range(self.pop_size):
      self.cells = [{'vector' : self.random_vector(self.search_space)} for x in range(self.pop_size)]
   

  def objective_function(self, vector):
    f = (np.pi / 4) * ((140 * (vector[0]*vector[0])) + (200 * (vector[1]*vector[1])))
    return(f) 


  def random_vector(self, minmax):
    temp = [np.random.uniform(x[0], x[1]) for x in minmax]
  # Control de D > d 
    while temp[1] > temp[0]:
      temp[0] = random.uniform(self.search_space[0][0], self.search_space[0][1])
      temp[1] = random.uniform(self.search_space[1][0], self.search_space[1][1])
    return temp

  def generate_random_direction(self, minmax):
    return [random.uniform(x[0], x[1]) for x in minmax]

  def compute_cell_interaction(self, cell, d, w):
    '''
      Compare the current cell to the other cells for attract or repel forces
    '''
    sum = 0.0

    for other_cell in self.cells:
      diff = 0.0
      for idx, i in enumerate( cell['vector'] ):
        diff += (cell['vector'][idx] - other_cell['vector'][idx])**2.0

      sum += d * math.exp(w * diff)
    return sum


  def attract_repel(self, cell):
    '''
      Compute the competing forces
    '''
    attract = self.compute_cell_interaction(cell, -self.d_attr, -self.w_attr)
    repel = self.compute_cell_interaction(cell, self.h_rep, -self.w_rep)
    return attract + repel


  def evaluate(self, cell):
    cell['cost'] = self.objective_function( cell['vector'] )
    # Puedo penalizar! 

    esfuerzo = evaluar_esfuerzo(*cell['vector'])

    # ----------- Penalizando funcion objetivo, valor * factor ------------ #

    if (esfuerzo > 85000000):
      #print("Penalizando funcion objetivo:", self.valor)
      cell['cost'] =  cell['cost'] + self.factor_penalizacion * (esfuerzo - 85000000)

    # --- Penalizando funcion objetivo cuando no se cumple que r <= (D -d) / 2 

    condicion_r = np.abs((cell['vector'][0] -  cell['vector'][1])) / 2
      
    if cell['vector'][2] > condicion_r:
      cell['cost'] =  cell['cost'] * self.factor_penalizacion

    cell['inter'] = self.attract_repel(cell)
    cell['fitness'] = cell['cost'] + cell['inter'] 
    return cell


  def tumble_cell(self, cell):
    step = self.generate_random_direction(self.search_space)

    vector = [None] * len(self.search_space)
    for idx, i in enumerate(vector):

      # For this search_space, move in that direction by the step distance from
      # where the cell currently is
      vector[idx] = cell['vector'][idx] + self.step_size * step[idx]
     
      # Control de las variables 
      if vector[idx] < self.search_space[idx][0]: vector[idx] = self.search_space[idx][0]
      if vector[idx] > self.search_space[idx][1]: vector[idx] = self.search_space[idx][1]
     
    # Control de D > d 
    while vector[1] > vector[0]:
        vector[0] = random.uniform(self.search_space[0][0], self.search_space[0][1])
        vector[1] = random.uniform(self.search_space[1][0], self.search_space[1][1])

    return {'vector' : vector}


  def chemotaxis(self):
    '''
      Best returns a cell instance
    '''
    best = None

    # chemotaxis steps
    for j in range(self.chem_steps):
      moved_cells = []

      # Iterate over each of the cells in the population
      for cell_idx, cell in enumerate(self.cells):
        
        sum_nutrients = 0.0
        # Determine J of current cell position
        cell = self.evaluate(cell)
        #print("cell cost:", cell)
        # If the first time, or if this movement gave the cell a lower energy
        if best is None or cell['cost'] < best['cost']: best = cell
        sum_nutrients += cell['fitness']
        
        # Move the cell to a new location
       
        # The cell will swimor tumble some every time interval
        for m in range(self.swim_length):
          
          new_cell = self.tumble_cell(cell)
          # Determine J of the moved to cell position
          new_cell = self.evaluate(new_cell)
          # If the newly positioned cell (from the last run) has the lowest J, track it
          if cell['cost'] < best['cost']: best = cell
          #print("New best:", best)
          # If the newly positioned cell is worse off than before, try again
          if new_cell['fitness'] > cell['fitness']: break # Se sale de swim si el movimiento no dio mejoras.
          # If the new cell is better off, save it
          # and log the total amount of food it's consumed
          cell = new_cell
          sum_nutrients += cell['fitness']

        cell['sum_nutrients'] = sum_nutrients
        moved_cells.append( cell )

      print("  >> chemo=#{0}, f={1}, cost={2}".format(j, best['fitness'], best['cost'] ))
      self.cells = moved_cells
      # Also capture these steps
      self.step_index += 1

    return best


  def search(self):
    '''
      Algorithm iterates over a new random population
    '''
    best = None

    # Elimination-dispersal: cells are discarded and new random samples are inserted with a low probability
    for l in range(self.elim_disp_steps):

      # Reproduction: cells that performed well over their lifetime may contribute to the next generation
      for k in range(self.repro_steps):

        # Chemotaxis: cost of cells is derated by the proximity to other cells and cells move along the manipulated cost surface one at a time
        # returns a single cell
        c_best = self.chemotaxis()

        # If the first time, or if this reproduction step gave a lower energy cell
        if best is None or c_best['cost'] < best['cost']: best = c_best
        print(" > best fitness={0}, cost={1}".format( best['fitness'], best['cost'] ))

        # During reproduction, typically half the population with a low health metric are
        # discarded, and two copies of each member from the first (high-health) half of the population are retained.
        self.cells = sorted(self.cells, key=lambda k: k['sum_nutrients'])
        lowest_cost_cells = self.cells[:self.pop_size//2]
        self.cells =  lowest_cost_cells + lowest_cost_cells

        # Also capture these steps
       
        self.step_index += 1


      # Elimination-dispersal over each cell
      for cell in self.cells:
        if random.random() <= self.p_eliminate: cell['vector'] = self.random_vector(self.search_space)
      
      self.step_index += 1


    print("best :: ", best)
    des_1 = (best['vector'][0] - best['vector'][1]) / 2
    diametros = best['vector'][0] / best['vector'][1]
    esfuerzo_mejor_particula = evaluar_esfuerzo(*best['vector'])
    print("")
    print("Esfuerzo:", esfuerzo_mejor_particula)
    print("Menor que 85000000: ", esfuerzo_mejor_particula < 85000000)
    print("Valor de D entre limites: ", (best['vector'][0] >= 20 and best['vector'][0] <= 100))
    print("Valor de d entre limites: ", (best['vector'][1] >= 10 and best['vector'][1] <= 80))
    print("Valor de r entre limites: ", (best['vector'][2] >= 1 and best['vector'][2] <= 15))
    print("r menor que D - d / 2: ", best['vector'][2] <= des_1)
    print("D/d > 1.01: ", diametros >= 1.01)
    return best


bfoa = BFOA(pop_size = 150, 
           problem_size = 3, 
           search_space = [[20,100],[10,80],[1,15]], 
           elim_disp_steps = 10, 
           repro_steps = 10, 
           chem_steps = 5,
           swim_l = 3,
           factor_penalizacion = 30)
best = bfoa.search() 
