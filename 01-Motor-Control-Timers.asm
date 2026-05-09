
; ==============================================================================
; TYTUŁ: Automatyczny Sterownik Silnika Krokowego (8051)
; OPIS: Program realizuje 3 obroty, przerwę i zmianę kierunku w pętli.
; WYKORZYSTANIE LICZNIKÓW:
;   - Timer 0 (Mode 1): Odmierzanie opóźnienia 70ns
;   - Timer 1 (Mode 2): Zliczanie kroków/obrotów
; ŚRODOWISKO: EdSim51
; ==============================================================================


;ustawienie trybu pracy liczników
;ustawienie licznika T1 w trybie pracy 2 oraz do zliczania impolsów zewnętrznych
;ustawienie licznika T0 w trybie pracy 1 oraz żeby zliczał impulsy zegara mikrokontrolera
mov TMOD, #01100001b ;przypisanie ustawień do rejestru TMOD
;sutawienie stanu początkowego licznika T1
mov tl1, #253 ;przypisanie do rejestru TL1 liczby 253
mov th1, #253 ;przypisanie do rejestru TH1 liczby 253

;włączenie licznika T1
setb tr1 ;ustawienie flagi TR1 na 1

;flaga odpowiadająca za zmianę kierunku obrotu silnika
clr f0 ;wyzerowanie flagi F0

;włączenie silnika żeby kręcił się w prawo
clr p3.1 ;ustawienie bitu p3.1 na 0
setb p3.0 ;ustawienie bitu p3.0 na 1

start: ;etykieta startowa 
	;sprawdzenie czy licznik odmierzył 3 obroty silnika
	jb tf1, zmiana ;skok warunkowy jeżeli TF1 jest 0 to skocz do etykiety zmiana
	jmp start ;skok beawarunkowy do etykiety start

zmiana: ;etykieta obsługująca zmianę kierunku obrotu silnika oraz odbierzanie przerwy w działaniu silnika 
	;zatrzymanie silnika
	setb p3.0 ;ustawienie bitu p3.0 na 1
	setb p3.1 ;ustawienie bitu p3.1 na 1

	;przerwa pomiedzy zmianą kierunku obrotu silnika
	mov th0, #0ffh ;ustawienie TH0 na wartość FFh 
	mov tl0, #0bah ;ustwienie TL0 na wartość BAh
	setb tr0 ;ustawienie TR0 na 1 (włączenie licznika T0)
	jnb tf0, $ ;skok warunkowy jeżeli tf0 jest równy 0 to powtórz ten skok warunkowy (sprawdzenei czy licznik T0 się przepełnił)
	clr tf0 ;wyzerowanie flagi przepełnienia licznika T0 
	clr tr0 ;TR0 zatrzymanie licznika T0
 
	clr tf1 ;wyzerowanie flagi przepełnienia licznika T1 

	jb f0, prawo ;skok warunkowy jeżeli F0 jest równe 1 to skacz do etykiety prawo
	jnb f0, lewo ;;skok warunkowy jeżeli F0 jest równe 0 to skacz do etykiety lewo
  jmp start ;skok bezwarunkowy do etykiety start

prawo: ;etykieta prawo odpowiedzialna za ustawienie kręcenia się silnika w prawo
	cpl f0 ;odwrócenie wartości F0
	clr p3.1 ;wyzerowanie p3.1 
	setb p3.0 ;ustawienie p3.0 na 1
	jmp start ;skok

lewo: ;etykieta lewo odpowiedzialna za ustawienie kręcenia się silnika w lewo 
	cpl f0;odwrócenie wartości F0
	clr p3.0 ;wyzerowanie p3.0 
	setb p3.1 ;ustawienie p3.1 na 1 
	jmp start ;skok bezwarunkowy do etykiety start

