# Aetherion — projekt Godot 4

## Budowanie APK
1. Otwórz zakładkę **Actions** w repozytorium.
2. Uruchom workflow **Build Aetherion Android APK**.
3. Po udanym buildzie pobierz artefakt **Aetherion-debug-apk**.

Pierwszy eksport Android wymaga szablonów eksportu Godot oraz konfiguracji Android SDK/JDK w środowisku CI. Jeżeli workflow zgłosi błąd, analizujemy logi i poprawiamy konfigurację.

## Aktualny zakres
Pierwsza wersja to offline PvE: wybór rasy, poruszanie się, walka, przeciwnicy, doświadczenie, loot, zadanie startowe i zapis lokalny. Nie ma jeszcze serwera ani multiplayera.

## Sterowanie
- Dotykowe przyciski kierunkowe po lewej stronie dolnego paska.
- ATAK, TECHNIKA, FORMA i MIKSTURA po prawej.
- Panel postaci, torby, skilli i zadania w górnym prawym rogu.

Projekt jest w trakcie rozwoju; nie zakładamy, że build jest poprawny, dopóki GitHub Actions go nie potwierdzi.
