; ==============================================================================
; TYTUŁ: Dzielenie liczb z klawiatury matrycowej z walidacją wejścia
; OPIS: Program pobiera dane z klawiatury (wiersz 1 i 2), wykonuje dzielenie 
;       i wyświetla resztę na wyświetlaczu 7-segmentowym.
;
; LOGIKA WALIDACJI:
;   - Wyświetla wynik tylko, gdy wciśnięto dokładnie 1 klawisz w wierszu 1 i 2.
;   - Wyświetla "-" w przypadku błędu (zbyt wiele klawiszy lub ich brak).
;
; HARDWARE (EdSim51):
;   - Klawiatura matrycowa (skanowanie wierszy)
;   - Wyświetlacz 7-segmentowy (dekodowanie wzorca cyfr)
; ==============================================================================

;deklaracja komurek w pamięci żeby wyświetlać liczby na wyświetlaczu
mov 30h, #11000000b ;zero
mov 31h, #11111001b ;jeden
mov 32h, #10100100b ;dwa
mov 33h, #10110000b ;trzy 
mov 34h, #10011001b ;cztery
mov 35h, #10010010b ;pięć
mov 36h, #10000010b ;sześć
mov 37h, #11111000b ;siedem
mov 38h, #10000000b ;osiem
mov 39h, #10010000b ;dziewięć
mov 3ah, #0 ;kropka

mov r7, #30h ;przypisanie adresu pamięci do R7

;ustawienie wyświetlacza prawego
clr p3.4 ;wyzerowanie p3.4
clr p3.3 ;wyzerowanie p3.3


;deklaracja flag używanych do znajdowania błędnych kombinacji przycisków
ignore_flag equ p2.7 ;flaga jeżeli są wciśnięte przyciski w 3 i 4 to je ignoruje 
not_row_12 equ p2.6 ;flaga jeżei 2 lub więcej przycisków jest wciśnięte w wierszu 


start: ;etykieta startowa programu
	;przygotowanie programu do startu (wyzerowanie używanych rejestrów)
	mov R3, #0 ;wyzerowanie rejestru R3
	mov R2, #0 ;wyzerowanie rejestru R2
	mov R0, #0 ;wyzerowanie rejestru R0
	mov R1, #0 ;wyzerowanie rejestru R1
	mov R4, #0 ;wyzerowanie rejestru R4
	clr not_row_12 ;wyzerowanie flagi
	clr ignore_flag ;wyzerowanie flagi
	mov p0, #0ffh ;wypełnienie p0 jedynkami w celu uniknienia nadpisania przez poprzednią iterację  
	clr F0 ;ustawienie F0 jako 0 (nie znalazł)

ScanRow: ;etykieta startwa skanowania wierszy matrycy z przyciskami
	clr f0  ;ustawienie F0 jako 0 (nie znalazł)
	clr ignore_flag ;wyzerowanie flagi
	mov r0, #0 ;ustawienie R0 na 0;
	;skanowanie pierwszego wiersza
	mov p0, #0ffh ;ustawienie P0 na ffh
	clr p0.3 ;ustawienie 3-bitu P0 na 0, co umożliwi wykrysie przyciśniętego przycisku w nim
	call colScan ;wywołanie funkcji skanującej każdą kolumnę wiersza
	setb p0.3 ;ustawienie P0 na 1
	
	;skanowanie wiersza drugiego
	setb F0
	mov p0, #0ffh ;ustawienie P0 na ffh w celu uniknięcia nadpisania danych przez poprzednią operację
	clr p0.2 ;ustawienie P0.2 na 0 w celu przeskanowania drugiego rzędu
	call colScan ;wywołanie funkcji skanującej kolumny w rzędzie
	setb p0.2 ;ustawienie P0.2 na 1

	;skanowanie wiersza trzeciego
	setb ignore_flag
	mov p0, #0ffh ;ustawienie P0 na ffh w celu uniknięcia nadpisania danych przez poprzednią operację
	clr p0.1 ;ustawienie P0.1 na 0 w celu przeskanowania trzeciego rzędu
	call colScan ;wywołanie funkcji skanującej kolumny w rzędzie
	setb p0.1 ;ustawienie P0.1 na 1

	;skanowanie wiersza czwartego  
	mov p0, #0ffh ;ustawienie P0 na ffh w celu uniknięcia nadpisania danych przez poprzednią operację
	clr p0.0 ;ustawienie P0.0 na 0 w celu przeskanowania czwartego rzędu
	call colScan ;wywołanie funkcji skanującej kolumny w rzędzie
	setb p0.0 ;ustawienie P0.1 na 1
	
	jmp check ;skok bezwarunkowy do etykiety check która sprawdza czy kombinacja przycisków są prawidłowe
	done: ;etykieta powrotna z etykiety check 
	jmp ScanRow ;skok bezwarunkowy do etykiety scanrow

