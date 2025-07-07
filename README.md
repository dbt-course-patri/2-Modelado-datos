# 2-Modelado-datos


1. [Buenas prácticas de modelado con dbt](#schema1)
2. [Materializations](#schema2)
3. [Configuraciones útiles en modelos](#schema3)
4. [Crear y organizar un proyecto dbt completo](#schema4)




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

<hr>
<a name='schema4'></a>


## 4. Crear y organizar un proyecto dbt completo

- Paso 1: Requisitos previos

    1. Crear entorno virual

    ```bash 
    python3 -m venv env_dbt
    source env_dbt/bin/activate
    ```
    2. Instalar dbt para PostgresSQL
    ```bash
    pip install dbt-postgres
    ```
    3. Verificar instalación
    ```bash
    dbt --version
    ```
- Paso 2: Crear el proyecto dbt
```bash
dbt init my_dbt_project
cd my_dbt_project
```

- Paso 3: Configura la conexión a PostgreSQL
Archivo `profiles.yml`

Ubicación:
`~/.dbt/profiles.yml`

Ejemplo de conexión a PostgreSQL:

```yaml
my_dbt_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: tu_usuario
      password: tu_contraseña
      port: 5432
      dbname: tu_base_de_datos
      schema: public
      threads: 4
```

- Paso 4: Organiza las carpetas de modelos

Dentro de `models/`, crea:

```bash
mkdir -p models/staging
mkdir -p models/intermediate
mkdir -p models/marts/core
mkdir -p models/marts/marketing
```
```pgsql
models/
├── staging/
│   ├── stg_customers.sql
│   └── schema.yml 
├── intermediate/
│   ├── int_orders_enriched.sql
│   └── schema.yml 
└── marts/
    ├── core/
    │   ├── fct_orders.sql
    │   └── schema.yml 
    └── marketing/
        ├── dim_customers.sql
        └── schema.yml 

```

- Paso 5: Crear contenedor PostgreSQL con Docker con `docker_compose.yml`

    1. Crear archivo `docker-compose.yml`
        Crea un archivo llamado docker-compose.yml con este contenido:
    Ejemplo:
    ```yaml
    version: '3.8'

    services:
    postgres:
        image: postgres:15
        container_name: dbt_postgres
        environment:
        POSTGRES_USER: dbt_user
        POSTGRES_PASSWORD: dbt_pass
        POSTGRES_DB: dbt_db
        ports:
        - "5432:5432"
        volumes:
        - pgdata:/var/lib/postgresql/data
        restart: unless-stopped

    volumes:
    pgdata:
    ```
    2.  Levantar el contenedor
    En la terminal, desde la carpeta donde está tu `docker-compose.yml`:

        ```bash
        docker-compose up -d
        ```
    Esto iniciará PostgreSQL accesible en `localhost:5432`.
    3. Verifica conexión (opcional)
    Puedes probar que se conecta con un cliente como:

    - DBeaver
    - psql desde la terminal:
    ```bash
    psql -h localhost -U dbt_user -d dbt_db
    ```

- Paso 6: Ejecutar PostgreSQL con Docker (sin docker-compose)
Ejecuta este comando en tu terminal:

```bash
docker run --name postgres-dbt \
  -e POSTGRES_USER=patricia \
  -e POSTGRES_PASSWORD=1234 \
  -e POSTGRES_DB=dbt_tutorial \
  -p 5432:5432 \
  -d postgres
```

Si da error al ejecutar el docker.
1. Eliminar el contenedor existente
    1. Verifica los contenedores existentes:
    ```bash
    docker ps -a
    ```

    2. Elimina el contenedor existente:
    ```bash
    docker rm -f postgres-dbt
    ```
    -f fuerza el borrado si está en ejecución.
    3. Volver a correr tu comando.
    ```bash
        docker run --name postgres-dbt \
    -e POSTGRES_USER=patricia \
    -e POSTGRES_PASSWORD=1234 \
    -e POSTGRES_DB=dbt_tutorial \
    -p 5432:5432 \
    -d postgres

    ```
- Paso 7: Verifica que está funcionando
Puedes probar conexión con:

```bash
psql -h localhost -U patricia -d dbt_tutorial
```

- Paso 8: Insertar datos de ejemplo
Puedes conectarte a tu base de datos PostgreSQL con pgAdmin, DBeaver o psql y ejecutar esto:
   1.  Crear esquema raw (si no existe)
    ```sql
    CREATE SCHEMA IF NOT EXISTS raw;
    ```
    2. Crear tabla raw.customers
    ```sql
    CREATE TABLE raw.customers (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP
    );

    INSERT INTO raw.customers (name, email, signup_date) VALUES
    ('Alice', 'alice@example.com', '2023-01-01'),
    ('Bob', 'bob@example.com', '2023-01-02'),
    ('Carol', 'carol@example.com', '2023-01-03');
    ```
- Paso 9: Crear modelos SQL paso a paso
    1. `models/staging/stg_customers.sql`
    2. `models/intermediate/int_orders_enriched.sql`
    3. `models/marts/core/fct_orders.sql`
    4. `models/marts/marketing/dim_customers.sql`

- Paso 10: Agrega archivos `schema.yml` para documentar

- Paso 11: Ejecutar tu flujo
    1. Compila el proyecto
    ```bash
    dbt debug
    ```
    2. Ejecuta modelos
    ```bash
    dbt run
    ```
    3. Verifica dependencias
    ```bash
    dbt ls
    ```
    4. Genera documentación
    ```bash
    dbt docs generate
    dbt docs serve
    ```


<hr>
<a name='schema5'></a>

## 5 Ejercicio: Modelo incremental
- Toma un modelo como `fct_orders`.
    - `materialized='incremental'`: lo convierte en modelo incremental.



- Cámbialo a incremental con `unique_key='order_id'`.
    - unique_key='order_id': identifica de forma única cada fila.

- Añade condición `WHERE con is_incremental()` para evitar re-procesar todo.
    - is_incremental(): permite añadir lógica que solo se ejecute cuando se agregan nuevos datos.

    - La condición order_date > max(order_date) evita reinsertar datos ya procesados.
- Ejecuta con datos nuevos y valida que solo se añaden filas nuevas.
```bash
dbt run --select fct_orders
```

- Inserta datos nuevos en la fuente `int_orders_enriched`
    - Hacer `INSERT` en la fuente original (`raw.orders` o `raw.customers`)
    - Si `int_orders_enriched` se construye desde stg_orders, y ese a su vez desde raw.orders, entonces lo correcto es:

    ```sql
    INSERT INTO raw.orders (order_id, customer_id, order_date, amount)
    VALUES
    (1005, 2, '2025-06-25', 200.00),
    (1006, 3, '2025-06-26', 300.00);
    ```
    - Luego simplemente ejecutas:

    ```bash
    dbt run --select stg_orders int_orders_enriched fct_orders
    ```