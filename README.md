# PAL Version 1.2

Alarma PAL para iOS y Android

## Descripcion
Proyecto en flutter para Alertas de Seguridad en iOS y Android

### Datos importantes del sistema 
Todos los usuarios pueden tener hasta tres referidos con estas relaciones:
- padre
- hermano
- pareja
- amigo
- otro

### TODO

- Seguridad por token al consumir el API
- Comprobar Token
- Listado de alertas offline
- Timeout en solicitudes
- Tarea en segundo plano con el track del alerta activa
- Recuperar contraseña en App
- Quitar recarga de pagina al solicitar los permisos del gps por primera vez
- Imagen del botón cancelar con sombra @noellopez1

### Cambios en esta version

- Offline, si no hay internet el alerta seguarda para siguiente conexion
- Cambiar el Icono de alerta de seguridad
- Mejoras de UI en pantalla de alertas
- Verificar cuando las mensajes son heartbeat y tracks y no mostrar alerta
- Mandar android id en lugar de modelo para android
- En login el form de email convierte la primera a mayusculas