# 2-Modelado-datos


1. [Buenas prácticas de modelado con dbt](#schema1)
2. [Materializations](#schema2)
3. [Configuraciones útiles en modelos](#schema3)




<hr>
<a name='schema1'></a>

## 1. Buenas prácticas de modelado con dbt

### Estructura del proyecto:
- **Staging** (`stg_`):
    - Fuente directa de datos (`raw`).
    - Se limpia nombre de columnas, tipos de datos, y se renombran campos.
    - Un modelo por tabla original.
- **Intermediate** (`int_`):
    - Combinaciones, joins o cálculos complejos entre tablas.
    - Sirve como base para lo modelos de negocio.
- **Marts** (`dim_`, `fct_`):
    - Modelos de negicio finales.
    - Pueden ser dimensiones o hechos.
    - Se utilizan en dashboards y reporting.

### Ventajas:
- Legibilidad.
- Reusabilidad.
- Control de cambios y trazabilidad clara.

<hr>
<a name='schema2'></a>

## 2. Materializations

| Tipo          | Descripción                                | Cuándo usar                                           |
| ------------- | ------------------------------------------ | ----------------------------------------------------- |
| `view`        | Modelo ligero, se ejecuta al momento.      | Datos que cambian frecuentemente, prototipos rápidos. |
| `table`       | Materializa como tabla física.             | Datos que no cambian con frecuencia.                  |
| `incremental` | Solo actualiza datos nuevos o modificados. | Grandes volúmenes de datos, ETL optimizado.           |


Sintaxis de configuración:

```sql
{{ config(materialized='incremental') }}
```

<hr>
<a name='schema3'></a>

## 3. Configuraciones útiles en modelos

```sql
{{
    config(
        materialized='incremental',
        unique_key='id',
        on_chema_change='sync_all_columns'
    )
}}
```

### Párametros comunes:
- `materialized`: tipo de materialización.
- `unique_key`: necesario para `incremental`.
- `tags`: agrupar modelos.
- `on_schema_change`: qué hacer si cambia el esquema.