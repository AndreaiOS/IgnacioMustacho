# Game Center — configurazione pronta da copiare

App: Ignacio Mustacho · bundle `com.ignaciomustacho.shadowbasketball`. Questi file non hanno creato record Apple. La scala v2 è quella attuale: non usare gli ID del vecchio prototipo.

## Classifica

In App Store Connect → app → Game Center aggiungere una leaderboard classica e una localizzazione English (U.K.). Dati anche in `Leaderboard-en.json`.

| Campo | Valore |
| --- | --- |
| Reference Name | Shadow Club High Score v2 |
| Leaderboard ID | `ignacio.shadow.highscore.v2` |
| Type | Classic |
| Score Format | Integer |
| Score Submission Type | Best Score |
| Sort Order | High to Low |
| Score Range | Lasciare vuoto: il gioco non impone un punteggio massimo |
| Default leaderboard | Questa classifica |
| Display Name | Shadow Club High Scores |
| Description | Build your combo and finish a run with your highest score. |
| Suffix singular | ` point` (spazio iniziale) |
| Suffix plural | ` points` (spazio iniziale) |

Il cap 320 riguarda i BPM, non il punteggio: non impostare 320 come score massimo. Immagine leaderboard opzionale, non necessaria al funzionamento. Non servono set, ricorrenze o multiplayer.

## Sei achievement

Creare ciascun ID esattamente come sotto, poi aggiungere la localizzazione inglese. Tutti: **10 punti Game Center**, **Hidden = No**, **Achievable more than once = No**. Totale: 60 punti Game Center. I punti Apple sono distinti dalle soglie di punteggio nella partita. Ordine consigliato: 10, 23, 33, 50, 81, 100.

### 10 — Tiny Flex

- Reference Name: `10 points - Tiny Flex`
- Achievement ID: `ignacio.shadow.points10.v2`
- Display Name: Tiny Flex
- Pre-earned Description: Reach 10 points in a single run.
- Earned Description: Ten points. The sleeve never stood a chance.
- Immagine: [award-10.png](award-10.png) — 1024×1024 RGB, 72 ppi.

### 23 — MJ-ish

- Reference Name: `23 points - MJ-ish`
- Achievement ID: `ignacio.shadow.points23.v2`
- Display Name: MJ-ish
- Pre-earned Description: Reach 23 points in a single run.
- Earned Description: Same number. Slightly different career.
- Immagine: [award-23.png](award-23.png) — 1024×1024 RGB, 72 ppi.

### 33 — Bench Legend

- Reference Name: `33 points - Bench Legend`
- Achievement ID: `ignacio.shadow.points33.v2`
- Display Name: Bench Legend
- Pre-earned Description: Reach 33 points in a single run.
- Earned Description: Still undefeated. Mostly unselected.
- Immagine: [award-33.png](award-33.png) — 1024×1024 RGB, 72 ppi.

### 50 — Self-Applause

- Reference Name: `50 points - Self-Applause`
- Achievement ID: `ignacio.shadow.points50.v2`
- Display Name: Self-Applause
- Pre-earned Description: Reach 50 points in a single run.
- Earned Description: Someone had to start the applause.
- Immagine: [award-50.png](award-50.png) — 1024×1024 RGB, 72 ppi.

### 81 — Imaginary MVP

- Reference Name: `81 points - Imaginary MVP`
- Achievement ID: `ignacio.shadow.points81.v2`
- Display Name: Imaginary MVP
- Pre-earned Description: Reach 81 points in a single run.
- Earned Description: The crowd in my head is going wild.
- Immagine: [award-81.png](award-81.png) — 1024×1024 RGB, 72 ppi.

### 100 — Hall of Me

- Reference Name: `100 points - Hall of Me`
- Achievement ID: `ignacio.shadow.points100.v2`
- Display Name: Hall of Me
- Pre-earned Description: Reach 100 points in a single run.
- Earned Description: I would like to thank my moustache.
- Immagine: [award-100.png](award-100.png) — 1024×1024 RGB, 72 ppi.

## Collegamento e verifica su dispositivo

1. Verificare Game Center nell'App ID e nel provisioning del bundle corrente; l'entitlement è già nel progetto. Usare la build firmata, non le scene DEBUG di controllo.
2. Aprire Club records → Connect Game Center. Provare autenticazione e annullamento; annullare non deve bloccare il gioco offline.
3. Con un account di test giocare una run normale. Verificare che il punteggio finale compaia nella classifica corretta. Poi ottenere un punteggio inferiore: con Best Score deve restare il maggiore.
4. Superare ciascuna soglia in una singola run e verificare gli achievement. I progressi parziali sono percentuali del miglior punteggio per soglia; i premi locali possono essere sincronizzati appena ci si autentica. Tutorial escluso.
5. Giocare offline: record e premi devono restare locali. Tornare online, autenticarsi e mantenere l'app attiva: gli achievement in coda ritentano ogni 15 secondi. I punteggi leaderboard falliti non hanno retry: per testarli, completare una nuova run online.
6. Chiudere/riaprire e verificare persistenza; controllare che gli annunci Apple non interrompano una mossa. I banner achievement sono disattivati dal codice in favore della celebrazione locale.
7. Se si cambia account, considerare che i progressi locali appartengono al dispositivo e possono essere riportati al nuovo account. Non sono salvataggi separati per utente. Non resettare dati di produzione per testare: usare account/dispositivi di prova e gli strumenti Apple disponibili per il test.
8. Associare leaderboard e achievement alla versione/submission e inviarli a review insieme alla prima versione che li usa. Record creato non significa già approvato o pubblicato.

Diagnostica: confrontare gli ID con `Configuration/Release.xcconfig`; controllare che la build sia del bundle attuale, la capability sia presente, le localizzazioni siano salvate e l'account sia autenticato. Nessuna credenziale Apple va inserita nel repository.

Fonti Apple consultate il 31 ottobre 2026: [leaderboard](https://developer.apple.com/help/app-store-connect/configure-game-center/manage-leaderboards/), [campi classifica](https://developer.apple.com/help/app-store-connect/reference/game-center/leaderboards/), [achievement](https://developer.apple.com/help/app-store-connect/configure-game-center/manage-achievements/), [test](https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-testing-game-center/), [invio componenti](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-game-center-components/).
