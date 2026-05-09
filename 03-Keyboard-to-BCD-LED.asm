; ==============================================================================
; TYTUŁ: Konwerter Klawiatura -> BCD -> Pasek LED
; OPIS: Program odczytuje wartość wciśniętego klawisza, konwertuje ją na 
;       format BCD (Binary-Coded Decimal) i wizualizuje na diodach LED.
;
; ZAŁOŻENIA:
;   - Uproszczona obsługa klawiatury (brak walidacji wielu wciśnięć).
;   - Mapowanie bezpośrednie klawisza na wartość liczbową.
;
; HARDWARE (EdSim51):
;   - Klawiatura matrycowa (Input)
;   - Pasek LED (Output - Port 1 lub Port 3 w zależności od konfiguracji)
; ==============================================================================


start: ;etykieta startowa programu
mov p0, #0ffh ;wypełnienie p0 jedynkami w celu uniknienia nadpisania przez poprzednią iterację  
clr F0 ;ustawienie F0 jako 0 (nie znalazł)

ScanRow: ;etykieta startwa skanowania wierszy matrycy z przyciskami
	mov r0, #0 ;ustawienie R0 na 0;
	;skanowanie pierwszego wiersza
	mov p0, #0ffh ;ustawienie P0 na ffh
	clr p0.3 ;ustawienie 3-bitu P0 na 0, co umożliwi wykrysie przyciśniętego przycisku w nim
	call colScan ;wywołanie funkcji skanującej każdą kolumnę wiersza
	setb p0.3 ;ustawienie P0 na 1
	
	;skanowanie wiersza drugiego
	mov p0, #0ffh ;ustawienie P0 na ffh w celu uniknięcia nadpisania danych przez poprzednią operację
	clr p0.2 ;ustawienie P0.2 na 0 w celu przeskanowania drugiego rzędu
	call colScan ;wywołanie funkcji skanującej kolumny w rzędzie
	setb p0.2 ;ustawienie P0.2 na 1

	;skanowanie wiersza trzeciego
	mov p0, #0ffh ;ustawienie P0 na ffh w celu uniknięcia nadpisania danych przez poprzednią operację
 
	clr p0.1 ;ustawienie P0.1 na 0 w celu przeskanowania trzeciego rzędu

	call colScan ;wywołanie funkcji skanującej kolumny w rzędzie

	setb p0.1 ;ustawienie P0.1 na 1

	;skanowanie wiersza czwartego  
	mov p0, #0ffh ;ustawienie P0 na ffh w celu uniknięcia nadpisania danych przez poprzednią operację

	clr p0.0 ;ustawienie P0.0 na 0 w celu przeskanowania czwartego rzędu

	call colScan ;wywołanie funkcji skanującej kolumny w rzędzie

	setb p0.0 ;ustawienie P0.1 na 1

	;warunek sprawdzający czy znaleziono jakiś przyciśnięty przycisk
	jb f0, start ;skok warunkowy jeżeli F0 jest 1 to skacz do etykiety start

	;jeżeli F0 jest 0 to nie znalazł przyciśniętego przycisku czyli przycisk nigdy mógł być nie wciśnięty lub został i trzeba wyzerować zmienne które słóżyły interpretacji przycisku oraz wyświetlaniu
	mov A, #0 ;wyzerowanie akumulatora
	mov p1, #0ffh ;wpisanie do P1 ffh w celu zgaszenia wszystkich diud
	jmp ScanRow ;skok bezwarunkowy do etykiety scanrow

colScan: ;etykieta Colscan używana do skanowania wiersza klawiatury
	jnb p0.6, GotKey ;skok warunkowy jężeli P0.6 jest równy 0 to skocz do etykiety GotKey
	inc r0 ;inkrementacja rejestru R0
	jnb p0.5, GotKey ;skok warunkowy jężeli P0.5 jest równy 0 to skocz do etykiety GotKey

	inc r0;inkrementacja rejestru R0

	jnb p0.4, GotKey ;skok warunkowy jężeli P0.4 jest równy 0 to skocz do etykiety GotKey

	inc r0 ;inkrementacja rejestru R0

	ret ;instrukcja powrotu do miejsca wywołania funkcji


GotKey: ;etykieta GotKey
	mov A, r0 ;skopiowanie danych z R0 do akumulatora 
	;sprawdzenie czy został wciśnięty przycisk 0 
	mov b, #10 ;wprowadzenie liczby 10 do rejestru b
	subb a, b ;odjęcie liczby 10 w rejestrzeb od liczby znajdującej się w akumulatorze
	jz zero ;skok warunkowy jeżeli wartość w akumulatorze jest równa 0 to skocz do etykiety zero
	
	;sprawdzenie czy został przyciśnięty przycisk # 
	mov a, r0 ;skopiowanie danych z R0 do akumulatora
	mov b, #11 ;wprowadzenie liczby 11 do rejestru b
	subb a, b ;odjęcie liczby 11 w rejestrzeb od liczby znajdującej się w akumulatorze
	jz chasztak ;skok warunkowy jeżeli wartość w akumulatorze jest równa 0 to skocz do etykiety chasztag
	
	;przekonwertowanie indeksów przycisków na liczby odpowiadające pozostałym przyciskom
	mov a, r0 ;skopiowanie danych z R0 do akumulatora
	inc a ;inkrementacja akumulatora

	after_excpt: ;etykieta do której pzrechodą funkcje po obsudze specjalnych przycisków
	
	;konwersia na bcd
	mov r0, a ;skopiowanie danych z akumulatora do R0
	mov b, #10 ;wprowadzenie liczby 10 do rejestru b
	div ab ;dzelenie liczby zawartej w akumulatorze przez liczbę w rejestrze b zapisując wynik dzielenia w akumulatorze a resztę z dzielenia w rejestrze b
	swap a ;zamiana miejsz 4 najstarszych bitów z 4 bitami młodszymi
	orl a, b ;przeprowadzenie operacji logicznej OR na akumulatorze oraz rejestrze b
	
	;Wyświetlenie liczby BCD na pasku ledeowym
	cpl a ;inwersja bitów akumulatora 
	mov p1, a ;skopiowanie liczby z akumulatora do portu P1
	
	setb F0 ;ustawienie bitu F0 na 1
	ret ;powrót do miejsca wywołania funkcji

zero: ;etykieta obsługująca przycisk który odpowiada za 0
	mov r0, #0 ;wprowadzenie liczby 0 do rejestru R0
	jmp after_excpt ;skok bezwarunkowy do etykiety after_except
chasztak: ;etykieta obsługująca przycisk odpowidający z #
	mov A, R0 ;skopiowanie danych z R0 do akumulatora
	jmp after_excpt ;skok bezwarunkowy do etykiety after_except

