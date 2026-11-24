# Aetherion — status projektu

## Kierunek
- Godot 4.4.1, GDScript, Android, 2D top-down, orientacja pozioma.
- Pierwszy cel: kompletna gra offline/PvE; multiplayer dopiero po ustabilizowaniu gry.
- Autorskie uniwersum i systemy, bez kopiowania chronionych postaci, nazw ani assetów.

## Zaimplementowane w prototypie
- Wybór jednej z pięciu ras, lokalny zapis i odczyt postępu.
- Ruch dotykowy, kamera śledząca gracza i duży świat 1920×1440.
- Walka podstawowa, fala obszarowa, promień, szarża i czasowa transformacja.
- Przeciwnicy z ruchem do gracza, atakiem, reakcją na trafienie, odradzaniem i dropem.
- Obrażenia wyświetlane nad celem, efekty trafień, aura transformacji i animowany promień.
- Strażnik Rdzenia z większą sylwetką, aurą i paskiem zdrowia bossa.
- Zadania startowe, Kronikarz, rozwój postaci, złoto, ekwipunek, mikstury i crafting.
- Panel mapy z ilustracją świata, nazwami regionów i znacznikiem celu zadania.
- Paski HP/Eterium, przebudowane przyciski walki oraz stylizowane okna UI.

## Ostatnia iteracja — spójna progresja doświadczenia
- Dodano wspólną funkcję `_grant_xp(amount)` dla nagród z walki, bossów i zadań.
- Każde źródło XP korzysta teraz z tego samego progu awansu i identycznego wzrostu HP, Eterium, ataku oraz obrony.
- Usunięto rozbieżność, w której nagrody z zadań mogły zwiększać XP bez natychmiastowego awansu i aktualizacji statystyk.

## Ostatnia iteracja — czytelne telegraphowanie ataków przeciwników
- Przeciwnicy zatrzymują się przed atakiem i sygnalizują go przez 0,52 s; Strażnik Rdzenia ma dłuższe przygotowanie 0,82 s i większy obszar ostrzegawczy.
- Zwykłe ciosy pokazują kierunek zagrożenia, a atak bossa zaznacza obszar na ziemi.
- Obrażenia są rozstrzygane dopiero po zakończeniu przygotowania, więc odejście poza zasięg pozwala uniknąć ciosu.
- Aktywna Szarża zapewnia unik podczas animacji doskoku; przeciwnik nadal wykonuje widoczny atak, ale nie zadaje wtedy obrażeń.

## Iteracja Android — oryginalna ikona aplikacji
- Dodano autorską ikonę Aetherion z kryształowym sercem Eterium i pięcioramiennym znakiem, w spójnej palecie granatu, turkusu i złota.
- Przygotowano cztery źródła SVG: klasyczną ikonę 512×512, foreground 432×432, background 432×432 i monochromatyczny foreground 432×432.
- `project.godot` wskazuje ikonę projektu, a `export_presets.cfg` dostarcza komplet wariantów Android Adaptive Icons i ikon tematycznych.
- Dodano `tests/test_android_icons.gd`; CI sprawdza zgodność ścieżek, ładowanie tekstur i minimalne rozmiary przed eksportem APK.
- To ikona aplikacji i nie zastępuje docelowych sprite'ów postaci, animacji ani środowisk.

## W trakcie przebudowy i walidacji
- Kolejne iteracje wyglądu oraz czytelności interfejsu na rzeczywistych ekranach Androida.
- Pełne animacje kierunkowe przeciwników; obecna iteracja dodaje proceduralny chód, odwracanie sylwetki i pochylenia, ale nie osobne arkusze przód/tył.
- Dopracowanie regionów jako odrębnych, eksplorowalnych obszarów z własnymi zawartościami.
- Testy na fizycznym telefonie, wydajność, skalowanie i ergonomia dotyku.

## Ograniczenia, których nie ukrywamy
- Obecne sprite'y są wstępną grafiką atlasową, a nie finalną, wysokiej jakości grafiką anime.
- Świat jest obecnie jedną mapą, nie zestawem kompletnych osobnych lokacji i wnętrz.
- Gra jest offline PvE. Nie ma jeszcze serwera, kont online, gildii, czatu, handlu ani PvP.
- Sukces GitHub Actions potwierdza walidację i eksport APK w CI; nie zastępuje testu na fizycznym urządzeniu.

## Zasada jakości
Nie oznaczamy funkcji jako gotowych ani APK jako przetestowanego, dopóki nie przejdą odpowiedniego builda i testów. Każdy etap musi mieć możliwy do sprawdzenia rezultat.

