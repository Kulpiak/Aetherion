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
- Wirtualny joystick w lewym dolnym rogu porusza postacią.
- **ATAK** — podstawowy atak.
- **FALA**, **PROMIEŃ** i **SZARŻA** — techniki Eterium i unik.
- **FORMA** — czasowe Przebudzenie Rdzenia.
- **HP** — użycie mikstury.
- Przyciski w prawym górnym rogu otwierają postać, torbę, umiejętności, rzemiosło, mapę i Kodeks.
- **ZADANIE** służy do rozmowy z Kronikarzem i badania ruin.
- **ZAPISZ / WCZYTAJ** obsługują lokalny zapis.

## Ikona aplikacji Android
- Dodano autorską ikonę Aetherion: kryształowe serce Eterium otoczone pięcioramiennym znakiem.
- Projekt ma osobny wariant główny, foreground i background dla Android Adaptive Icons oraz wariant monochromatyczny dla ikon tematycznych Androida 13+.
- Ikony są wektorowymi plikami SVG zintegrowanymi z `project.godot` i presetem eksportu Android.
- CI ładuje wszystkie warianty w Godot i sprawdza, czy konfiguracja wskazuje właściwe pliki oraz czy zachowano wymagane minimalne rozmiary.

## Ostatnia iteracja
- Dodano pięć autorskich herbów ras w wektorowym atlasie SVG i zintegrowano je z ekranem wyboru postaci.
- Dodano oryginalny atlas czterech glifów Eterium, zintegrowanych z telegraphami przeciwników, atakami, falą energii i Przebudzeniem Rdzenia.
- Dodano subtelne, animowane drobiny Eterium dopasowane kolorystycznie do biomów świata.
- Dodano Kodeks w grze: opis pięciu rodów, regionów i natury Eterium.
- To nadal etap rozbudowy prototypu; oprawa postaci i świata wymaga pełnego, docelowego przebudowania.

## Status projektu
To rozwijana wersja testowa offline PvE. Multiplayer, serwer, handel między graczami i synchronizacja online nie są jeszcze zaimplementowane. Każdy build traktujemy jako potwierdzony dopiero po poprawnym przejściu walidacji Godot i eksportu APK w GitHub Actions; zachowanie w grze wymaga jeszcze testu na urządzeniu.

## Oprawa wizualna regionów
- Na mapie zintegrowano osiem autorskich landmarków SVG, po jednym dla każdego regionu: Kamiennego Kręgu, Zielonych Ostępów, Korony Gór, Krypty Kryształów, Złotych Pustkowi, Wschodnich Ruin, Popielnych Ziem i Szlaku Eterium.
- Odkryte punkty otrzymują wyraźniejszą poświatę i animowany obrys; nieodkryte są subtelniejsze.
- Drobiny atmosferyczne korzystają teraz z osobnych palet kolorystycznych wszystkich ośmiu regionów.

## Eksploracja regionów
- Podczas podróży HUD pokazuje aktualny region.
- Odkrywanie nowych obszarów daje jednorazową nagrodę 25 XP i 10 złota (Kamienny Krąg jest strefą startową bez nagrody).
- Mapa oznacza odkryte regiony i zachowuje postęp eksploracji w lokalnym zapisie.
- Zapis w wersji 4 pozostaje zgodny wstecz z wcześniejszymi zapisami wersji 1–3.

## Animacje kierunkowe bohatera
- Bohater ma cztery orientacje: przód, tył i profil w obie strony. Dla wszystkich pięciu ras dodano autorskie sprite'y tyłem i z profilu, z dwiema klatkami chodu.
- Ruch ukośny korzysta z dominującej osi. Animacje kierunkowe przeciwników pozostają w planie dalszych prac.

## Animacja stworzeń
- Regionalne stworzenia i Strażnik Rdzenia korzystają z własnej fazy ruchu: sylwetki odwracają się w lewo/prawo, kołyszą podczas pościgu i otrzymują subtelne pochylenie zależne od kierunku.
- Istoty eteryczne i kryształowe unoszą się w spoczynku; przygotowanie ataku daje odrzut w tył, a cios — pochylenie do przodu. Krótkie ślady pyłu podkreślają ruch stworzeń naziemnych.
- Jest to proceduralna animacja na istniejących sprite'ach, a nie komplet nowych klatek kierunkowych. Pełne zestawy przód/tył i animowane modele pozostają w planie.

