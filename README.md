# Proyecto Prueba Inter

Este proyecto es una aplicación de Flutter creada utilizando Clean Architecture, que organiza el código en capas separadas para asegurar una mejor mantenibilidad, escalabilidad y separación de responsabilidades.

## Estructura del Proyecto

La aplicación está estructurada en tres capas principales:

1. **Domain:** Define la lógica de negocio, las entidades y los contratos (interfaces) para los repositorios y data sources.

   - **Entities:** Representan los objetos del dominio.
   - **Repositories:** Interfaces que definen las reglas de acceso a datos.
   - **Datasources:** Interfaces para las fuentes de datos (API, bases de datos, etc.).

2. **Infrastructure:** Implementa las fuentes de datos y los repositorios.

   - **Datasources:** Implementaciones concretas de las fuentes de datos (e.g., SQLite, APIs).
   - **Repositories:** Implementaciones que coordinan las interacciones entre las fuentes de datos y el dominio.

3. **Presentation:** Se encarga de la interfaz de usuario y la lógica relacionada con la presentación.
   - **Screens:** Pantallas y widgets que componen la UI.
   - **Stores:** Gestión del estado usando **MobX**.

## Características Principales

- **Gestión de Amigos y Ubicaciones:** Permite agregar, editar y gestionar amigos, así como crear, eliminar y asignarles ubicaciones.
- **Mapas Interactivos:** Muestra mapas con las ubicaciones usando `flutter_map`.
- **Geolocalización:** Obtiene la ubicación actual del usuario o tiene la opción de buscar las coordendas según alguna direccion,
- **Validación de Formulario:** Valida datos como el nombre, correo electrónico y número de teléfono antes de agregar un nuevo amigo.

## Librerías Utilizadas

Estas son las principales librerías que se utilizaron en el proyecto:

- **Flutter Map** (`flutter_map`): Para la integración de mapas interactivos.
- **MobX** (`mobx`, `flutter_mobx`, `mobx_codegen`): Para la gestión reactiva del estado.
- **Geolocalización y Geocoding** (`geolocator`, `geocoding`): Para obtener la ubicación del usuario y convertir direcciones en coordenadas.
- **Image Picker** (`image_picker`): Para permitir la selección de imágenes desde la galería del dispositivo.
- **SQLite** (`sqflite`): Para almacenamiento persistente en la base de datos local.

## Instalación

1. Clona este repositorio en tu máquina local:
   ```bash
   git clone https://github.com/SergioCamiloCastillo/prueba_inter.git
   ```
2. Navega hasta el directorio del proyecto::
   ```bash
   cd prueba_inter
   ```
3. Navega hasta el directorio del proyecto::
   ```bash
   flutter pub get
   ```
4. Corre la aplicación ya sea en Android o iOS, segun el editor de texto y el emulador