## Iteracja grafiki — herby pięciu ras
- Dodano nowy, oryginalny atlas wektorowych herbów pięciu ras: kompas słoneczny Terranów, płomienne kły Varkari, kryształowe skrzydła Elarian, żywy liść Sylvari oraz księżycowy znak Noctari.
- Atlas SVG jest ładowany bezpośrednio przez Godot i wyświetlany w kartach wyboru postaci obok nazwy rasy; nie jest to osobna grafika poglądowa.
- Zachowano dotychczasowy atlas sylwetek i statystyki ras. Zasoby są wektorowe, więc skalują się bez utraty ostrości na ekranach Androida.
- To pierwszy z etapów wymiany oprawy; nie zastępuje jeszcze pełnych animowanych modeli i docelowych środowisk.

## Iteracja oprawy walki — glify Eterium
- Dodano autorski atlas SVG z czterema glifami: kręgiem runicznym, cięciem energii, rozbłyskiem uderzenia i znakiem Przebudzenia.
- Glify są renderowane bezpośrednio w scenie: pojawiają się podczas przygotowania ataków przeciwników, przy ataku podstawowym i Promieniu, w fali obszarowej oraz w aurze i impulsie aktywacji Przebudzenia Rdzenia.
- Zachowano wektorowe źródła i skalowanie bez utraty ostrości; efekty nie wymagają dodatkowych węzłów sceny ani ciężkich shaderów.

## Iteracja eksploracji — odkrywanie regionów
- Dodano osiem logicznych stref świata: Kamienny Krąg, Zielone Ostępy, Korona Gór, Krypta Kryształów, Złote Pustkowia, Wschodnie Ruiny, Popielne Ziemie i Szlak Eterium.
- HUD pokazuje aktualną strefę, a wejście do nieodkrytego regionu wyświetla komunikat i — poza początkowym Kamiennym Kręgiem — przyznaje jednorazowo 25 XP oraz 10 złota.
- Mapa pokazuje liczbę i listę odkrytych regionów. Odkrycia są zapisywane lokalnie.
- Format zapisu podniesiono do wersji 3; odczyt nadal akceptuje wersje 1 i 2.

## Iteracja oprawy świata — autorskie landmarki regionów
- Dodano wektorowy atlas ośmiu oryginalnych landmarków: kamiennego strażnika kręgu, prastare drzewo, lodowy szczyt, kryształową kryptę, pustynne sanktuarium, obserwatorium ruin, bazaltową iglicę i monolit Eterium.
- Każdy landmark jest renderowany bezpośrednio na mapie w odpowiadającym mu regionie. Odkryte regiony otrzymują wyraźniejszą poświatę i animowany obrys; nieodkryte punkty są subtelniejsze.
- Drobiny atmosferyczne otrzymały osobne palety barw dla wszystkich ośmiu regionów.
- Mapa nadal jest jedną wspólną lokacją, a landmarki nie zastępują pełnych, osobnych biomów i ich zawartości.

## Iteracja zawartości regionów — lokalne bestiariusze
- Dodano autorski atlas SVG z 14 odrębnymi sylwetkami stworzeń: po dwa gatunki dla każdego z siedmiu niebezpiecznych regionów.
- Na mapie pojawia się 18 spotkań rozmieszczonych w rodzimych strefach; nagrody XP i złota skalują się z siłą regionalnego przeciwnika.
- Kodeks zawiera spis regionalnej fauny.
- Każde z 18 spotkań ma stabilny `spawn_id`; zapis v4 zachowuje HP, pozycję, stan życia i licznik odrodzenia.

## Iteracja animacji bohatera — cztery kierunki
- Dodano oryginalny wektorowy atlas 640×512 z widokami od tyłu i z profilu dla wszystkich pięciu ras; każda orientacja ma dwie klatki chodu.
- Bohater używa dotychczasowego atlasu frontowego przy ruchu w dół, nowych sprite'ów tyłem przy ruchu w górę oraz profilu przy ruchu w lewo/prawo.
- Ruch ukośny wybiera dominującą oś.

## Iteracja animacji regionalnej fauny — orientacja i ruch
- Wszystkie 14 regionalnych stworzeń oraz Strażnik Rdzenia korzystają z animacji ruchu zależnej od własnej fazy chodu.
- Sylwetki odwracają się w lewo/prawo, kołyszą, pochylają przy ataku; istoty eteryczne i kryształowe unoszą się w spoczynku.
- To proceduralna animacja na istniejących sprite'ach, bez pełnych nowych klatek kierunkowych.

