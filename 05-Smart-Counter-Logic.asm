; ==============================================================================
; TYTUŁ: Dwukierunkowy licznik z dynamicznym Modulo i autokorektą
; OPIS: Licznik sterowany zdarzeniowo (SW1) z wyborem kierunku (SW7) 
;       oraz przełączanym trybem pracy (DEC/HEX).
;
; LOGIKA SPECJALNA:
;   - Detekcja zbocza przycisku (Edge Detection) zapobiegająca auto-powtarzaniu.
;   - Dynamiczne przełączanie Modulo 10 / Modulo 16.
;   - Autokorekcja: Wymuszenie stanu "7" przy przejściu z HEX do DEC, 
;     jeśli bieżąca wartość > 9.
; ==============================================================================

;Kodowanie znaków Wyświetlacza
 mov 30h, #11000000b   ; 0
 mov 31h, #11111001b   ; 1
 mov 32h, #10100100b   ; 2
 mov 33h, #10110000b   ; 3
 mov 34h, #10011001b   ; 4
 mov 35h, #10010010b   ; 5
 mov 36h, #10000010b   ; 6
 mov 37h, #11111000b   ; 7
 mov 38h, #10000000b   ; 8
 mov 39h, #10010000b   ; 9
 mov 3Ah, #10001000b		; A
 mov 3Bh, #10000000b		; B
 mov 3Ch, #11000110b		; C
 mov 3Dh, #11000000b		; D
 mov 3Eh, #10000110b		; E
 mov 3Fh, #10001110b		; f
       
      ;ustawienie na jakim wyćwietlaczu ma się wyświetlać
 clr p3.4
 clr p3.3
;Ustawienie początkowej wartości licznika
 mov R1, #0
 ;ustawienie wskaźnika numeru licznika
 mov R0, #30h

;Etykieta startowa
start:
	;Wyświetlenie znaku z pamięci pod wskaźnikiem R0
 	mov p1, @R0
	;skok bezwarunkowy do zatrzasku sw1
 	jmp latch
	;pętla main
 	jmp start
       
latch: ;zatrzask
  pre: ; pętla dopóki przycisk zostanie wciśnięty
 		jb p2.1, kos
 		jmp pre
  kos: ;pętla dopóki przycisk zostanie odciśnięty
 	jnb p2.1, koniec
 	jmp kos
  koniec: ;przycisk po zatrzaśnięci przejście do wyboru ustawienia licznika
 		mov P0, #0ffh ;Wyzerowanie p0 żeby dalej można było odczytywać przyciski
 		jmp change
change: ;Etykieta odpowiedzialna za wybór jaki stan jest licznik base-10 / base-18
 	 
 	jnb p2.5, b16_mode ; sprawdzeie przycisku sw5
 	jmp b10_mode; skok do stanu base-10
      	
 b16_mode: ;Etykieta odpowiedzialna za base-10
	mov A, R1 ;przypisanie R1 do A 
 	call step_counter ; Wywołanie funkcji odpowiedzialnej za inkrementacje czy dekrementacje licznika
	cjne R1, #16, continue_16 ;instrukcja porównawcza jeżeli R1 == 16 to licznik jest zerowany 
		mov R1, #0 ;zerowanie licznika
 		mov R0, #30h ; przypisanie wskaźnika na znak 0 
 		jmp start ;skok bezwarunkowy do startu
	continue_16: ;jeżeli R1 != 16 
 		jnc reverse_16 ; jeżeli instrunkcja cjne skoczyła bez ustawienia flafi carry R1>16 gdy licznik sie przepełni odwrcamy jego działanie
 		mov R1, A ;przypisanie A do R1
 		ADD A, #30h, ;Ustawienie odpowiedniego adresu do wskaźnika
 		mov R0, A
 		jmp start
reverse_16: ;odwrócenie licznika 
	mov R1, #15, ;wpisanie 15 pierwszej wartości
	mov R0, #3Fh
	jmp start
 		  
b10_mode: ;Etykieta odpowiedzialna za ustawienie za base-10
	mov A, R1 
	call step_counter ;wywołanie funkcji odpowiedzialnej za inkrementacje lub dekrementacje licznika
	cjne R1, #10, continue_10	 ;funkcja porównawcza R1 == 10 to zerujemu licznik
	mov R1, #0 ;zerowanie licznika 
	mov R0, #30h ;przypisanie adresu znaku 0 
	jmp start 
	continue_10: ; etykieta gdy R1 != 10
		cjne R1, #0ffh, normal_10 ;Jeżeli R1 == 0xff wtedy licznik się przepełnił czyli odwracamy jego działanie
		mov R1, #9 ;przypisanie następnej liczby jako 9
		mov R0, #39H ;przypisanie adresu znaku 9
		jmp start	
	normal_10: ;jeżeli R1 != 0xff 
		cjne R1, #10, normal_continue ;jeżeli R1 == 10 to pokazujemy 10 bo wykracza poza base 10
		jmp show_7 ;Skok bezwarunkowy do etykiety wyświetlającej 7
		normal_continue: ; Jeżeli R1 != 10 
		jnc show_7 ; jeżeli ustawiono flagę carry odwracamy działanie licznika
 		mov R1, A ; R1 =A
 		ADD A, #30h;;przypisanie adresu znaku 0
 		mov R0, A
 		jmp start
	show_7: ;etykieta pokazująca 7 oraz ustawia wartość licznika na 7
		mov R1, #7 
		mov R0, #37h
		jmp start
step_counter: ; Funkcja odpowiedzialna za wybór czy inkrementujemy licznik czy go dekrementujemy
	jnb p2.7, decrease ;jeżeli kliknięty sw7 to dekrementujemy
	inc A ;jeżeli sw7 nie wciśnięty to inkrementujemy licznik
	mov R1, A
	reti ;powrót do miejsca wywołania funkcji
	decrease: ;Etykieta gdy sw7 wciśniety
	dec A
	mov R1, A
	reti ;powrót do miejsca wywołania funkcji
	
