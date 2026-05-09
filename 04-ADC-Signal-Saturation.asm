; ==============================================================================
; TYTUŁ: Akwizycja i Przetwarzanie Sygnałów ADC (8051)
; OPIS: System czasu rzeczywistego pobierający próbki z przetwornika ADC,
;       realizujący wzmocnienie programowe z algorytmem nasycenia (saturation).
;
; MECHANIZMY SPRZĘTOWE:
;   - INT0: Przerwanie zewnętrzne wyzwalające odczyt próbki.
;   - Port P2: Wejście danych z przetwornika ADC (8-bit).
;   - Port P0: Wyjście na oscyloskop (DAC).
;   - SW0-SW3: Wejście dla współczynnika wzmocnienia (Gain).
; ==============================================================================

ORG 0000H ;Ustawienie adresu startowego skoku do początku programu
	LJMP start ;skok do etykiety programu startowego

ORG 0003H ;miejsce w pamięci gdzie obsługiwane jest przerwania z zerwnątrz od ADC
	LJMP przerwanie ;Skok do obsługi przerwania ADC

ORG 0100H ; Ustawanie adresu poczatkowego gdzie znajduje się program żeby nie nadpisać skoku przerwania
start: ;Etykieta strtowa
	setb p3.2 ;Wyzerowania flagi przerwania
  SETB IT0 ; Ustawienie przerwania żeby wyzwalane zostało zboczem opadającym
  SETB EX0 ; Odblokowanie przerwania 0
  SETB EA  ; odblokowanie globalnych przerwań
  MOV P2, #0FFH ; Ustawienie P2 jako wejście dla ADC
	MOV P1, #0FFH ; Ustawanie P1 jako wejście dla przełączników SW
  SETB P3.7; RD domyślnie w stanie wysokim
  CLR P3.6 ; WR domyślnie w stanie niskim

loop: ; główna pętla programu
	;wyzwalanie zboczem opadającym ADC
	CLR P3.6
	SETB P3.6          
	;pętla która daje czas na odpowiedź ADC
	MOV R6, #100
	DJNZ R6, $
	SJMP loop

przerwanie: ;Etykieta przerwania z ADC
	CLR P3.7; RD = 0: Dane z ADC pojawiają się na P2
	MOV A, P2; Kopiuj dane z ADC do Akumulatora
	SETB P3.7; RD = 1: Koniec odczytu
	mov r1, A ; kopia danych z Acc
	mov A, p2 ;pobranie wzmocnienia
	cpl A ;ODwrócenie bitów wzmocnienia (logika odwrotna)
	anl A, #00001111b ;Maskowanie acc bo obsługa tylko sw0-sw3
	mov b, R1 ;pobranie wartości próbki
	mul ab ;mnożenie próbka * wzmocnienie
	jb psw.2, przepelnienie ; Wykreycie przepełnienia
	mov p1, Acc ; kopia danych na wejście DAC
	clr p0.7 ;Włączenie oscyloskopu
	reti ; powrót do pętli głównej
	przepelnienie: ;etykieta obsługująca przepełnienie
	mov p1, #255 ; danie na wejście DAC 255
	clr p0.7 ;Włączenie oscyloskopu
reti ; powrót do pętli głównejORG 0000H ;Ustawienie adresu startowego skoku do początku programu
	LJMP start ;skok do etykiety programu startowego

ORG 0003H ;miejsce w pamięci gdzie obsługiwane jest przerwania z zerwnątrz od ADC
	LJMP przerwanie ;Skok do obsługi przerwania ADC

ORG 0100H ; Ustawanie adresu poczatkowego gdzie znajduje się program żeby nie nadpisać skoku przerwania
start: ;Etykieta strtowa
	setb p3.2 ;Wyzerowania flagi przerwania
  SETB IT0 ; Ustawienie przerwania żeby wyzwalane zostało zboczem opadającym
  SETB EX0 ; Odblokowanie przerwania 0
  SETB EA  ; odblokowanie globalnych przerwań
  MOV P2, #0FFH ; Ustawienie P2 jako wejście dla ADC
	MOV P1, #0FFH ; Ustawanie P1 jako wejście dla przełączników SW
  SETB P3.7; RD domyślnie w stanie wysokim
  CLR P3.6 ; WR domyślnie w stanie niskim

loop: ; główna pętla programu
	;wyzwalanie zboczem opadającym ADC
	CLR P3.6
	SETB P3.6          
	;pętla która daje czas na odpowiedź ADC
	MOV R6, #100
	DJNZ R6, $
	SJMP loop

przerwanie: ;Etykieta przerwania z ADC
	CLR P3.7; RD = 0: Dane z ADC pojawiają się na P2
	MOV A, P2; Kopiuj dane z ADC do Akumulatora
	SETB P3.7; RD = 1: Koniec odczytu
	mov r1, A ; kopia danych z Acc
	mov A, p2 ;pobranie wzmocnienia
	cpl A ;ODwrócenie bitów wzmocnienia (logika odwrotna)
	anl A, #00001111b ;Maskowanie acc bo obsługa tylko sw0-sw3
	mov b, R1 ;pobranie wartości próbki
	mul ab ;mnożenie próbka * wzmocnienie
	jb psw.2, przepelnienie ; Wykreycie przepełnienia
	mov p1, Acc ; kopia danych na wejście DAC
	clr p0.7 ;Włączenie oscyloskopu
	reti ; powrót do pętli głównej
	przepelnienie: ;etykieta obsługująca przepełnienie
	mov p1, #255 ; danie na wejście DAC 255
	clr p0.7 ;Włączenie oscyloskopu
