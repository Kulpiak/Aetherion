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
- Zachowano wektorowe źródła i skalowanie bez utraty ostrości; efekty nie wymagają dodatkowych węzłów ani ciężkich shaderów, co ogranicza koszt na Androidzie.
- To zintegrowane efekty walki, nie finalna wymiana sprite'ów bohaterów i pełnych animacji kierunkowych.

## Iteracja eksploracji — odkrywanie regionów
- Dodano osiem logicznych stref świata: Kamienny Krąg, Zielone Ostępy, Korona Gór, Krypta Kryształów, Złote Pustkowia, Wschodnie Ruiny, Popielne Ziemie i Szlak Eterium.
- HUD pokazuje aktualną strefę, a wejście do nieodkrytego regionu wyświetla komunikat i — poza początkowym Kamiennym Kręgiem — przyznaje jednorazowo 25 XP oraz 10 złota.
- Mapa pokazuje liczbę i listę odkrytych regionów. Odkrycia są zapisywane lokalnie.
- Format zapisu podniesiono do wersji 3; odczyt nadal obsługuje zapisy wersji 1 i 2, a brakujące dane eksploracji są bezpiecznie uzupełniane bez naliczania wstecznych nagród.



## Iteracja oprawy świata — autorskie landmarki regionów
- Dodano wektorowy atlas ośmiu oryginalnych landmarków: kamiennego strażnika kręgu, prastare drzewo, lodowy szczyt, kryształową kryptę, pustynne sanktuarium, obserwatorium ruin, bazaltową iglicę i monolit Eterium.
- Każdy landmark jest renderowany bezpośrednio na mapie w odpowiadającym mu regionie. Odkryte regiony otrzymują wyraźniejszą poświatę i animowany obrys; nieodkryte punkty są subtelniejsze.
- Drobiny atmosferyczne otrzymały osobne palety barw dla wszystkich ośmiu regionów, zamiast kilku ogólnych warunków kolorystycznych.
- Atlas jest wektorowy SVG i nie dodaje osobnych węzłów sceny ani ciężkich efektów post-processingu.
- To pierwszy wizualny pass wyróżniający regiony; mapa nadal jest jedną wspólną lokacją, a landmarki nie zastępują pełnych, osobnych biomów i ich zawartości.

## Iteracja zawartości regionów — lokalne bestiariusze
- Dodano autorski atlas SVG z 14 odrębnymi sylwetkami stworzeń: po dwa gatunki dla każdego z siedmiu niebezpiecznych regionów.
- Zielone Ostępy, Korona Gór, Krypta Kryształów, Złote Pustkowia, Wschodnie Ruiny, Popielne Ziemie i Szlak Eterium otrzymały własne nazwy przeciwników, wygląd, zdrowie, obrażenia i szybkość.
- Na mapie pojawia się 18 spotkań rozmieszczonych w rodzimych strefach; po pokonaniu przeciwnicy odradzają się w obrębie swojej strefy.
- Nagrody XP i złota skalują się z siłą regionalnego przeciwnika. Kamienny Krąg pozostaje bezpiecznym obszarem bez zwykłych wrogów.
- Kodeks zawiera teraz spis regionalnej fauny. Strażnik Rdzenia nadal korzysta z dotychczasowego sprite'a bossa i własnego stanu zapisu.
- Zwykłe spotkania są odtwarzane przy rozpoczęciu sesji; nie dodano jeszcze osobnych map regionów ani trwałego zapisu stanu każdego zwykłego przeciwnika.


## Iteracja animacji bohatera — cztery kierunki
- Dodano oryginalny wektorowy atlas 640×512 z widokami od tyłu i z profilu dla wszystkich pięciu ras; każda orientacja ma dwie klatki animacji.
- Bohater używa dotychczasowego atlasu frontowego przy ruchu w dół, nowych sprite'ów tyłem przy ruchu w górę oraz profilu przy ruchu w lewo/prawo (profil jest lustrzany dla lewej strony).
- Klatki chodu są wybierane zgodnie z ruchem; zachowano tint trafienia, migotanie nietykalności i efekty Przebudzenia Rdzenia.
- Kierunek ukośny wybiera dominującą oś, więc animacja jest czterokierunkowa, a nie ośmiokierunkowa.
- Zmiana dotyczy bohatera. Regionalne stworzenia i boss nadal wymagają osobnych zestawów animacji kierunkowych; atlas nie zastępuje jeszcze docelowych animowanych modeli anime.


## Iteracja animacji regionalnej fauny — orientacja i ruch
- Wszystkie 14 regionalnych stworzeń oraz Strażnik Rdzenia korzystają teraz z animacji ruchu zależnej od własnej fazy chodu, zamiast wspólnego przełączania klatek według zegara globalnego.
- Sylwetki odwracają się poziomo zgodnie z kierunkiem pościgu; ruch pionowy otrzymuje subtelne pochylenie, a krok jest wspierany przez niezależne kołysanie, squash/stretch i krótkie ślady pyłu.
- Stworzenia eteryczne i kryształowe otrzymały spokojniejszy, unoszący się ruch spoczynkowy. Przygotowanie ataku odsuwa sylwetkę w kierunku przeciwnym do celu, a sam cios pochyla ją do przodu.
- Zachowano istniejące telegraphy, obrażenia, błysk trafienia, paski HP i oryginalne atlasowe sylwetki.
- To lekka animacja proceduralna na bazie obecnych sprite'ów, bez pełnych nowych klatek i bez czterokierunkowych arkuszy dla każdego stworzenia. Docelowe animowane modele i osobne pozy przód/tył nadal pozostają do wykonania.


## Iteracja zapisu świata — trwały stan regionalnych przeciwników
- Podniesiono format lokalnego zapisu do wersji 4; odczyt nadal akceptuje wersje 1–3.
- Każdy z 18 regionalnych punktów odrodzenia ma stabilny identyfikator, dzięki czemu zapis nie zależy od losowej pozycji przeciwnika ani kolejności jego ruchu.
- Zapis przechowuje dla zwykłych przeciwników aktualne HP, pozycję, stan życia oraz postęp 18-sekundowego odrodzenia. Po wczytaniu przywracane są dane świata, a chwilowe animacje i przygotowania ataków są bezpiecznie resetowane.
- Stan regionalnej fauny jest zapisywany również natychmiast po pokonaniu przeciwnika, oprócz autosave i zapisu przy pauzie/zamknięciu.
- Strażnik Rdzenia nadal korzysta z osobnego mechanizmu zapisu bossa; nowy zapis regionalny go nie nadpisuje.
- Stare zapisy bez pola `enemy_states` zachowują dotychczasowe zachowanie i rozpoczynają regionalne spotkania od wartości początkowych.
