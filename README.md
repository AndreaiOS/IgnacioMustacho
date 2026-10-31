# Ignacio Mustacho — Shadow Basketballing

Prototipo iPhone nativo, giocabile offline. Ignacio è il fondatore immaginario dello Shadow Basketballing: fa mosse di basket **senza palla e senza canestro**. Personaggio raster con **12 fotogrammi distinti per ciascuna delle quattro mosse**, ispirato ai riferimenti canonici conservati in `Documentation/CharacterReferences`. Arena illustrata, tipografia sportiva e organo originale. Asset prodotti con lo strumento immagini integrato; nessun servizio esterno acquistato. È un’interpretazione illustrata, non una riproduzione fotografica.

Preparazione pubblicazione: [passaggi del proprietario](AppStore/Publication/OWNER-STEPS.md), [scheda App Store](AppStore/Publication/STORE-LISTING.md), [Game Center](AppStore/GameCenter/SETUP.md). Verifica locale materiali: `python3 Scripts/verify_publication.py`.

Ultimo aggiornamento e media: [ArenaUpdate](Documentation/ArenaUpdate.md).

## Avvio

Aprire `Ignacio.xcodeproj`, selezionare lo scheme **Ignacio**, scegliere **iPhone 18 Pro (iOS 27.0)** e premere Run. Il progetto generato è incluso: XcodeGen serve solo per rigenerarlo dopo modifiche a `project.yml`.

Toolchain verificata: Xcode **27.0 (27A266a)**, Swift **6.4**, XcodeGen **2.45.4**. Deployment target iOS **17.0**, solo iPhone, orientamento verticale. Nessuna dipendenza di terze parti. Il team già selezionato è conservato in `Configuration/LocalSigning.xcconfig`; archivio locale firmato verificato con bundle ID `com.ignaciomustacho.shadowbasketball`. Nessuna pubblicazione eseguita. Vedere [preparazione iPhone e Release](Documentation/Device-Release.md) e [pacchetto App Store](AppStore/README.md).

Dalla directory del progetto:

```sh
xcodebuild -list -project Ignacio.xcodeproj
xcrun simctl list devices available
xcodebuild -project Ignacio.xcodeproj -scheme Ignacio \
  -destination 'platform=iOS Simulator,id=52907F42-D533-4B8A-A74E-93C33F7B35B4' \
  -derivedDataPath /tmp/ignacio-derived CODE_SIGNING_ALLOWED=NO build

swift test --scratch-path /tmp/ignacio-swift-build

xcodebuild -project Ignacio.xcodeproj -scheme Ignacio \
  -destination 'platform=iOS Simulator,id=52907F42-D533-4B8A-A74E-93C33F7B35B4' \
  -derivedDataPath /tmp/ignacio-derived CODE_SIGNING_ALLOWED=NO test

xcrun swift-format lint --strict --recursive Sources Tests UITests Package.swift
xcrun swift-format format --in-place --recursive Sources Tests UITests Package.swift
```

L’UUID è quello realmente presente sul Mac di sviluppo; su un altro Mac usare un dispositivo restituito da `simctl list`. La sandbox Codex richiede autorizzazione per le cache Swift/Xcode e CoreSimulator.

SwiftLint è configurato in `.swiftlint.yml` ma non è installato su questa macchina: `swiftlint lint --strict` è il comando previsto, non verificato. Il formatter/linter Swift ufficiale incluso in Xcode è stato eseguito.

## Come giocare

- **Tap**: Dribble.
- **Swipe verso il basso**: Between the legs.
- **Swipe orizzontale in entrambe le direzioni**: Behind the back.
- **Swipe verso l’alto**: Shoot.

Il cartello e la voce inglese anticipano la mossa. Eseguire il gesto mentre il **centro del pallino è dentro il riquadro delineato HIT ZONE**: compare **NOW**, seguito dal gesto richiesto. Il contorno e il testo rendono la zona riconoscibile anche senza distinguere i colori. La linea interna segna il beat ideale; tutta la fascia è valida, prima e dopo il beat. Il pallino continua oltre la linea centrale e non si ferma più al bersaglio. I quattro pulsanti in basso eseguono le stesse azioni e offrono un’alternativa ai gesti. È un gioco ritmico, non di memoria: ogni comando resta visibile.

