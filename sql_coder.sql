--tablas
SELECT * FROM Area
SELECT * FROM Asignaturas
SELECT * FROM Encargado
SELECT * FROM Estudiantes
SELECT * FROM Profesiones
SELECT * FROM Staff

-------------------------------------------------------------------------------------	
-------------------------------  P R O J E C T  ------------------------------- 
				--------------- NIVEL OPERATIVO --------------- 

-- 1)Análisis de docentes por camada/ comisión: 
--Número de documento de identidad, nombre del docente y camada, para identificar la camada mayor y la menor según el número de la  camada. 
--Número de documento de identidad, nombre de docente y camada para identificar la camada con fecha de ingreso ,ayo 2021. 
--Agregar un campo indicador que informe cuáles son los registros ”mayor o menor” y los que son “mayo 2021” y ordenar el listado de menor a mayor por camada

SELECT Documento, Nombre, Camada, "Mayor" as marca FROM Staff WHERE Camada = (SELECT MAX(Camada) FROM Staff)
UNION
SELECT Documento, Nombre, Camada, "Menor" as marca FROM Staff WHERE Camada = (SELECT MIN(Camada) FROM Staff)
UNION
SELECT Documento, Nombre, Camada, "Mayo" as marca FROM Staff WHERE YEAR(FechaIngreso) = 2021 AND MONTH(FechaIngreso) = 5

-- 2) Análisis diario de estudiantes: 
--Por medio de la fecha de ingreso de los estudiantes identificar: cantidad total de estudiantes.
--Mostrar los periodos de tiempo separados por año, mes y día, y presentar la información ordenada por la fecha que más ingresaron estudiantes.

SELECT YEAR(FechaIngreso) AS Año, MONTH(FechaIngreso) as Mes, DAY(FechaIngreso) as Day, COUNT(EstudiantesID) AS N_Estudiantes
FROM Estudiantes
GROUP BY FechaIngreso
ORDER BY COUNT(EstudiantesID) DESC

-- 3)Análisis de encargados con más docentes a cargo: 
--Identificar el top 10 de los encargados que tiene más docentes a cargo, filtrar solo los que tienen a cargo docentes. 
--Ordenar de mayor a menor para poder tener el listado correctamente.

SELECT TOP 10
Encargado.Encargado_ID, COUNT(Staff.DocentesID) AS DocentesACargo
FROM Encargado LEFT JOIN Staff ON Encargado.Encargado_ID = Staff.Encargado
WHERE Encargado.Tipo LIKE "*Docente*"
GROUP BY Encargado.Encargado_ID
ORDER BY COUNT(Staff.DocentesID) DESC
 
-- 4)Análisis de profesiones con más estudiantes: 
--Identificar la profesión y la cantidad de estudiantes que ejercen, mostrar el listado solo de las profesiones que tienen más de 5 estudiantes.
--Ordenar de mayor a menor por la profesión que tenga más estudiantes.

SELECT Profesiones.Profesiones, COUNT(Estudiantes.EstudiantesID) AS N_Estudiantes 
FROM Estudiantes INNER JOIN Profesiones ON Estudiantes.Profesion=Profesiones.ProfesionesID
GROUP BY Profesiones.Profesiones
HAVING COUNT(Estudiantes.EstudiantesID) > 5
ORDER BY COUNT(Estudiantes.EstudiantesID) DESC

-- 5) Análisis de estudiantes por área de educación: 
--Identificar: nombre del área, si la asignatura es carrera o curso , a qué jornada pertenece, cantidad de estudiantes y monto total del costo de la asignatura. 
--Ordenar el informe de mayor a menor por monto de costos total, tener en cuenta los docentes que no tienen asignaturas ni estudiantes asignados, también sumarlos.

SELECT Area.Nombre, Asignaturas.Tipo, Asignaturas.Jornada,
COUNT(Estudiantes.EstudiantesID), SUM(Asignaturas.Costo)
FROM Asignaturas 
INNER JOIN Area ON Asignaturas.Area = Area.AreaID
RIGHT JOIN Staff ON Asignaturas.AsignaturasID = Staff.Asignatura
LEFT JOIN Estudiantes ON Staff.DocentesID = Estudiante.Docente
GROUP BY Area.Nombre, Asignaturas.Tipo, Asignaturas.Jornada
ORDER BY SUM(Asignaturas.Costo) 


				--------------- NIVEL TÁCTICO ---------------

