import numpy as np
import random
import warnings
import random
import copy
import pandas as pd
import time
import matplotlib
import matplotlib.pyplot as plt
from datetime import datetime

class Particula:
	def __init__(self, n_variables, limites_inf=None, limites_sup=None, verbose=False):
		self.n_variables = n_variables
		self.limites_inf = limites_inf
		self.limites_sup = limites_sup
		self.posicion = np.repeat(None, n_variables)
		self.velocidad = np.repeat(None, n_variables)
		self.valor = np.repeat(None, 1)
		self.mejor_valor = None
		self.mejor_posicion = None

		for i in np.arange(self.n_variables):
			self.posicion[i] = random.uniform(self.limites_inf[i], self.limites_sup[i])

		self.velocidad = np.repeat(0, self.n_variables)

		print("Nueva partícula creada")
		print("----------------------")
		print("Posición: " + str(self.posicion))
		print("Límites inferiores de cada variable: " \
                  + str(self.limites_inf))
		print("Límites superiores de cada variable: " \
                  + str(self.limites_sup))
		print("Velocidad: " + str(self.velocidad))
		print("")

	def evaluar_particula(self, funcion_objetivo, optimizacion):
		self.valor = funcion_objetivo(*self.posicion)
		if self.mejor_valor is None:
			self.mejor_valor    = np.copy(self.valor)
			self.mejor_posicion = np.copy(self.posicion)
		else:
			if optimizacion == "minimizar":
				if self.valor < self.mejor_valor:
					self.mejor_valor    = np.copy(self.valor)
					self.mejor_posicion = np.copy(self.posicion)
			else:
				if self.valor > self.mejor_valor:
					self.mejor_valor    = np.copy(self.valor)
					self.mejor_posicion = np.copy(self.posicion)

		print("La partícula ha sido evaluada")
		print("-----------------------------")
		print("Valor actual: " + str(self.valor))
		print("")


	def mover_particula(self, mejor_p_enjambre, inercia=0.8, peso_cognitivo=2,
                        peso_social=2):

		componente_velocidad = inercia * self.velocidad
		r1 = np.random.uniform(low=0.0, high=1.0, size = len(self.velocidad))
		r2 = np.random.uniform(low=0.0, high=1.0, size = len(self.velocidad))
		componente_cognitivo = peso_cognitivo * r1 * (self.mejor_posicion - self.posicion)
		componente_social = peso_social * r2 * (mejor_p_enjambre - self.posicion)
		nueva_velocidad = componente_velocidad + componente_cognitivo + componente_social
		self.velocidad = np.copy(nueva_velocidad)

		self.posicion = self.posicion + self.velocidad
        
        #comprobar límites
		for i in np.arange(len(self.posicion)):
			if self.posicion[i] < self.limites_inf[i]:
				self.posicion[i] = self.limites_inf[i]
				self.velocidad[i] = 0

			if self.posicion[i] > self.limites_sup[i]:
				self.posicion[i] = self.limites_sup[i]
				self.velocidad[i] = 0

		print("La partícula se ha desplazado")
		print("-----------------------------")
		print("Nueva posición: " + str(self.posicion))
		print("")


