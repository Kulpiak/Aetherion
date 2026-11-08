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
- Lepsze, pełne animacje kierunkowe postaci i przeciwników.
- Dopracowanie regionów jako odrębnych, eksplorowalnych obszarów z własnymi zawartościami.
- Testy na fizycznym telefonie, wydajność, skalowanie i ergonomia dotyku.

## Ograniczenia, których nie ukrywamy
- Obecne sprite'y są wstępną grafiką atlasową, a nie finalną, wysokiej jakości grafiką anime.
- Świat jest obecnie jedną mapą, nie zestawem kompletnych osobnych lokacji i wnętrz.
- Gra jest offline PvE. Nie ma jeszcze serwera, kont online, gildii, czatu, handlu ani PvP.
- Sukces GitHub Actions potwierdza walidację i eksport APK w CI; nie zastępuje testu na fizycznym urządzeniu.

## Zasada jakości
Nie oznaczamy funkcji jako gotowych ani APK jako przetestowanego, dopóki nie przejdą odpowiedniego builda i testów. Każdy etap musi mieć możliwy do sprawdzenia rezultat.