colScan: ;etykieta Colscan używana do skanowania wiersza klawiatury
	mov R4, #0 ;wyzerowanie rejestru R4 który zlicza ile prztycików jest wciśniętych w wierszu
	;skanowanie wierszy jest zmodyfikowane w taki sposób żeby użyta została "funkcja" w celu powrotu z niej w to miejsce z którego została wywołana nie było by to możliwe przy użyciu tylko instrukcji skoku warunkowego albo było by to bardziej skomplikowane
	jb p0.6, next1 ; skok warunkowy jeżeli p0.6 jest 1 to skocz do next1
	call GotKey ;wywołanie funkcji GotKey
	next1: ;etykieta next1
	inc r0 ;inkrementacja pozycji znaku na klawiaturze

	jb p0.5, next2; skok warunkowy jeżeli p0.5 jest 1 to skocz do next2
	call GotKey ;wywołanie funkcji GotKey
	next2: ;etykieta next1
	inc r0	;inkrementacja pozycji znaku na klawiaturze

	jb p0.4, next3; skok warunkowy jeżeli p0.4 jest 1 to skocz do next3
	call GotKey;wywołanie funkcji GotKey
	next3: ;etykieta next1
	inc r0;inkrementacja pozycji znaku na klawiaturze

	
	cjne R4, #0,more_keys_in_row ;skok warunkowy jeżli R4 nie jest równe 0 to skocz do more_keys_in_row (wykrycie że wciśnięto 1 lub więcej przycisków w wierszu)
	
	all_good:;etykieta powrotna z more_keys_in_row
	ret ;instrukcja powrotu do miejsca wywołania funkcji



more_keys_in_row: ;"funkcja" more_keys_in_row (wykrywa czy jeden przycisk jest wciśnięty czy więcej w wierszu)
	cjne R4, #1, no_good ;skok warunkowy jeżeli R4 nie jest równy 1 to skocz do no_good
	jmp all_good ;skok bezwarunkowy do all_good
	no_good: ;etykieta no_good (jeżeli jest więcej przycisków wciśniętych w wierszu)
	inc R1 ;inkrementacja R1
	jmp all_good ;skok bezwarunkowy do etykiety all_good

none: ;etykieta odpowiedzialna za wyświetlenie znaku - kiedy jest nieprawidłowa kombinacja przycisków wciśnięta
	mov p1, #0bfh ;przypisanie do p1 bfh
	jmp next ;skok bezwarunkowy do etykiety next