Il primo Play della sessione propone quattro comandi lenti, uno per mossa, senza perdita di vite; poi inizia automaticamente la partita. Tutorial è ripetibile dalla Home. How to Play apre una guida facoltativa con le quattro mosse animate, gesti, hit zone e regole, con accesso diretto a Play o warm-up. Un errore di gesto, di tempo o un comando mancato costa una delle tre vite e azzera la combo. Nessun timer o limite di durata. Dopo tre errori: punteggio, record e Play Again.

Perfect: entro ±180 ms nel tutorial, fino a ±140 ms in partita, 2 punti. Good: entro ±500 ms nel tutorial e ±400 ms nei primi otto comandi, 1 punto. La mezza finestra normale è il minimo fra `max(0.28, 0.4 - (index / 8) * 0.02)` e l’85% di un beat; Perfect è il minimo fra 140 ms e metà della finestra Good. Al limite finale: Good ±159 ms, Perfect ±80 ms. I bordi sono inclusi; il riconoscimento conserva il timestamp iniziale del contatto e concede fino a 450 ms per completare uno swipe iniziato nella fascia valida. Moltiplicatore ×1, ×2 dalla combo 10 e ×3 dalla combo 20. Un comando viene giudicato una sola volta.

Un comando ogni quattro beat. Tutorial invariato (circa 71 BPM); i primi quattro comandi della partita sono a 100 BPM. Ogni quattro comandi si passa a 120, 140, 160 e 180 BPM, poi si aggiungono 5 BPM ogni quattro comandi fino a 320 BPM dal comando 129 (PACE 33). La difficoltà dipende dai comandi, non dal punteggio o dalla combo. Il limite tecnico evita richieste impossibili: non c’è un plateau precoce al comando 17. Ritardo di riconoscimento o frame molto lento possono estendere il countdown seguente per lasciare almeno tre beat di preavviso; dopo una celebrazione si riparte sempre con quattro beat interi.

| Comando | PACE | BPM | Intervallo nominale mosse |
| --- | --- | --- | --- |
| 1 | 1 | 100 | 2,40 s |
| 17 | 5 | 180 | 1,33 s |
| 33 | 9 | 200 | 1,20 s |
| 65 | 17 | 240 | 1,00 s |
| 97 | 25 | 280 | 0,86 s |
| 129 e oltre | 33 | 320 | 0,75 s |

Quattro note ascendenti di organo accompagnano il countdown sullo stesso clock del bersaglio. Le note si accorciano alle alte velocità, con un piccolo spazio tra una e l’altra; anche le animazioni di gioco si accorciano (da 850 a circa 391 ms), mantenendo tutte le 12 pose. Le reazioni celebrative conservano la loro durata protetta di 1,35 s. Gli annunci vocali delle mosse restano attivi; il finale mantiene solo musica e battuta scritta. Audio ambient rispetta la modalità silenziosa. Il pulsante audio è in Home; la voce inglese disponibile sul dispositivo può differire. Background mette in pausa senza consumare vite; Resume conserva il tempo relativo al bersaglio.


## Struttura e scelte

- `Sources/Domain/RhythmGame.swift`: macchina a stati pura, mosse, finestre temporali, vite, combo e protocollo record. Nessun framework UI/storage, tempo passato esplicitamente.
- `Sources/Data/Services.swift`: record UserDefaults, sintesi PCM/AVSpeech e GameKit.
- `Sources/Presentation/GameModel.swift`: stato della schermata e coordinamento; clock monotono, audio e record iniettati.
- `Sources/Presentation/SpriteCharacter.swift`: riproduzione dei 120 frame (48 di gioco e 72 di reazione), ritagli e ancoraggio dei piedi da `Sources/Art/SpriteLayout.json`; nessuna dissolvenza tra pose. Il vecchio personaggio vettoriale resta come fallback.
- `Sources/Presentation/HowToPlayView.swift`: guida pubblica animata e scorrevole; la motion review DEBUG rimane separata.
- `Sources/Domain/GestureInput.swift` e `Sources/Presentation/TouchSurface.swift`: riconoscimento puro e timestamp UITouch.
- `Scripts`: generazione audio originale e analisi geometrica degli atlas, senza alterare i PNG.
- `Sources/Presentation/IgnacioApp.swift`: composition root e viste SwiftUI.
- `Tests/DomainTests`: test Swift Testing deterministici.
- `UITests`: percorsi XCUITest con schermate allegate.
- `Documentation`: risultati visivi e note di verifica.

