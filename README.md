#   Aventura Matemática – Minijuego Educativo

### 📚 Proyecto Final – Programación para Dispositivos Móviles  
**Universidad La Salle – Arequipa, Perú | 2025**

## 📝 1. Descripción del Proyecto
**Aventura Matemática** es una aplicación móvil educativa desarrollada en **Flutter**, cuyo objetivo es ayudar a niños y personas en general a reforzar sus habilidades en operaciones matemáticas básicas (suma, resta, multiplicación y división) de forma divertida, interactiva y progresiva.

Incluye funcionalidades como:  
- Sistema de niveles (Fácil, Medio, Difícil y Libre)  
- Registro e inicio de sesión de usuarios con Firebase Authentication
- Temporizador y retroalimentación visual
- Almacenamiento de datos con **Firebase Firestore**

## 👥 2.  Integrantes

| Nombre                  | Correo institucional               |
|-------------------------|------------------------------------|
| Pachari Gomez Leonardo  | lpacharig@ulsalle.edu              |
| Quispe Huanca Angela    | aquispeh@ulsalle.edu               |
| Usedo Quispe Allison    | ausedoq@ulsalle.edu                |
  
## ⚙️ 3. Instrucciones de instalación y ejecución
✅**Requisitos previos**
  *  Tener instalado Flutter SDK (versión estable recomendada)
  *  Tener instalado Android Studio (con emulador o dispositivo físico configurado)
  *  Git instalado (Descargar Git)
  *  Tener una cuenta Firebase (ya configurada en el proyecto)
  *  Dispositivo móvil con modo desarrollador activado y conectado por USB
    
✅**Pasos para clonar y ejecutar el proyecto**  
  
  *  Clona el repositorio desde GitHub  
    Abre una terminal o consola y escribe:

    ```
    # Clona el repositorio desde GitHub
    git clone https://github.com/usuario/repositorio-aventura-matematica.git
    
    # Entra a la carpeta del proyecto
    cd repositorio-aventura-matematica
    ```
   
 *  Instala las dependencias  
    Dentro del directorio del proyecto, ejecuta:
    ```
    flutter pub get
    ```
*  Conecta un emulador o dispositivo real    
    - Si usas Android Studio, puedes lanzar un emulador desde AVD Manager  
    - Si usas un celular real:
        * Activa el modo desarrollador
        * Habilita la opción Depuración por USB
        * Conéctalo por cable y acepta la autorización en pantalla
*  Ejecuta la app
   En la terminal:
   ```
   flutter run
   ```
*  Desde Android Studio:
   * Abre el proyecto
   * Espera que cargue el entorno
   * Haz clic en el botón ▶️ "Run"   
     
## 4. Pantallas Implementadas

|  **Pantalla**            |  **Descripción resumida**                                                         |
| ------------------------ | ----------------------------------------------------------------------------------- |
| **Splash Screen**        | Animación inicial con el logo y transición al menú principal.                       |
| **Login Screen**         | Inicio de sesión con Firebase y opción de recuperar contraseña.                     |
| **Register Screen**      | Registro de nuevos usuarios con nombre, correo y contraseña.                        |
| **Home Screen**          | Menú principal con botones de navegación y opción de cerrar sesión.                 |
| **Perfil de Usuario**    | Estadísticas, avatar, edición de nombre y conexión a Firebase.                      |
| **Selección de Niveles** | Cuatro niveles de dificultad con explicación y navegación al juego.                 |
| **Pantalla de Juego**    | Preguntas aleatorias, temporizador, puntuación en tiempo real.                      |
| **Resultados**           | Estadísticas al finalizar: preguntas correctas, tiempo promedio, retroalimentación. |
| **Historial**            | Lista de partidas anteriores, con nivel y puntuación, sincronizada con Firebase.    |

## 5. Aprendizajes
Este proyecto nos permitió aplicar conceptos como:

* Navegación y manejo de estado en Flutter
* Diseño de interfaz con Material Design
* Trabajo colaborativo y uso de GitHub
* Planificación de arquitectura MVC
  
## 6. Estado del proyecto
  
* Funcionalidad completa
* Firebase conectado
* Flujo de pantallas terminado
* Código modular y organizado
* Preparado para dispositivos móviles Android