reti ; powrót do pętli głównejORG 0000H ;Ustawienie adresu startowego skoku do początku programu
	LJMP start ;skok do etykiety programu startowego

ORG 0003H ;miejsce w pamięci gdzie obsługiwane jest przerwania z zerwnątrz od ADC
	LJMP przerwanie ;Skok do obsługi przerwania ADC

ORG 0100H ; Ustawanie adresu poczatkowego gdzie znajduje się program żeby nie nadpisać skoku przerwania
start: ;Etykieta strtowa
	setb p3.2 ;Wyzerowania flagi przerwania
  SETB IT0 ; Ustawienie przerwania żeby wyzwalane zostało zboczem opadającym
  SETB EX0 ; Odblokowanie przerwania 0
  SETB EA  ; odblokowanie globalnych przerwań
  MOV P2, #0FFH ; Ustawienie P2 jako wejście dla ADC
	MOV P1, #0FFH ; Ustawanie P1 jako wejście dla przełączników SW
  SETB P3.7; RD domyślnie w stanie wysokim
  CLR P3.6 ; WR domyślnie w stanie niskim

loop: ; główna pętla programu
	;wyzwalanie zboczem opadającym ADC
	CLR P3.6
	SETB P3.6          
	;pętla która daje czas na odpowiedź ADC
	MOV R6, #100
	DJNZ R6, $
	SJMP loop

przerwanie: ;Etykieta przerwania z ADC
	CLR P3.7; RD = 0: Dane z ADC pojawiają się na P2
	MOV A, P2; Kopiuj dane z ADC do Akumulatora
	SETB P3.7; RD = 1: Koniec odczytu
	mov r1, A ; kopia danych z Acc
	mov A, p2 ;pobranie wzmocnienia
	cpl A ;ODwrócenie bitów wzmocnienia (logika odwrotna)
	anl A, #00001111b ;Maskowanie acc bo obsługa tylko sw0-sw3
	mov b, R1 ;pobranie wartości próbki
	mul ab ;mnożenie próbka * wzmocnienie
	jb psw.2, przepelnienie ; Wykreycie przepełnienia
	mov p1, Acc ; kopia danych na wejście DAC
	clr p0.7 ;Włączenie oscyloskopu
	reti ; powrót do pętli głównej
	przepelnienie: ;etykieta obsługująca przepełnienie
	mov p1, #255 ; danie na wejście DAC 255
	clr p0.7 ;Włączenie oscyloskopu
reti ; powrót do pętli głównejORG 0000H ;Ustawienie adresu startowego skoku do początku programu
	LJMP start ;skok do etykiety programu startowego

ORG 0003H ;miejsce w pamięci gdzie obsługiwane jest przerwania z zerwnątrz od ADC
	LJMP przerwanie ;Skok do obsługi przerwania ADC

ORG 0100H ; Ustawanie adresu poczatkowego gdzie znajduje się program żeby nie nadpisać skoku przerwania
start: ;Etykieta strtowa
	setb p3.2 ;Wyzerowania flagi przerwania
  SETB IT0 ; Ustawienie przerwania żeby wyzwalane zostało zboczem opadającym
  SETB EX0 ; Odblokowanie przerwania 0
  SETB EA  ; odblokowanie globalnych przerwań
  MOV P2, #0FFH ; Ustawienie P2 jako wejście dla ADC
	MOV P1, #0FFH ; Ustawanie P1 jako wejście dla przełączników SW
  SETB P3.7; RD domyślnie w stanie wysokim
  CLR P3.6 ; WR domyślnie w stanie niskim

loop: ; główna pętla programu
	;wyzwalanie zboczem opadającym ADC
	CLR P3.6
	SETB P3.6          
	;pętla która daje czas na odpowiedź ADC
	MOV R6, #100
	DJNZ R6, $
	SJMP loop

przerwanie: ;Etykieta przerwania z ADC
	CLR P3.7; RD = 0: Dane z ADC pojawiają się na P2
	MOV A, P2; Kopiuj dane z ADC do Akumulatora
	SETB P3.7; RD = 1: Koniec odczytu
	mov r1, A ; kopia danych z Acc
	mov A, p2 ;pobranie wzmocnienia
	cpl A ;ODwrócenie bitów wzmocnienia (logika odwrotna)
	anl A, #00001111b ;Maskowanie acc bo obsługa tylko sw0-sw3
	mov b, R1 ;pobranie wartości próbki
	mul ab ;mnożenie próbka * wzmocnienie
	jb psw.2, przepelnienie ; Wykreycie przepełnienia
	mov p1, Acc ; kopia danych na wejście DAC
	clr p0.7 ;Włączenie oscyloskopu
	reti ; powrót do pętli głównej
	przepelnienie: ;etykieta obsługująca przepełnienie
	mov p1, #255 ; danie na wejście DAC 255
	clr p0.7 ;Włączenie oscyloskopu
reti ; powrót do pętli głównej