-- 1)Análisis mensual de estudiantes por área: 
--Identificar para cada área: el año y el mes (concatenados en formato YYYYMM), cantidad de estudiantes y monto total de las asignaturas. 
--Ordenar por mes del más actual al más antiguo y por cantidad de clientes de mayor a menor.

SELECT Area.Nombre, 
CONCAT(YEAR(Estudiantes.FechaIngreso), MONTH(Estudiantes.FechaIngreso)) AS YYYYMM, 
COUNT(Estudiantes.EstudiantesID) AS Cant_Estudiantes, 
SUM(Asignaturas.Costo) AS Costo_Total
FROM Area
INNER JOIN Asignaturas ON Area.AreaID = Asignaturas.Area
INNER JOIN Staff ON Staff.Asignatura = Asignaturas.AsignaturasID
INNER JOIN Estudiantes ON Estudiantes.Docente = Staff.DocentesID
GROUP BY Area.Nombre, CONCAT(YEAR(Estudiantes.FechaIngreso), MONTH(Estudiantes.FechaIngreso))
ORDER BY YYYYMM DESC, Cant_Estudiantes DESC

-- 2)Análisis encargado tutores jornada noche: 
--Identificar el nombre del encargado, el documento de identidad, el número de la camada (solo el número) y la fecha de ingreso del tutor. Ordenar por camada de forma mayor a menor.

SELECT Encargado.Nombre, Encargado.Documento, RIGHT(Asignaturas.Camada,5) AS N_Camada
FROM Staff 
INNER JOIN Encargado ON Staff.Encargado = Encargado.Encargado_ID 
INNER JOIN Asignaturas ON Asignaturas.AsignaturasID = Staff.Asignatura
WHERE Asignaturas.Tipo = "Noche" AND Encargado.Tipo LIKE "*Tutor*"
ORDER BY RIGHT(Asignaturas.Camada,5)

-- 3) Análisis asignaturas sin docentes o tutores: 
--Identificar el tipo de asignatura, la jornada, la cantidad de áreas únicas y la cantidad total de asignaturas que no tienen asignadas docentes o tutores.
--Ordenar por tipo de forma descendente.

SELECT Asignaturas.Tipo, Asignaturas.Jornada, COUNT(DISTINCT Asignaturas.Area) AS Cant_Areas, COUNT(Asignaturas.AsignaturasID) AS Cant_Asignaturas
FROM Asignaturas 
LEFT JOIN Staff ON Asignaturas.AsignaturasID = Staff.Asignatura
WHERE Staff.DocentesID IS NULL
GROUP BY Asignaturas.Tipo, Asignaturas.Jornada
ORDER BY Asignaturas.Tipo DESC

-- 4)Análisis asignaturas mayor al promedio: 
--Identificar el nombre de la asignatura, el costo de la asignatura y el promedio del costo de las asignaturas por área. 
--Una vez obtenido el dato, del promedio se debe visualizar solo las carreras que se encuentran por encima del promedio. 

--completar


-- 5)Análisis aumento de salario docente: 
--Identificar el nombre, documento de identidad, el área, la asignatura y el aumento del salario del docente, este último calcularlo sacándole un porcentaje al costo de la asignatura,
--todas las áreas tienen un porcentaje distinto, Marketing-17%, Diseño-20%, Programación-23%, Producto-13%, Data-15%, Herramientas 8%

SELECT Staff.Nombre, Staff.Documento, Area.Nombre, Asignatura.Nombre, (Asignaturas.Costo * 0.17) AS Aumento_Salarial
FROM Staff
INNER JOIN Asignaturas ON Staff.Asignatura = Asignaturas.AsignaturasID
INNER JOIN Area ON Area.AreaID = Asignaturas.Area
WHERE Area.Nombre = "Marketing Digital"
UNION
--completar con los demas
SELECT Staff.Nombre, Staff.Documento, Area.Nombre, Asignatura.Nombre, (Asignaturas.Costo * 0.2) AS Aumento_Salarial
FROM Staff
INNER JOIN Asignaturas ON Staff.Asignatura = Asignaturas.AsignaturasID
INNER JOIN Area ON Area.AreaID = Asignaturas.Area
WHERE Area.Nombre = "Diseño"

-- ...
-- UNION
-- ...
-- UNION
-- ...
-- UNION
-- ...


