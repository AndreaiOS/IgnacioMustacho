# Archivio e verifiche — 31 ottobre 2026

Archivio locale aggiornato: `BuildArtifacts/Ignacio-1.0-Publication.xcarchive` dalla radice del progetto. Non è incluso nello ZIP dei materiali né nel repository.

- Bundle: `com.ignaciomustacho.shadowbasketball`; versione **1.0 (1)**.
- Release archive per generic iOS: **ARCHIVE SUCCEEDED**. Include i nuovi link privacy e supporto in Sound check, curva fino a 320 BPM e grafica attuale.
- Packaging: `python3 Scripts/verify_archive.py BuildArtifacts/Ignacio-1.0-Publication.xcarchive` passato.
- Firma: `codesign --verify --deep --strict` passato fuori dalla sandbox; `get-task-allow = true`, quindi **firma di sviluppo**, da esportare/rifirmare per distribuzione con Xcode Organizer. Il primo controllo nella sandbox non poteva verificare la catena di fiducia del portachiavi.
- Test UI mirato `testSoundCheckPersistsVoiceChoiceWithoutMutingGameAudio`: passato su iPhone 18 Pro, verifica raggiungibilità dei link e persistenza preferenze. Evidenza in `Verification/`.
- Swift-format lint e `git diff --check`: passati. SwiftLint non installato.
- Materiali: `python3 Scripts/verify_publication.py` verifica limiti testi, bundle e ID Game Center, sei badge, quattro screenshot, icona, recapiti e link locali.
- Pagine HTML controllate localmente su desktop e viewport mobile 393×852, senza overflow orizzontale.

Nessuna validazione App Store Connect, esportazione IPA di distribuzione, prova Game Center online o upload eseguito. Nessuna installazione fisica eseguita per questa preparazione. I quattro screenshot promozionali restano validi: questa modifica aggiunge solo i link in Sound check, schermata esclusa dalle quattro immagini.

## Riprodurre l'archivio

Dalla radice, con il proprio team configurato localmente:

```sh
xcodebuild -list -project Ignacio.xcodeproj
xcodebuild -project Ignacio.xcodeproj -scheme Ignacio -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath BuildArtifacts/Ignacio-1.0-Publication.xcarchive -jobs 2 archive
python3 Scripts/verify_archive.py BuildArtifacts/Ignacio-1.0-Publication.xcarchive
codesign --verify --deep --strict BuildArtifacts/Ignacio-1.0-Publication.xcarchive/Products/Applications/Ignacio.app
```

Prima dell'invio attivare GitHub Pages: il link privacy nell'app deve essere pubblico. Verificare in Apple che il numero build 1 non sia già utilizzato. Seguire `OWNER-STEPS.md` per firma, TestFlight, dichiarazioni e invio. Gli altri archivi nella cartella BuildArtifacts sono snapshot precedenti.