### Trwały stan regionalnych przeciwników
Lokalny zapis v4 zachowuje dla każdego regionalnego punktu odrodzenia stan pokonania, pozostałe HP, pozycję i licznik odrodzenia. Postęp walki w regionach nie resetuje się po ponownym uruchomieniu gry; starsze zapisy v1–v3 pozostają obsługiwane.

## Testy regresji
- GitHub Actions uruchamia headless test migracji zapisu v3 oraz round-trip zapisu v4 przed eksportem APK.
- Osobny test ikon Androida sprawdza konfigurację projektu i wszystkie cztery źródła ikon, ich ładowanie przez Godot i minimalne wymiary.
- Sukces eksportu i testów CI nie zastępuje jeszcze testu na fizycznym urządzeniu Android.


## Pierwsza osobna lokacja — Sanktuarium Geody
- Wejście znajduje się przy świecącym portalu w Krypcie Kryształów; przycisk **LOKACJA** służy do wejścia i powrotu.
- Sanktuarium jest osobną mapą 1280×800 z własnym wektorowym tłem, ołtarzem Geodowego Rdzenia i portalem wyjściowym.
- W środku spotkasz czterech strażników oraz bossa Matriarchę Geody. Pokonanie bossa odblokowuje rdzeń; jego zabezpieczenie daje 4 odłamki Eterium, 90 złota i 140 XP.
- Zapis v5 zachowuje oddzielnie pozycję i stan przeciwników/łupów świata głównego oraz sanktuarium. Starsze zapisy v1–v4 pozostają obsługiwane.
- To pierwsza odrębna lokacja; pozostałe regiony nie mają jeszcze własnych osobnych map.


## Druga osobna lokacja — Sanktuarium Korzeni
- W Zielonych Ostępach znajduje się portal do osobnej mapy 1280×800 z autorskim tłem przedstawiającym pradawne drzewo, sklepienie z korzeni, kamienny krąg i świetlisty basen.
- W środku walczysz z Pnączowymi Kłami, Mchowymi Wartownikami i bossem Strażnikiem Splotu. Boss ma własny sprite SVG i czytelny sygnał przygotowania ataku.
- Po pokonaniu Strażnika Splotu można oczyścić Serce Splotu: nagroda to 2 odłamki Eterium, 3 skóry bestii, 110 złota i 170 XP.
- Lokalny zapis v6 zachowuje pozycję w sanktuarium, stan pięciu przeciwników, łupy, pokonanie bossa i odebranie reliktu. Migracja zapisów v1–v5 pozostaje obsługiwana.
- GitHub Actions uruchamia osobny test Sanktuarium Korzeni przed eksportem Android APK.


## Rzemiosło — poprawka receptur i trwałość
- Poprawiono identyfikator receptury Pancerza Łowcy w przycisku warsztatu; wcześniej różnica wielkości liter mogła dodać błędną nazwę do plecaka zamiast wytworzyć wyposażenie.
- Nieznane identyfikatory receptur są odrzucane, a ponowne wytwarzanie posiadanego wyposażenia nie zużywa materiałów.
- Wytworzenie mikstury i założenie wykonanego wyposażenia zapisuje postęp od razu, bez czekania na 30-sekundowy autosave.
- CI uruchamia osobny test receptur: koszty materiałów, bonusy statystyk, duplikaty, brak materiałów oraz zapis/odczyt wytworzonego wyposażenia.

## Trzecia osobna lokacja — Sanktuarium Burzowego Kryształu
- W Koronie Gór dodano portal do osobnej mapy 1280×800 z autorskim wektorowym środowiskiem lodowych grani, aurory i centralnego ołtarza burzowego kryształu.
- W środku spotkasz Szronowe Raptory i Burzowe Odłamki oraz unikalnego bossa Władcę Burzowego Kryształu z osobnym sprite'em SVG i chłodną, niebieską sygnalizacją ataku.
- Pokonanie bossa daje 180 złota i 260 XP. Uwolnienie Serca Burzowego Kryształu daje 3 odłamki Eterium, 2 skóry bestii, 130 złota i 210 XP.
- Lokalny zapis v7 zachowuje pozycję, stan przeciwników i łupów, pokonanie bossa oraz odebranie reliktu. Migracja zapisów v1–v6 pozostaje obsługiwana.
- GitHub Actions uruchamia osobny test migracji v6, wejścia/wyjścia, izolacji stanu świata, zdrowia bossa, nagród i trwałości reliktu przed eksportem Android APK.
- To trzecia osobna lokacja; pozostałe regiony nadal wymagają własnych map i zawartości.