## Iteracja zapisu świata — trwały stan regionalnych przeciwników
- Lokalny zapis v4 przechowuje HP, pozycję, stan życia i czas odrodzenia 18 regionalnych spotkań.
- Stan regionalnej fauny jest zapisywany również natychmiast po pokonaniu przeciwnika.
- Starsze zapisy v1–v3 pozostają obsługiwane.

## Iteracja jakości — regresja lokalnego zapisu
- Dodano headless test integracyjny `tests/test_enemy_save.gd`, uruchamiany przez GitHub Actions przed eksportem APK.
- Build #95 zaliczył wszystkie 12 asercji migracji i odtwarzania zapisu.
- Test automatyczny nie zastępuje testu zapisu na rzeczywistym Androidzie.


## Korekta ikon Android — bezpieczny obszar adaptacyjny
- Zmniejszono znak na warstwie foreground i monochromatycznej do 92% skali, zachowując środek kompozycji; istotne elementy mieszczą się teraz w centralnej strefie ochronnej Android Adaptive Icons.
- Wariant główny pozostaje pełną kompozycją kwadratową, a tło adaptacyjne nie zawiera elementów krytycznych dla rozpoznawalności znaku.


## Iteracja świata — osobna lokacja Sanktuarium Geody
- Dodano odrębną, eksplorowalną instancję 1280×800 dostępną przez portal w Krypcie Kryształów; ma własną mapę SVG, kryształowe filary, centralny ołtarz i portal powrotny.
- Lokacja ma czterech strażników (Kryształowe Pająki i Eterowi Skrybowie) oraz unikalnego bossa Matriarchę Geody z osobnym sprite'em SVG.
- Pokonanie Matriarchy odblokowuje Geodowy Rdzeń; jego zabezpieczenie daje 4 odłamki Eterium, 90 złota i 140 XP.
- Przejście zachowuje dokładną pozycję gracza, stan przeciwników i łupy obu map. Zapis podniesiono do v5; starsze wersje v1–v4 wczytują się do świata głównego z domyślnym stanem sanktuarium.
- Dodano test headless przejścia, walki z bossem, nagrody, zapisu i powrotu. Test CI ma potwierdzić tę iterację przed udostępnieniem nowego APK.
- To pierwsza osobna lokacja, nie komplet ośmiu osobnych biomów. Pozostałe regiony nadal korzystają z jednej mapy świata.


## Druga osobna lokacja — Sanktuarium Korzeni
- W Zielonych Ostępach dodano drugi portal prowadzący do odrębnej mapy 1280×800 z autorskim tłem SVG: starożytny krąg korzeni, kamienny ołtarz, świetlisty basen i organiczne sklepienie.
- Sanktuarium zawiera czterech strażników (Pnączowe Kły i Mchowych Wartowników) oraz unikalnego bossa Strażnika Splotu z osobnym sprite'em SVG.
- Pokonanie Strażnika Splotu odblokowuje Serce Splotu. Oczyszczenie reliktu daje 2 odłamki Eterium, 3 skóry bestii, 110 złota i 170 XP.
- Zapis v6 zachowuje osobno stan przeciwników, łupów, bossa i reliktu Sanktuarium Korzeni, a także pozycję gracza wewnątrz lokacji. Zapisy v1–v5 są nadal obsługiwane.
- Dodano headless test migracji v5 oraz pełnego cyklu wejścia, walki, zapisu, nagrody i powrotu; test jest częścią workflow Android przed eksportem APK.
- To druga osobna lokacja. Pozostałe regiony nadal wymagają własnych map, a grafika bohaterów i fauna potrzebują dalszych pełnych animacji i docelowego dopracowania.


## Iteracja walki — Strażnik Splotu: Więzy Korzeni
- Dodano odrębną technikę obszarową bossa Sanktuarium Korzeni: po 1,05 s ostrzeżenia tworzy eliptyczne pole korzeni o promieniach 126×74 jednostki, blokujące zapamiętaną pozycję gracza zamiast śledzić go w trakcie ostrzeżenia.
- Uderzenie rozstrzyga się w zapisanym punkcie; opuszczenie pola lub aktywna Szarża Eterium pozwala uniknąć obrażeń. Trafienie korzysta ze wspólnej redukcji obrażeń i nietykalności.
- Ostrzeżenie i uderzenie otrzymały osobną zieloną oprawę wektorową, rozróżniającą tę technikę od czerwonego ataku Strażnika Rdzenia i lodowej Burzowej Nawałnicy.
- Dodano `tests/test_rootwarden_combat.gd` i etap CI przed testami Sanktuarium Burzowego Kryształu.
- Test obejmuje obecność bossa, parametry pola, blokadę celu, możliwość ucieczki, obrażenia po trafieniu, unik Szarżą i ochronę przez nietykalność.
