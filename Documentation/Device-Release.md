> Aggiornamento 31 ottobre 2026: archivio corrente e verifiche in [BUILD-STATUS](../AppStore/Publication/BUILD-STATUS.md); procedura completa in [OWNER-STEPS](../AppStore/Publication/OWNER-STEPS.md). Le informazioni sugli archivi precedenti qui sotto sono storiche.

# iPhone, Game Center e archivio locale

Stato verificato il 31 ottobre 2026. Nessun caricamento, creazione record o modifica account Apple eseguiti.

## Configurazione reale

- Team già selezionato nel progetto: conservato in `Configuration/LocalSigning.xcconfig` (ignorato da Git) e nelle eventuali impostazioni di firma del target.
- Bundle ID corrente `com.ignaciomustacho.shadowbasketball`, scelto dopo il rifiuto del namespace prototype. Profilo locale compatibile rilevato; record App Store Connect non verificato.
- Un iPhone fisico disponibile: “iPhone di Andrea”. L’altro dispositivo iOS è un iPad. Installazione/registrazione su dispositivo gestite dal proprietario in Xcode; nessun comando di installazione fisica eseguito dall’agente.
- Versione locale `1.0`, build `1`; verificare che sia una combinazione nuova nel record Apple prima di un futuro caricamento.
- App solo iPhone, iOS 17+, portrait. Corretto l’override XcodeGen che produceva erroneamente `UIDeviceFamily = [1, 2]`.
- Release con `-O`, `ENABLE_TESTABILITY=NO`, dSYM e archive action Release.
- Icona presente nel catalogo; plist esplicito include versione/build, launch screen, export-compliance flag e ID classifica. `Scripts/verify_archive.py` controlla il prodotto reale e aveva fallito sul vecchio packaging prima della correzione.

## Firma e archivi

Archivio firmato dello snapshot iniziale dei premi, precedente alla progressione 320 BPM e alla rifinitura del club: **`BuildArtifacts/Ignacio-1.0-1-Current.xcarchive`**, versione 1.0 (1), nuovo bundle ID, icona finale e sei premi. Archive Release riuscito senza `-allowProvisioningUpdates`, usando il profilo già disponibile sul Mac. Packaging e `codesign --verify --deep --strict` riusciti. Entitlements: team locale selezionato, application identifier con nuovo bundle ID, Game Center true, `get-task-allow = true`.

È una firma **di sviluppo**, non una IPA validata per App Store Connect. I precedenti archivi `Ignacio-1.0-1.xcarchive` e `Ignacio-1.0-1-StoreAssets.xcarchive` appartengono al vecchio bundle `com.prototype.ignaciomustacho` e precedono i premi: sono storici, non il deliverable corrente. Gli archivi sono ignorati da Git. Nessuna chiave privata o credenziale letta/esportata, nessun dispositivo installato dall’agente.

## Game Center: codice vs servizio Apple

Il codice autentica su richiesta di “Connect Game Center”, presenta il controller Apple se necessario, apre il dashboard leaderboards e invia il punteggio al termine della partita se il giocatore è autenticato. L’ID della nuova scala punti `ignacio.shadow.highscore.v2` è ora configurabile in `Configuration/Release.xcconfig` e viene incorporato nel plist, anziché fissato nel codice. Una configurazione vuota mostra un messaggio esplicito e non prova l’invio. Il record locale funziona sempre; non c’è coda di invii offline o reinvio automatico dei record precedenti al login.

**Non verificati**: esistenza dell’app e della leaderboard in App Store Connect, localizzazione della classifica, invio/lettura reali, stato review dei componenti Game Center. Entitlement e compilazione non dimostrano che il servizio sia operativo.

Passo Apple del proprietario: verificare il record app associato al nuovo bundle ID, abilitare Game Center, configurare una classic leaderboard con ID che coincida con il file locale, punteggi interi ordinati dal più alto, aggiungere localizzazione, quindi testare login → partita → invio → classifica con la build firmata. [Configurazione leaderboard Apple](https://developer.apple.com/help/app-store-connect/configure-game-center/manage-leaderboards/) e [test Game Center](https://developer.apple.com/help/app-store-connect/configure-game-center/overview-of-testing-game-center/).

## Comandi riproducibili

```sh
xcodebuild -list -project Ignacio.xcodeproj
xcodebuild -showdestinations -project Ignacio.xcodeproj -scheme Ignacio
xcodebuild -project Ignacio.xcodeproj -scheme Ignacio -configuration Release \
  -destination 'generic/platform=iOS' -archivePath BuildArtifacts/Ignacio-review.xcarchive archive
python3 Scripts/verify_archive.py BuildArtifacts/Ignacio-review.xcarchive
codesign --verify --deep --strict BuildArtifacts/Ignacio-review.xcarchive/Products/Applications/Ignacio.app
```

Per installare: in Xcode selezionare il team esistente e “iPhone di Andrea”, completare Register Device se richiesto, Developer Mode/trust sul telefono, Run. Il proprietario sta già eseguendo questo passaggio. Misurare sul telefono ritmo/touch/audio, silent mode, background/resume e fine partita.

Gli achievement hanno una coda persistente separata dalla leaderboard, con sei ID configurati nel plist e progressi fino al 100%. Metadati e badge locali in `AppStore/GameCenter`; nessun achievement remoto creato o verificato. Vedere [gestione achievement Apple](https://developer.apple.com/help/app-store-connect/configure-game-center/manage-achievements).

Prima di TestFlight restano da verificare i record Apple, validare/esportare la firma di distribuzione tramite Organizer, verificare metadati/privacy e autorizzare un caricamento separato. Bundle ID, versione e build collegano il binario al record Apple: [documentazione upload](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/). Nessuna dichiarazione di “pronto TestFlight” basata soltanto sull’archivio locale.