Le note dell’organo sono programmate in anticipo sul clock audio a partire dallo stesso bersaglio dell’indicatore. `RhythmTiming` nel Domain è l’unica fonte per accettazione, deadline, coordinate normalizzate del pallino e bordi della fascia: il tempo visibile va da quattro beat prima al massimo tra un beat e la mezza finestra più 120 ms dopo il bersaglio. Il centro del pallino e i bordi del riquadro usano la stessa trasformazione in pixel. NOW appare solo finché il comando può ancora essere eseguito; dopo un input compare il giudizio, senza invitare a un secondo gesto. Il gesto viene giudicato sul timestamp iniziale del contatto, con riconoscimento anticipato dello swipe a 14 pt, una sola azione per contatto e protezione dai gesti rimasti aperti sul comando precedente. Il tempo di attivazione audio non consuma il countdown iniziale. Feedback distinti indicano anticipo, ritardo e mossa errata. Per il prototipo il rendering usa un ticker a 60 Hz e AVAudioPlayer: la precisione audio non è sample-accurate. Il prossimo passaggio su dispositivo fisico è misurare latenza touch/audio e aggiungere calibrazione prima di valutare difficoltà competitiva. Il clock è iniettabile; i test del dominio non dormono e non usano il tempo reale.

## Game Center

Sono implementati autenticazione esplicita, apertura delle leaderboard via GKAccessPoint e invio dei punteggi di fine partita. Identificatore configurabile in `Configuration/Release.xcconfig`: **ignacio.shadow.highscore.v2**. Record e gioco funzionano sempre offline; gli errori online sono mostrati nella schermata classifica, senza classifiche simulate.

Per rendere operativa la classifica online:

1. Registrare il proprio bundle ID e abilitare Game Center nel developer account e nell’app App Store Connect.
2. Configurare la firma con un team e un provisioning profile che includano Game Center. L’entitlement è già nel progetto.
3. Creare una leaderboard classica con ID `ignacio.shadow.highscore.v2`, punteggi interi ordinati dal più alto al più basso.
4. Collegarla all’app e verificare login, invio e lettura con gli account di test Apple su build firmata.

Nessun record App Store Connect o componente Game Center è stato creato dall’agente; la firma locale esistente funziona, gli invii online non sono ancora verificati. La classifica non ha coda di retry: un punteggio non inviato resta nel record locale. Gli achievement hanno invece una coda persistente con retry, descritta sotto. Nessun account Instagram o integrazione social richiesti.

## Accessibilità, privacy e limiti

Comandi testuali oltre ai colori, etichette VoiceOver, azioni accessibili per le quattro mosse, pulsanti alternativi, layout relativo alle dimensioni dello schermo e rispetto di Reduce Motion per il personaggio. La sfida resta temporizzata: non si dichiara equivalenza dell’esperienza con VoiceOver. Interfaccia in inglese; stringhe SwiftUI localizzabili e estrazione Xcode abilitata, ma traduzioni non ancora aggiunte. Dimensioni Dynamic Type estreme e modelli iPhone aggiuntivi richiedono QA dedicata.

Nessuna analytics, pubblicità, tracking, microfono o dato sensibile. UserDefaults conserva il record, le preferenze audio, i progressi achievement e le conferme di sincronizzazione per identificativo giocatore Game Center. Game Center è opzionale e usa l’account Apple; il manifest privacy dichiara accesso alle preferenze e uso del clock per intervalli interni, secondo [la documentazione Apple](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api). Prima di una distribuzione occorrono revisione privacy, conferma editoriale dell’icona e degli asset in `AppStore`, QA audio e hardware, localizzazioni e configurazione Game Center.


## Pacchetto visivo e archivio locale

`AppStore` contiene icona esportata 1024×1024 RGB, anteprime piccole, screenshot promozionali da catture reali, branding e metadati inglesi. I file necessari all’app sono integrati in `Sources/Assets.xcassets` e `Sources/LaunchScreen.storyboard`. L’avvio mostra l’arena senza timer; la Home è subito interattiva.

```sh
swift Scripts/export_store_art.swift
swift Scripts/make_store_screenshots.swift
python3 Scripts/verify_archive.py BuildArtifacts/Ignacio-1.0-1-Current.xcarchive
```

Il secondo comando richiede le catture reali esportate in `AppStore/RawScreenshots`. I test UI e la verifica su due simulatori sono documentati nel README del pacchetto. Gli archivi firmati di sviluppo non sono una dichiarazione di idoneità al caricamento TestFlight.

## Premi e finali

