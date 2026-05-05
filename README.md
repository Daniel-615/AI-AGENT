# Agente Inteligente de Rescate en Entorno Dinámico

## Descripción General

Este proyecto consiste en el desarrollo de un **agente inteligente autónomo** capaz de operar en un entorno dinámico e incierto representado como una cuadrícula.
El agente tiene como objetivo **localizar y rescatar personas**, evitando obstáculos, gestionando recursos limitados y tomando decisiones racionales basadas en información parcial.

El sistema integra múltiples técnicas de Inteligencia Artificial, incluyendo:

* Algoritmos de búsqueda
* Representación del conocimiento
* Planificación
* Manejo de incertidumbre
* Toma de decisiones
* Aprendizaje automático

---

## Objetivos del Proyecto

* Diseñar un agente capaz de **percibir, razonar y actuar** en un entorno cambiante.
* Implementar **algoritmos de búsqueda informados y no informados**.
* Modelar el entorno con **reglas lógicas**.
* Incorporar **incertidumbre y sensores imperfectos**.
* Desarrollar un sistema de **aprendizaje basado en experiencia**.
* Evaluar el desempeño del agente mediante métricas definidas.

---

## Modelado del Entorno

El entorno se representa como una **cuadrícula (grid)** donde cada celda puede contener:

* Espacio libre
* Obstáculos (no transitables)
* Zonas peligrosas (riesgo probabilístico)
* Personas a rescatar
* Estaciones de recarga (opcional)
* Posición del agente

### Características del entorno:

* **Dinámico**: los elementos pueden cambiar durante la ejecución.
* **Parcialmente observable**: el agente no conoce todo el mapa.
* **Estocástico**: ciertas acciones tienen resultados probabilísticos.

---

## Arquitectura del Agente

El agente está diseñado como un **agente basado en modelo con aprendizaje**, compuesto por:

### 1. Percepción

El agente recibe información del entorno mediante sensores:

* Estado de celdas cercanas
* Presencia de obstáculos o peligros
* Nivel de energía

### 2. Estado Interno

Mantiene un modelo interno del entorno:

* Mapa explorado
* Ubicación de objetivos conocidos
* Historial de acciones

### 3. Acciones

El agente puede:

* Moverse (arriba, abajo, izquierda, derecha)
* Rescatar personas
* Recargar energía

---

## Algoritmos de Búsqueda

Se implementan dos tipos:

### ✔ Búsqueda No Informada

* **Breadth-First Search (BFS)**
* No utiliza heurísticas
* Garantiza encontrar solución si existe

### ✔ Búsqueda Informada

* **A* (A estrella)**
* Utiliza heurística (distancia Manhattan)
* Optimiza tiempo y costo

### Comparación

| Algoritmo | Ventaja   | Desventaja             |
| --------- | --------- | ---------------------- |
| BFS       | Completo  | Lento en mapas grandes |
| A*        | Eficiente | Requiere heurística    |

---

## Representación del Conocimiento

Se implementa una base de conocimiento mediante reglas lógicas:

Ejemplos:

* Si una celda es obstáculo → no transitable
* Si hay peligro alto → evitar
* Si hay persona → priorizar rescate

Estas reglas permiten inferir decisiones sin necesidad de exploración completa.

---

## Planificación

El agente planifica secuencias de acciones considerando:

* Precondiciones (ej: tener energía suficiente)
* Efectos (ej: reducir energía, rescatar persona)

Se generan planes para:

* Alcanzar objetivos
* Minimizar riesgo
* Optimizar recursos

---

## Manejo de Incertidumbre

El entorno incluye elementos probabilísticos:

* Zonas peligrosas con riesgo variable
* Sensores con posible error

Se modela mediante:

* Probabilidades asignadas a eventos
* Evaluación de riesgo en decisiones

---

## Toma de Decisiones

Se define una función de utilidad para evaluar acciones:

Ejemplo:

Utilidad = (Personas rescatadas × peso) − (Riesgo × penalización) − (Consumo de energía)

El agente selecciona acciones que **maximizan su utilidad esperada**.

---

## Aprendizaje Automático

El agente mejora su comportamiento mediante **aprendizaje por refuerzo (Q-Learning)**:

### Características:

* Aprende de la experiencia
* Ajusta valores Q (estado-acción)
* Mejora decisiones con el tiempo

### Beneficios:

* Adaptación a entornos dinámicos
* Optimización de rutas
* Reducción de errores

---

## Tecnologías Utilizadas

* **Lenguaje:** Python
* **Visualización:** (consola / pygame / matplotlib)
* **Algoritmos IA:** BFS, A*, Q-Learning

---

## Estructura del Proyecto

```
/proyecto
│── agente.py          # Lógica del agente
│── entorno.py         # Definición del entorno
│── busqueda.py        # Algoritmos BFS y A*
│── conocimiento.py    # Reglas lógicas
│── aprendizaje.py     # Q-Learning
│── main.py            # Ejecución del sistema
```

---

## Ejecución

1. Clonar repositorio:

```
git clone <repo>
```

2. Ejecutar:

```
python main.py
```

---

##  Resultados Esperados

* El agente es capaz de:

  * Encontrar rutas óptimas
  * Evitar zonas peligrosas
  * Adaptarse al entorno
  * Mejorar con la experiencia

---

##  Análisis de Desempeño

Se evalúa en función de:

* Número de rescates
* Tiempo de ejecución
* Consumo de energía
* Riesgos asumidos

---

##  Entregables

* Código fuente funcional
* Documento técnico
* Video demostrativo (≤ 5 minutos)

---

## Autores

* Angel Suyán Garcia
* Ary Daniel Recinos

---

## Conclusión

Este proyecto demuestra la integración de múltiples técnicas de Inteligencia Artificial en un sistema funcional, capaz de operar en entornos complejos, tomar decisiones racionales y mejorar con la experiencia.

---
