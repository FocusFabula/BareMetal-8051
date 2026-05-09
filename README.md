
# 🛠️ BareMetal-8051: Assembly Solutions Lab

Zbiór projektów niskopoziomowych opracowanych na architekturę **MCS-51 (8051)**. Każdy z programów został zaprojektowany, aby rozwiązać konkretny problem z zakresu systemów wbudowanych – od prostej automatyki po cyfrowe przetwarzanie sygnałów.

### 🚀 Środowisko testowe
Wszystkie programy zawarte w tym repozytorium zostały napisane, skompilowane i **pomyślnie przetestowane** w środowisku symulacyjnym **EdSim51**. 

> **Uwaga:** Aby uruchomić projekty, zaleca się korzystanie z EdSim51 ze względu na specyficzne mapowanie urządzeń peryferyjnych (klawiatura matrycowa, przetworniki ADC/DAC, paski LED), które zostało wykorzystane w kodzie.

---

### 📂 Zawartość repozytorium

| Projekt | Opis kluczowych zagadnień | Wykorzystane komponenty |
| :--- | :--- | :--- |
| **[01. Motor Control](./01-Motor-Control)** | Sterowanie cykliczne silnikiem, zmiana kierunku. | Timer 0 (M1), Timer 1 (M2) |
| **[02. Keyboard Division](./02-Keyboard-Division)** | Arytmetyka i walidacja wejścia z klawiatury. | Klawiatura matrycowa, 7-seg LED |
| **[03. BCD Converter](./03-BCD-Converter)** | Konwersja systemów liczbowych i I/O. | Klawiatura, Pasek LED |
| **[04. Signal Processing](./04-Signal-Processing)** | Akwizycja ADC, wzmocnienie i algorytm nasycenia. | Przerwania (INT0), ADC/DAC |
| **[05. Smart Counter](./05-Smart-Counter)** | Maszyna stanów, autokorekta zakresu DEC/HEX. | SW-Control, Edge Triggering |

---