Soglie di **punteggio numerico per singola partita**: 10, 23, 33, 50, 81, 100. Non sono conteggi delle mosse o della combo. Ogni soglia attiva una breve celebrazione una volta per run, con animazione dedicata di 12 pose e uno stacco originale di organo. Il tempo di gioco si ferma per 1,35 secondi; nessun gesto o vita viene consumato. Keep playing salta la pausa; il comando successivo riparte con quattro beat completi. Pause/background conservano anche il tempo della celebrazione. Tutorial escluso dai premi.

Cinque finali ironici dipendono dal punteggio raggiunto; la reazione e la battuta scritta non bloccano Play Again. La battuta finale non viene letta: resta la cadenza musicale; gli annunci vocali delle mosse sono invariati. Audio disattivato e Reduce Motion sono rispettati. Il vecchio record a scala 100/50 è separato dalla nuova scala 2/1: chiavi locali e leaderboard `v2`, senza conversioni arbitrarie.

`Sources/Domain/Rewards.swift` definisce soglie, finali e ledger puro. `Sources/Data/Achievements.swift` persiste il massimo progresso percentuale per premio e prova a inviarlo dopo autenticazione esplicita. Errori/offline mantengono la coda; retry ogni 15 secondi mentre l’app è attiva, nessuna richiesta sovrapposta. Le conferme sono per giocatore e per snapshot: progressi maturati durante un invio restano pendenti. Il progresso locale appartiene al dispositivo e può essere riportato agli account usati su quel dispositivo; non viene scaricato o unito lo storico remoto di altri dispositivi. La celebrazione può ripetersi nelle nuove partite; l’achievement Apple proposto è non ripetibile.

Nomi, descrizioni e sei badge 1024×1024 RGB sono in `AppStore/GameCenter`. I 10 punti Game Center proposti per ogni premio sono distinti dalle soglie del gioco. La configurazione Apple e il test end-to-end restano da eseguire.

Per rigenerare il progetto conservando gli override di firma correnti:

```sh
python3 Scripts/regenerate_project.py
```

Verifica dello snapshot iniziale dei premi: 28 test Domain, 15 app e 8 UI; dettagli in [RewardsUpdate](Documentation/RewardsUpdate.md). La verifica attuale della progressione e della rifinitura comprende 32 test Domain, 22 app e 12 UI, build Release per simulatore e controlli mirati del layout finale. Risultati e immagini in [Polish](Documentation/Polish/README.md).

## Firma su un altro Mac

Per il simulatore non serve un team. Per un dispositivo, copiare `Configuration/LocalSigning.xcconfig.example` in `Configuration/LocalSigning.xcconfig` e scegliere il proprio team; il file locale è escluso da Git. Certificati, profili, archivi, cache e risultati Xcode non sono versionati. Il bundle ID resta nella configurazione condivisa. Il repository non assegna una licenza commerciale agli asset di riferimento forniti dall’utente.

## Rifinitura del club

Sound check (icona cursori in Home, o durante la pausa) conserva sul dispositivo il master audio e la scelta separata degli annunci vocali. Spegnere gli annunci lascia organo ed effetti; disattivare il master non cancella la preferenza della voce. Il finale non legge mai la battuta.

La Home alterna una breve posa di vanità ogni otto secondi, con scala costante; Reduce Motion mantiene la posa ferma. Piccoli coriandoli e un lieve accento di scala compaiono solo nella celebrazione protetta. Nessun effetto decorativo copre l’input attivo. Il feedback mostra i punti realmente guadagnati, distingue i successi con un segno di conferma e rende gli errori più contrastati. I quattro pulsanti dei gesti hanno un’altezza di 44 punti.

Il tabellino finale riporta punti, record, BPM e premi della run; il timbro record appare solo quando il punteggio supera il precedente record. Cinque fasce di risultato con tre battute ciascuna (15 totali), alternate nei replay della sessione. Club records mostra il progresso locale reale dei sei premi con percentuali e contrassegno di completamento.

Scene DEBUG di verifica visiva: argomenti di lancio `--milestone-review` e `--pace-review` (clock fermo, progressi sintetici, nessun salvataggio). Non sono modalità di gioco pubbliche né fonti per screenshot promozionali. Dettagli della prima rifinitura in `Documentation/Polish/README.md`. La successiva revisione visiva navy/rosso/bianco è documentata in [Broadcast](Documentation/Broadcast/README.md), con [confronto prima/dopo](Documentation/Broadcast/index.html).