GotKey: ;etykieta GotKey (etykieta odpowiedzialna za obróbkę wciśniętego przycisku)
	;;tutaj coś będzie
	jb ignore_flag, ignore ;skok warunkowy jeżeli flaga ignore_flag jest 1 to skacz do ignoruj (żeżeli przycisk jest w wierszach 3 lub 4)
	jnb f0, first_column ;skok warunkowy jeżeli F0 jest 0 to skocz do first column 
	;przypisanie indeksu przycisku znajdującego się w wierszu 2 do R3
	mov A, R0 ;skopiowanie liczby z R0 do akumulatora 
	mov R3, A ;skopiowanie liczby z akumulatora do R3
	jmp second_column ; skok bezwarunkowy do secodn column
	first_column: ;etykieta first_column
	;przypisanie indeksu przycisku z pierwszego wiersza do R2
	mov A, R0 ;skopiowanie liczby z R0 do akumulatora 
	mov R2, A ;skopiowanie liczby z akumulatora do R2

	second_column: ;etykieta second_column
	inc R1 ;inkrementacja rejestru R1 odpowiedzialnego za liczbę wciśniętych przycisków
	inc r4 ;inkrementacja rejestru R4 odpoweidzialnego za liczbę wciśniętych przycisków w wierszu
	
	from_ignore: ;etykieta powrotna z etykiety ignore 
	ret ;powrót do miejsca wywołania funkcji

ignore: ;etykieta ignore 
	setb not_row_12 ;ustawienie flagi not_row_12 na 1
jmp from_ignore ;skok bezwarunkowy do From_ignore

check: ;etykieta chech odpowiedzialna za sprawdzenie czy jest wciśnięta właściwa kombinacja przycisków oraz za wyświetlanie liczb na wyświetlaczu
	jb not_row_12, none ;skok warunkowy jeżeli not_row_12 jest 1 to skacz do none
	;sprawdzenie ilości przyciśniętych przycisków na klawiaturze
	mov A, r1 ;skopiowanie liczby wciśniętych przycisków z R1 do akumulatora
	mov b, #2 ;przypisanie 2 do rejestru b
	subb a, b ;odjęcie liczby w rejestrze B od liczby w akumulatorze
	;sprawdzenie czy operacja ta zotsała zrobiona bez przenoszenia (0-1) 
	jnb CY, no_overflow ;skok warunkowy jeżeli flaga CY jest 0 skocz do no_overflow
	clr CY ;wyzerowanie flafi CY
	no_overflow: ;etykieta no_overflow
	jnz none ;skok warunkowy jeżeli akumulator nie jest 0 to skacz do none

	;miejsce w którym przyciski zostały odczytane poprawnie 
	mov p1, #0ffh ;przypisasnie ffh do p1 w celu zgaszenia wyświetlacza
	;zamiana zapisanych indeksów przycisków na odpowiadające im liczby 
	inc R3 ;inkrementacja rejestru R3
	inc R2;inkrementacja rejestru R2

	;przygotowanie liczb do operacji dzielenia
	mov A, R3 ;przypisanie liczby z rejestru R3 do akumulatora (liczba z 2 wiersza)
	mov b, R2 ;przypisanie liczby z rejestru R2 do rejestru b (liczba z 1 wiersza)
	div ab ; wykonanie dzielenia
	;;reszta z dzielenia w b
	;wyświetlenie reszty z dzielenia na wyświetlaczu	
	mov A, b ;przypisanie do akumulatora rejestru b
	add a, R7 ;dodanie liczby z akumulatora do rejestru R7 (dodanie reszty z dzielenia do adresu liczby odpowiedzialnej z wyświetlanie)
	mov r1, a ;przypisanie liczby z akumulatora do rejestru R1
	mov a, @R1 ;przypisanie liczby znajdującej się pod adresem pamięci zawartym w R1
	;wyświetlenie reszty z dzielenia na wyświetlaczu
	mov p1, a ;przypisanie portom p1 liczby z akumulatora
	
	next: ;etykieta next (kiedy nie jest poprawna kombinacja na klawiaturze)
	;przygotowanie do kolejnego skanowania klawiatury
	mov r1, #0 ;przypisanie do R1 0
	mov R4, #0 ;przypisanie do R4 0
	clr not_row_12 ;wyczyszczenie flagi not_ro_12
	jmp done ;skok bezwarunkowy do etykiety done

