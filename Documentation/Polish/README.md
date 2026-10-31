# Rifinitura del club — 31 ottobre 2026

Versione locale verificata, con progressione estesa e rifiniture visive/audio. [Apri la galleria prima/dopo](index.html): Home, finale, opzioni, premi e scene di controllo. Le catture sono originali dei simulatori, senza ritoccare l’interfaccia.

## Comportamento implementato

- Progressione ogni quattro comandi: 100 → 180 BPM nei primi cinque stadi, poi +5 BPM fino a **320 BPM al comando 129, PACE 33**. Intervallo nominale fra richieste da 2,40 a 0,75 secondi. Il limite è basato sui comandi, non sul punteggio. [Parametri e regressioni](../PaceUpdate.md).
- Finestre più strette fino a Good ±159 ms e Perfect ±80 ms. Note e animazioni si accorciano con il ritmo. Swipe iniziati in tempo conservano il margine di riconoscimento; dopo una celebrazione ripartono quattro beat completi.
- Finale con battuta esclusivamente scritta e cadenza musicale. Gli annunci delle quattro mosse rimangono; Sound check permette di disattivarli separatamente dall’organo. Entrambe le preferenze persistono sul dispositivo.
- Home con brevi pose alternate, timbro ironico e accesso alle opzioni. Oro per Perfect, punti effettivamente guadagnati nel feedback, errori più contrastati e pulsanti mosse alti 44 punti.
- Celebrazione protetta con coriandoli e leggero accento di scala; decorazioni escluse dall’input. Reduce Motion disattiva i nuovi movimenti decorativi.
- Finale con record, BPM e premi della run; timbro nuovo record solo quando meritato. Quindici battute, tre per ciascuna delle cinque fasce, alternate durante la sessione. Club records mostra i sei progressi locali reali.
- Corretto un troncamento della battuta finale trovato nella verifica visiva: ora va a capo anche sul simulatore piccolo. Test di regressione osservato fallire prima della correzione e passare dopo.

## Immagini e provenienza

| Schermata | Prima | Dopo |
| --- | --- | --- |
| Home | [Prima](Before/Home.png) | [Dopo](After-Large/Home.png) |
| Finale | [Prima](Before/GameOver.png) | [Dopo](After-Large/GameOver.png) |
| Opzioni audio | — | [Sound check](After-Large/SoundCheck.png) |
| Premi locali | — | [Club records](After-Large/ClubRecords.png) |
| Celebrazione | — | [Tiny Flex](After-Small/Milestone10.png) |
| Velocità massima | — | [320 BPM](After-Small/Pace320.png) |

`After-Small` proviene da iPhone 18 Pro, `After-Large` da iPhone 18 Pro Max. I manifest registrano test e allegati; `manifest-final.json` sostituisce le catture omonime dopo la correzione di wrapping. Le scene Milestone10/Pace320 usano clock fermo e stato sintetico DEBUG per verificare il layout; non salvano record e non sono screenshot promozionali. I quattro screenshot in `AppStore/Screenshots` sono stati rigenerati da catture normali aggiornate del simulatore grande, incluso il finale corretto.

## Verifica completata

- 32 test Domain, 22 test app e 12 test UI superati. La suite grande comprende persistenza audio, sei celebrazioni, lunga partita fino al massimo ritmo, input e navigazione.
- Suite precedente sul piccolo: 21 test app e 10 UI superati; dopo le aggiunte finali, tre controlli UI mirati superati (finale, celebrazione, 320 BPM). Dopo il wrapping, anche il controllo finale/replay sul grande è passato.
- Build Release per simulatore generico superata; scene di revisione escluse dalla compilazione Release.
- `swift-format lint --strict` e `git diff --check` superati. SwiftLint non installato.
- Verifica visiva delle catture, controllo dimensioni/formato dei quattro export App Store e limiti dei metadati.

Risultati locali: `/tmp/ignacio-polish-domain-final.log`, `/tmp/ignacio-polish-large.xcresult`, `/tmp/ignacio-polish-small-final.xcresult`, `/tmp/ignacio-polish-large-final.xcresult`, `/tmp/ignacio-polish-release.log`. Comandi di build/test e destinazioni nel README principale. Questi risultati temporanei non sono versionati; immagini e manifest sì.

## Limiti e consegna

La verifica è su simulatore: latenza touch/audio reale, comportamento a 320 BPM su iPhone fisico, Dynamic Type estremo e Game Center end-to-end richiedono ancora verifica. L’archivio firmato precedente è storico e non contiene questa rifinitura. Nessun caricamento App Store/TestFlight o modifica agli account Apple.

Questa rifinitura viene conservata in un commit locale separato dal commit iniziale `2117e6b` già presente su `origin/main`. Non viene eseguito un nuovo push delle rifiniture durante questa consegna.
