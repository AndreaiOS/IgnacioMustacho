# Ignacio Mustacho — cosa resta al proprietario

Preparazione del 31 ottobre 2026. Nome pubblico: Andrea Murru. Email pubblica: an.murru@gmail.com. Prezzo confermato: gratuito. App e testi inglesi; versione 1.0, build 1 da confrontare con eventuali caricamenti già presenti.

## 1. Mettere online supporto e privacy

Le pagine complete sono in `docs/` alla radice del repository. Dopo il push, su GitHub aprire **AndreaiOS/IgnacioMustacho → Settings → Pages → Build and deployment → Deploy from a branch → main → /docs → Save**. Non occorre un dominio acquistato. Attendere il deployment e aprire senza autenticazione:

- Supporto: https://andreaios.github.io/IgnacioMustacho/support.html
- Privacy: https://andreaios.github.io/IgnacioMustacho/privacy.html

Sono indirizzi di destinazione: non dichiararli operativi prima che entrambe le pagine rispondano. L'app usa già il link privacy in Sound check; attivare Pages è quindi necessario prima di inviarla ad Apple. Il contatto email non richiede Pages. Non usare URL localhost, file locali o raw.githubusercontent come URL finali.

Controllare nome, recapito e impegni sulla gestione delle richieste email nella policy. Le pagine non hanno analytics, moduli, cookie applicativi o font esterni. Il testo distingue dati locali, servizio Apple, richieste email e hosting GitHub. [Guida GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).

## 2. Creare/verificare l'app Apple

Nel proprio account Apple Developer verificare l'App ID esplicito `com.ignaciomustacho.shadowbasketball` con Game Center. In App Store Connect creare/verificare l'app iOS associata: nome Ignacio Mustacho, lingua principale English (U.K.), SKU proposto `ignacio-mustacho-ios` (interno, verificare unicità). Non usare il vecchio bundle `com.prototype.ignaciomustacho`.

Completare eventuali accordi/account richiesti da Apple. Inserire privatamente il numero di telefono del contatto App Review: non serve pubblicarlo su GitHub. Scegliere paesi di distribuzione e stato DSA trader/non-trader se richiesto; queste informazioni non sono deducibili dal codice. Confermare i diritti sugli asset forniti. Prezzo: Free. Nessun acquisto o abbonamento da configurare.

## 3. Configurare Game Center

Seguire `../GameCenter/SETUP.md`, con i JSON e i sei PNG già pronti. La configurazione locale non crea i record Apple. Completare le prove online indicate prima di inviare la versione che espone quei pulsanti.

## 4. Scheda, privacy e classificazione

Usare `STORE-LISTING.md`, i file `.txt` e `PRIVACY-AND-RATING.md`. Selezionare i quattro screenshot in `../Screenshots`; icona già nel binario. Le dichiarazioni privacy/classificazione sono proposte basate sul codice, da confermare nel questionario Apple. Non dichiarare supporto completo VoiceOver/Dynamic Type senza la verifica dedicata.

## 5. Distribuzione e prova fisica

Aprire il nuovo archivio indicato in `BUILD-STATUS.md` in Xcode Organizer. Usare Validate App / Distribute App → App Store Connect e la firma di distribuzione del proprio account. Il controllo locale della firma non equivale alla validazione Apple. Verificare versione/build: se 1.0 (1) è già stato caricato, aumentare `CURRENT_PROJECT_VERSION` e ricreare l'archivio prima di procedere.

Caricare su TestFlight e provare con `TestFlight-what-to-test-en.txt`, incluse latenza touch/audio, Silent mode, background e Game Center. La build non contiene un account app proprietario: nessuna credenziale demo da inventare. Per il primo lancio si propone rilascio manuale dopo approvazione, così puoi verificare che tutti i componenti siano pronti.

## 6. Invio

Selezionare la build elaborata, completare note review e contatti, risposte export compliance, privacy, età, territori e prezzo; associare i componenti Game Center alla versione/review. Inviare ad App Review solo quando i controlli precedenti sono completati. Nessun invio Apple viene eseguito da questi file.
