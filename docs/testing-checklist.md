# RiskRaid — Testing Checklist v0.1

Usa esta lista cuando abras el prototipo en Roblox Studio.

## Prueba principal

1. Presiona **Play**.
2. Debe aparecer un mapa gris con paredes negras.
3. Debes ver una UI arriba a la izquierda con:
   - Raid Backpack
   - Stash
   - Extracts
   - Deaths
4. Camina hacia una caja azul.
5. Mantén presionado el prompt **Search**.
6. Debe aparecer un objeto en `Raid Backpack`.
7. Ve a la zona verde **Extraction**.
8. Mantén presionado **Extract**.
9. El objeto debe pasar del `Raid Backpack` al `Stash`.
10. El contador `Extracts` debe subir.

## Prueba de muerte/drop

1. Recoge loot de una caja azul.
2. Camina hacia el bloque rojo de prueba.
3. Tu personaje debe morir.
4. Debe aparecer una bolsa roja en el lugar de muerte.
5. Al reaparecer, tu `Raid Backpack` debe estar vacío.
6. Si otro jugador toca la bolsa y usa **Steal**, recibe esos objetos.

## Qué revisar y reportar

Cuando pruebes, mándame captura o texto de:

- Errores rojos en la ventana **Output**.
- Si no aparece la UI.
- Si las cajas no dan loot.
- Si la extracción no guarda objetos.
- Si la bolsa no aparece al morir.
- Si algo se ve feo o confuso.

## Limitaciones conocidas

- El almacén todavía es temporal; se borra cuando se cierra el servidor.
- Todavía no hay dúos reales.
- Todavía no hay bots.
- Todavía no hay ranked.
- Todavía no hay mapa visual profesional.
- Todavía no hay monetización.
