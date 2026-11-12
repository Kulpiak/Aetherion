# Aetherion — KI: Legends of Power

## Pobieranie i instalacja APK na Androidzie
1. Otwórz najnowszy udany build w zakładce **Actions** repozytorium.
2. W sekcji **Artifacts** pobierz `Aetherion-debug-apk`.
3. Rozpakuj pobrany plik ZIP i uruchom `Aetherion-debug.apk` na telefonie.
4. Jeśli Android zapyta, zezwól aplikacji Pliki/przeglądarce na instalowanie aplikacji z tego źródła.
5. Gra działa jako lokalne **offline PvE** — po instalacji nie wymaga połączenia z internetem.

## Aktualny zakres offline
- Wybór jednej z pięciu ras i rozwój poziomu postaci.
- Dotykowe poruszanie, kamera, podstawowy atak, technika obszarowa i forma.
- Wrogowie z pościgiem, atakiem, HP i odradzaniem.
- Przeciwnicy zapowiadają ataki czytelnym sygnałem; można zejść z linii ciosu lub uniknąć trafienia aktywną Szarżą. Strażnik Rdzenia ostrzega przed większym atakiem obszarowym.
- Doświadczenie, złoto, mikstury i losowe łupy widoczne na ziemi.
- Podnoszenie materiałów przez podejście do nich.
- Ekwipunek, broń i pancerz z bonusami statystyk.
- Rzemiosło: Ostrze Eterium, Pancerz Łowcy i mikstury.
- Łańcuch zadania startowego, Wschodnie Ruiny i boss Strażnik Rdzenia.
- Lokalny zapis postępu: przycisk **ZAPISZ / WCZYTAJ**, automatyczny zapis co 30 sekund oraz zapis przy wstrzymaniu aplikacji.

## Sterowanie
- Przyciski kierunkowe na dolnym pasku poruszają postacią.
- **ATAK** — podstawowy atak.
- **TECHNIKA** — umiejętność obszarowa.
- **FORMA** — czasowe przebudzenie.
- **MIKSTURA** — leczenie.
- Przyciski w prawym górnym rogu otwierają postać, torbę, umiejętności, rzemiosło i mapę.
- **ZADANIE** służy do rozmowy z Kronikarzem i badania ruin.
- **ZAPISZ / WCZYTAJ** obsługują lokalny zapis.

## Ostatnia iteracja
- Dodano pięć autorskich herbów ras w wektorowym atlasie SVG i zintegrowano je z ekranem wyboru postaci.
- Dodano oryginalny atlas czterech glifów Eterium, zintegrowanych z telegraphami przeciwników, atakami, falą energii i Przebudzeniem Rdzenia.
- Dodano subtelne, animowane drobiny Eterium dopasowane kolorystycznie do biomów świata.
- Dodano Kodeks w grze: opis pięciu rodów, regionów i natury Eterium.
- To nadal etap rozbudowy prototypu; oprawa postaci i świata wymaga pełnego, docelowego przebudowania.

## Status projektu
To rozwijana wersja testowa offline PvE. Multiplayer, serwer, handel między graczami i synchronizacja online nie są jeszcze zaimplementowane. Każdy build traktujemy jako potwierdzony dopiero po poprawnym przejściu walidacji Godot i eksporcie APK w GitHub Actions; zachowanie w grze wymaga jeszcze testu na urządzeniu.

## Oprawa wizualna regionów
- Na mapie zintegrowano osiem autorskich landmarków SVG, po jednym dla każdego regionu: Kamiennego Kręgu, Zielonych Ostępów, Korony Gór, Krypty Kryształów, Złotych Pustkowi, Wschodnich Ruin, Popielnych Ziem i Szlaku Eterium.
- Odkryte punkty otrzymują wyraźniejszą poświatę i animowany obrys; nieodkryte są subtelniejsze.
- Drobiny atmosferyczne korzystają teraz z osobnych palet kolorystycznych wszystkich ośmiu regionów.

## Eksploracja regionów
- Podczas podróży HUD pokazuje aktualny region.
- Odkrywanie nowych obszarów daje jednorazową nagrodę 25 XP i 10 złota (Kamienny Krąg jest strefą startową bez nagrody).
- Mapa oznacza odkryte regiony i zachowuje postęp eksploracji w lokalnym zapisie.
- Zapis w wersji 3 pozostaje zgodny wstecz z wcześniejszymi zapisami wersji 1 i 2.

