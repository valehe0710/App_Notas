# App Notas

Aplicación móvil desarrollada en Flutter que permite gestionar notas, fotos y usuarios, consumiendo una API REST externa creada en Dart con Shelf.

Esta app incluye almacenamiento local, manejo de sesiones, navegación, temas visuales y conexión con la API por medio de JSON.

------------------------------

## Funcionalidades principales

**👤 Usuarios**

- Registro de usuario
- Inicio de sesión
- Guardado de sesión con shared_preferences
- Actualización de información del usuario
- Cierre de sesión

**📝 Notas**

- Crear notas
- Editar notas
- Eliminar notas
- Listado de notas por usuario
- Sincronización con la API mediante peticiones HTTP

**📸 Fotos**

- Tomar o seleccionar fotos con image_picker
- Guardarlas localmente y enviarlas a la API
- Mostrar las fotos asociadas al usuario
- Eliminar fotos

**Historial**

- Se muestra información obtenida desde la API
- Registro de cambios y acciones del usuario

>> Funcionalidad secundaria

- Cambio de tema modo claro / modo oscuro dentro de la app

-------------------------------------------

### Tecnologías utilizadas

Flutter para UI, HTTP para consumir la API, JSON para el intercambio de datos, shared_preferences para almacenar sesiones y path_provider para manejo de archivos locales

-----------------------------------------

### Dependencias utilizadas (pubspec.yaml)

- shared_preferences: ^2.2.2
- image_picker: ^1.0.4
- sqflite: ^2.3.0
- path_provider: ^2.1.3

-----------------------------------------

### Ejecutar la app

- Clonar este repositorio
- Abrir carpeta en VS Code

  - Ejecutar en consola:
    - ** flutter pub get*
     - ** flutter run*

Asegurarse de tener la API corriendo

-------------------------------------------
### Demostración de algunas pantallas

Pantalla Inicio de sesión: 

<img width="338" height="721" alt="Image" src="https://github.com/user-attachments/assets/b94a0999-6369-4aa9-b9db-089cccababde" />

Pantalla Registro:

<img width="319" height="700" alt="Image" src="https://github.com/user-attachments/assets/08107a77-67e5-4285-8c5c-e2fd72d3d1f0" />

Pantalla Home para las notas:

<img width="327" height="707" alt="Image" src="https://github.com/user-attachments/assets/3203c997-5983-4293-8147-dfb004929d0e" />

Menú de opciones :

<img width="331" height="717" alt="Image" src="https://github.com/user-attachments/assets/5744cdc5-eec6-429c-94e2-833977470295" />

Pantalla Editar Perfil:

<img width="359" height="778" alt="Image" src="https://github.com/user-attachments/assets/30234304-d481-4364-8eaf-91af00343902" />

Pantalla Historial:

<img width="319" height="690" alt="Image" src="https://github.com/user-attachments/assets/47df57ec-97b1-4232-8d18-4a984f451d4a" />

Pantalla Ajustes:

<img width="317" height="697" alt="Image" src="https://github.com/user-attachments/assets/cece3882-7c4c-4db1-88f8-7f54c6b3cb98" />

Pantalla Ajustes Modo oscuro activado:

<img width="327" height="723" alt="Image" src="https://github.com/user-attachments/assets/28f1294f-0aeb-4421-ac66-c435db3d6a39" />

Pantalla Cerrar Sesión:

<img width="318" height="697" alt="Image" src="https://github.com/user-attachments/assets/899a3731-8df7-4a72-852c-abc0e6aa36ea" />



