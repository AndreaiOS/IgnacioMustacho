# Arena, ritmo e guida — 31 ottobre 2026

## Comportamento

- How to Play dalla Home: quattro mosse animate con nome e gesto, spiegazione della HIT ZONE/NOW, tre vite e accelerazione. Scorrevole, chiusura immediata, Play diretto e warm-up pratico. Nessun flag diagnostico; la motion review resta DEBUG. Reduce Motion ferma le animazioni e Dynamic Type accessibilità passa a una colonna.
- Input giudicato all’inizio del contatto UITouch, non alla fine dell’animazione dello swipe. Soglia 14 pt, durata massima 450 ms, tap massimo 300 ms, nessun doppio giudizio o gesto trasferito al comando successivo. Attivazione audio esclusa dal tempo del countdown. Regressioni riprodotte prima delle correzioni.
- Quattro comandi per livello: 100 → 111 → 125 → 143 → 167 BPM. Massimo dal comando 17, circa 34 secondi senza pause. Finestra visiva conserva spazio dopo il bordo tardivo anche alla massima velocità.
- Organo originale ascendente, ambiente e cadenza di fine partita. Direzione approvata: [Organ Build Up](https://www.101soundboards.com/sounds/3508700-organ-build-up). La registrazione non è stata scaricata o copiata. `Scripts/make_arena_audio.py` genera i WAV; note programmate sul clock AVAudioPlayer. Anteprima: `Arena-Audio-Preview.wav`.

## Arte e animazione

48 frame disegnati, 12 per azione: preparazione, azione, seguito e ritorno in 850 ms, senza crossfade. Gli atlas originali sono in `Sources/Art/ignacio-*-12.png`. `Scripts/analyze_sprite_layout.py` individua le figure e salva rettangoli, punti di appoggio ed esclusioni di frammenti adiacenti in `SpriteLayout.json`; il renderer ritaglia e maschera a runtime senza modificare i PNG. Generazione integrata, nessun servizio esterno acquistato.

Prompt e provenienza: `Smooth-Animation-Prompts.json`, `Art-Prompts-Final.json`, `Art-Prompts.json`. Identità canonica: `CharacterReferences`. Arena illustrata con profondità e illuminazione; Avenir Next Condensed Heavy per titoli/comandi e Menlo Bold per punteggi, presenza dei font verificata da test.

## Verifica e limiti

Comandi riproducibili nel README. Risultati e media sono riportati sotto. Nessuna verifica di latenza touch/audio su hardware fisico né provisioning Game Center. SwiftLint non installato; disponibile swift-format. Gli sprite generati mantengono piccole variazioni di disegno tra frame; non sono un rig 3D. La guida gestisce Reduce Motion e caratteri grandi; resta necessaria QA su ulteriori iPhone e con VoiceOver prima della distribuzione.

Verifiche del sorgente corrente: 22 test Domain, 8 test App e 6 percorsi XCUITest superati; swift-format strict senza segnalazioni. Xcode 27 / iPhone 18 Pro iOS 27. Risultati: `/tmp/ignacio-guide-final.xcresult`, log `/tmp/ignacio-guide-final.log`, `/tmp/ignacio-domain-final.log`. Gli XCUITest comprendono swipe fisici, tap, pausa/ritorno, fine partita/retry e guida→warm-up/Play. L’attivazione AVAudioSession produce ancora un warning di possibile blocco sul main thread; il countdown parte dopo l’attivazione, con regressione verificata, ma non si dichiara risolta la misura di latenza hardware.

## Correzione Dribble richiesta dopo la prima revisione

Confrontati i PNG effettivi e il rendering: i frame centrali del vecchio `ignacio-dribble-12.png` portavano la mano nello spazio tra le ginocchia, quasi a terra, con flessione del busto. `Move.allCases`, ordine JSON e caricamento delle quattro righe erano corretti; non c’era condivisione accidentale di frame. La somiglianza con Between the legs era nel disegno.

Nuovo asset: `Sources/Art/ignacio-dribble-side-12.png`, 12 pose generate con image_gen integrato; prompt esatto in `Dribble-Fix-Prompt.json`. Mano sul lato esterno, corsa molto più corta fino circa al ginocchio, busto e appoggi relativamente stabili. Between the legs conserva abbassamento, stance più aperta e attraversamento basso da un lato all’altro. Il renderer usa tutti i 12 nuovi frame, ordinati per pressione e recupero per evitare un secondo abbassamento nella fase di ritorno. L’originale è conservato per confronto ma non è usato da Dribble.

La raccolta diagnostica opzionale `simctl diagnose` si era bloccata dopo il successo di tutti i test: terminato soltanto quel sottoprocesso, Xcode ha chiuso correttamente il report con `TEST SUCCEEDED` (exit 0). Screenshot esportati in `Screenshots/Final`. Filmato comparativo delle mosse: `Ignacio-Motion-Review.mp4`.

Dopo la correzione Dribble: build/test App ripetuti con successo (`/tmp/ignacio-dribble-fix.log`, 8 test). Dominio e navigazione invariati rispetto al run completo di 36 test. Controllati visivamente atlas e fotogrammi del filmato della build corrente: Dribble resta esterno e corto; Between attraversa basso con maggiore flessione. Il filmato esclude l’avvio bianco dell’app. Le screenshot della guida in `Screenshots/Final` precedono soltanto la sostituzione di Dribble; layout e navigazione sono quelli correnti.
