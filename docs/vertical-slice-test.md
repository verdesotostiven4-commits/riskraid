# RiskRaid — Vertical Slice Test

## Objetivo

Esta prueba revisa la versión integrada del juego: lobby, stash, loadout, raid, loot, extracción, bots de seguridad y progreso básico.

## Antes de probar

1. Abrir GitHub Desktop.
2. Hacer Fetch origin.
3. Hacer Pull origin si aparece.
4. En Roblox Studio, detener Play.
5. En Rojo, hacer Disconnect y luego Connect.
6. Presionar Play.

## Flujo principal

1. Aparecer en el lobby.
2. Usar Starter Kit si está disponible.
3. Usar las estaciones de equipamiento:
   - Pulse Blaster
   - Med Kit
   - Armor Plate
4. Usar Deploy Gate.
5. Ir por cajas azules.
6. Ir por cajas moradas en High Risk Vault.
7. Evitar o desactivar Security Sentries.
8. Ir a Extraction Zone.
9. Confirmar que los objetos pasan al stash.
10. Confirmar que el jugador vuelve al lobby.

## Qué debe verse

- Lobby amarillo.
- Señales grandes.
- Estaciones de equipamiento.
- Zona morada de alto riesgo.
- Cajas azules normales.
- Cajas moradas mejores.
- Bots rojos de seguridad.
- Zona verde de extracción.
- UI con stash, mochila, rango y estadísticas.

## Reportar errores

Enviar captura de Output si pasa algo como:

- No aparece el lobby.
- No aparecen estaciones.
- No funciona Deploy.
- No funciona Extraction.
- No aparece stash.
- No aparecen bots.
- Hay mucho lag.
- Aparece error rojo.

## Limitaciones conocidas

- El HUD avanzado todavía puede mejorar.
- El guardado real puede requerir publicar la experiencia y activar API Services.
- El combate completo contra jugadores no está incluido todavía.
- El mapa todavía es prototipo visual, no arte final.