class Enjambre:
	def __init__(self, n_particulas, n_variables, limites_inf = None,
                 limites_sup = None, verbose = False):

		self.n_particulas = n_particulas
		self.n_variables = n_variables
		self.limites_inf = limites_inf
		self.limites_sup = limites_sup
		self.particulas = []
		self.optimizado = False
		self.iter_optimizacion = None
		self.mejor_particula = None
		self.mejor_valor = None
		self.mejor_posicion = None
		self.historico_particulas = []
		self.historico_mejor_posicion = []
		self.historico_mejor_valor = []
		self.diferencia_abs = []
		self.resultados_df = None
		self.valor_optimo = None
		self.posicion_optima = None

		for i in np.arange(n_particulas):
			particula_i = Particula(
	                            n_variables = self.n_variables,
	                            limites_inf = self.limites_inf,
	                            limites_sup = self.limites_sup,
	                            verbose     = verbose
	                          )
			self.particulas.append(particula_i)

		print("---------------")
		print("Enjambre creado")
		print("---------------")
		print("Número de partículas: " + str(self.n_particulas))
		print("Límites inferiores de cada variable: " + str(self.limites_inf))
		print("Límites superiores de cada variable: " + str(self.limites_sup))
		print("")


	def mostrar_particulas(self, n=None):
		if n is None:
			n = self.n_particulas
		elif n > self.n_particulas:
			n = self.n_particulas

		for i in np.arange(n):
			print(self.particulas[i])
		return(None)

	def evaluar_enjambre(self, funcion_objetivo, optimizacion):
		for i in np.arange(self.n_particulas):
			self.particulas[i].evaluar_particula(funcion_objetivo = funcion_objetivo, optimizacion     = optimizacion)

		self.mejor_particula =  copy.deepcopy(self.particulas[0])
		for i in np.arange(self.n_particulas):
			if optimizacion == "minimizar":
				if self.particulas[i].valor < self.mejor_particula.valor:
					self.mejor_particula = copy.deepcopy(self.particulas[i])
			else:
				if self.particulas[i].valor > self.mejor_particula.valor:
					self.mejor_particula = copy.deepcopy(self.particulas[i])

		self.mejor_valor    = self.mejor_particula.valor
		self.mejor_posicion = self.mejor_particula.posicion

		print("-----------------")
		print("Enjambre evaluado")
		print("-----------------")
		print("Mejor posición encontrada : " + str(self.mejor_posicion))
		print("Mejor valor encontrado : " + str(self.mejor_valor))
		print("")

	def mover_enjambre(self, inercia, peso_cognitivo, peso_social):
		for i in np.arange(self.n_particulas):
			self.particulas[i].mover_particula(
                mejor_p_enjambre = self.mejor_posicion,
                inercia          = inercia,
                peso_cognitivo   = peso_cognitivo,
                peso_social      = peso_social
			)

		print("---------------------------------------------------------------------")
		print("La posición de todas las partículas del enjambre ha sido actualizada.")
		print("---------------------------------------------------------------------")
		print("")

	def optimizar(self, funcion_objetivo, optimizacion, n_iteraciones = 50,
                  inercia = 0.8, reduc_inercia = True, inercia_max = 0.9,
                  inercia_min = 0.4, peso_cognitivo = 2, peso_social = 2,
                  parada_temprana = False, rondas_parada = None,
                  tolerancia_parada  = None):

		if parada_temprana \
        and (rondas_parada is None or tolerancia_parada is None):
			raise Exception(
                "Para activar la parada temprana es necesario indicar un " \
                + " valor de rondas_parada y de tolerancia_parada."
                )
        
        # Si se activa la reducción de inercia, hay que especificar los argumentos
        # inercia_max y inercia_min.
		if reduc_inercia \
        and (inercia_max is None or inercia_min is None):
			raise Exception(
            "Para activar la reducción de inercia es necesario indicar un " \
            + "valor de inercia_max y de inercia_min."
            )

        # ITERACIONES
        # ----------------------------------------------------------------------
		start = time.time()

		for i in np.arange(n_iteraciones):
			print("-------------")
			print("Iteracion: " + str(i))
			print("-------------")
            
            # EVALUAR PARTÍCULAS DEL ENJAMBRE
            # ------------------------------------------------------------------
			self.evaluar_enjambre(
                funcion_objetivo = funcion_objetivo,
                optimizacion     = optimizacion,
                )

            # SE ALMACENA LA INFORMACIÓN DE LA ITERACIÓN EN LOS HISTÓRICOS
            # ------------------------------------------------------------------
			self.historico_particulas.append(copy.deepcopy(self.particulas))
			self.historico_mejor_posicion.append(copy.deepcopy(self.mejor_posicion))
			self.historico_mejor_valor.append(copy.deepcopy(self.mejor_valor))

            # SE CALCULA LA DIFERENCIA ABSOLUTA RESPECTO A LA ITERACIÓN ANTERIOR
            # ------------------------------------------------------------------
            # La diferencia solo puede calcularse a partir de la segunda
            # iteración.
			if i == 0:
				self.diferencia_abs.append(None)
			else:
				diferencia = abs(self.historico_mejor_valor[i] \
                                 - self.historico_mejor_valor[i-1])
				self.diferencia_abs.append(diferencia)

            # CRITERIO DE PARADA
            # ------------------------------------------------------------------
            # Si durante las últimas n iteraciones, la diferencia absoluta entre
            # mejores partículas no es superior al valor de tolerancia_parada,
            # se detiene el algoritmo y no se crean nuevas iteraciones.
			if parada_temprana and i > rondas_parada:
				ultimos_n = np.array(self.diferencia_abs[-(rondas_parada): ])
				if all(ultimos_n < tolerancia_parada):
					print("Algoritmo detenido en la iteracion " 
                          + str(i) \
                          + " por falta cambio absoluto mínimo de " \
                          + str(tolerancia_parada) \
                          + " durante " \
                          + str(rondas_parada) \
                          + " iteraciones consecutivas.")
					break
            
            # MOVER PARTÍCULAS DEL ENJAMBRE
            # ------------------------------------------------------------------
            # Si se ha activado la reducción de inercia, se recalcula su valor 
            # para la iteración actual.
			if reduc_inercia:
				inercia = ((inercia_max - inercia_min) \
                          * (n_iteraciones-i)/n_iteraciones) \
                          + inercia_min
           
			self.mover_enjambre(
               inercia        = inercia,
               peso_cognitivo = peso_cognitivo,
               peso_social    = peso_social
            )

		end = time.time()
		self.optimizado = True
		self.iter_optimizacion = i
        
        # IDENTIFICACIÓN DEL MEJOR PARTÍCULA DE TODO EL PROCESO
        # ----------------------------------------------------------------------
		if optimizacion == "minimizar":
			indice_valor_optimo=np.argmin(np.array(self.historico_mejor_valor))
		else:
			indice_valor_optimo=np.argmax(np.array(self.historico_mejor_valor))

		self.valor_optimo    = self.historico_mejor_valor[indice_valor_optimo]
		self.posicion_optima = self.historico_mejor_posicion[indice_valor_optimo]
        
        # CREACIÓN DE UN DATAFRAME CON LOS RESULTADOS
        # ----------------------------------------------------------------------
		self.resultados_df = pd.DataFrame(
            {
            "mejor_valor_enjambre"   : self.historico_mejor_valor,
            "mejor_posicion_enjambre": self.historico_mejor_posicion,
            "diferencia_abs"         : self.diferencia_abs
            }
        )
		self.resultados_df["iteracion"] = self.resultados_df.index
        
		print("-------------------------------------------")
		print("Optimización finalizada " \
              + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
		print("-------------------------------------------")
		print("Duración optimización: " + str(end - start))
		print("Número de iteraciones: " + str(self.iter_optimizacion))
		print("Posición óptima: " + str(self.posicion_optima))
		print("Valor óptimo: " + str(self.valor_optimo))
		print("")


part = Particula(
        n_variables = 3,
        limites_inf = [4,10,20],
        limites_sup = [-1,2,5]
        )

def funcion_objetivo(x_0, x_1, x_2):
    f= x_0**2 + x_1**2 + x_2**2
    return(f)

part.evaluar_particula(
    funcion_objetivo = funcion_objetivo,
    optimizacion = "maximizar"
    )

part.mover_particula(
    mejor_p_enjambre = np.array([-1000,-1000,+1000]),
    inercia          = 0.8,
    peso_cognitivo   = 2,
    peso_social      = 2
    )

enjambre = Enjambre(
               n_particulas = 4,
               n_variables  = 3,
               limites_inf  = [-5,-5,-5],
               limites_sup  = [5,5,5]
            )

def funcion_objetivo(x_0, x_1, x_2):
    f= x_0**2 + x_1**2 + x_2**2
    return(f)

enjambre.evaluar_enjambre(
    funcion_objetivo = funcion_objetivo,
    optimizacion     = "minimizar"
    )

enjambre.mover_enjambre(
    inercia          = 0.8,
    peso_cognitivo   = 2,
    peso_social      = 2,
)

def funcion_objetivo(x_0, x_1):
    """
    Para la región acotada entre −10<=x_0<=0 y −6.5<=x_1<=0 la función tiene
    múltiples mínimos locales y un único minimo global que se encuentra en
    f(−3.1302468,−1.5821422) = −106.7645367
    """
    f = np.sin(x_1)*np.exp(1-np.cos(x_0))**2 \
        + np.cos(x_0)*np.exp(1-np.sin(x_1))**2 \
        + (x_0-x_1)**2
    return(f)


enjambre = Enjambre(
               n_particulas = 50,
               n_variables  = 2,
               limites_inf  = [-10, -6.5],
               limites_sup  = [0, 0]
            )

enjambre.optimizar(
    funcion_objetivo = funcion_objetivo,
    optimizacion     = "minimizar",
    n_iteraciones    = 250,
    inercia          = 0.8,
    reduc_inercia    = True,
    inercia_max      = 0.9,
    inercia_min      = 0.4,
    peso_cognitivo   = 1,
    peso_social      = 2,
    parada_temprana  = True,
    rondas_parada    = 5,
    tolerancia_parada = 10**-3
)