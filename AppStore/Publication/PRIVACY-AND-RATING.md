# Risposte preparate — conferma finale in App Store Connect

Valutazione sul codice corrente del 31 ottobre 2026. Queste note non inviano dichiarazioni all'account Apple.

## App Privacy

**Proposta per questa build: Data Not Collected**, purché il proprietario non aggiunga server, analytics, SDK pubblicitari o raccolte esterne di dati giocatore. È un'inferenza dal codice, non una risposta già approvata da Apple.

Motivo: record, preferenze, progresso e identificativo Game Center usato per le conferme restano in UserDefaults. L'app non trasmette dati a server dello sviluppatore. I soli invii di gioco sono verso Apple tramite GameKit; Apple chiarisce che la raccolta svolta da Apple non è a carico dello sviluppatore nella dichiarazione, mentre eventuali dati raccolti dallo sviluppatore da servizi Apple vanno dichiarati. Non equiparare quindi il manifest locale alla privacy del servizio Apple. [Definizioni e FAQ Apple](https://developer.apple.com/app-store/app-privacy-details/).

| Voce | Proposta / riscontro |
| --- | --- |
| Tracking | No |
| Pubblicità / IDFA | Nessuno |
| Analytics SDK propri o terzi | Nessuno |
| Dati conservati esclusivamente sul dispositivo | Record, preferenze, premi, player ID Game Center e conferme sync |
| Servizio Apple opzionale | Punteggi e percentuali achievement associati all'account Game Center |
| Email di supporto | Inviata volontariamente fuori dall'app; valutare di nuovo la dichiarazione se si aggiunge un modulo o una raccolta sistematica nell'app |
| Website | Hosting GitHub separato dall'app, senza analytics aggiunti; log tecnici del provider descritti nella policy |

Non affermare che Apple non raccolga dati. La policy pubblica descrive Game Center e rimanda alla [privacy Apple](https://www.apple.com/legal/privacy/data/en/game-center/). Se si iniziano a scaricare/conservare dati dei giocatori su un backend, rivedere questa proposta prima dell'upload. Il manifest attuale dichiara nessun tracking e motivi per UserDefaults/clock; non è un sostituto del questionario App Store.

## Questionario età

Non assegnare manualmente “4+” come conclusione: Apple calcola il risultato dalle risposte. In particolare, i contest includono competizioni per classifica o obiettivi e non soltanto scommesse. Con classifica persistente e sfida al record, la proposta prudente è **Contests: Frequent**, da confermare nel questionario effettivo; questo può produrre una fascia 13+ nel sistema corrente. Non rispondere “nessuno” solo perché non ci sono premi in denaro. [Definizioni Apple](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/).

| Contenuto o funzione | Risposta proposta |
| --- | --- |
| Violenza realistica/cartoon, armi | None: movimenti sportivi senza combattimento |
| Sesso/nudità, temi maturi, paura, droghe/alcol/tabacco | None |
| Linguaggio volgare / umorismo scurrile | None: battute di vanità senza contenuti volgari |
| Informazioni mediche/salute | None: nessun consiglio di salute o tracking fitness |
| Gioco d'azzardo e simulato | None |
| Loot boxes | No |
| Contests | Frequent, vedi motivazione sopra |
| Pubblicità | No |
| Accesso web illimitato | No: solo link specifico privacy e composizione email, nessun browser libero incorporato |
| Chat/social media/UGC | Nessuna funzione proprietaria. Verificare i profili, soprannomi e funzioni social effettivamente accessibili nel dashboard Game Center prima di rispondere alle capacità |
| Parental controls / age assurance nell'app | No: non implementati; controlli Apple esterni non sono una funzione propria |
| Made for Kids | Non selezionato; non è stata preparata una pubblicazione nella categoria Kids |

## Export compliance e altre dichiarazioni

Il plist contiene `ITSAppUsesNonExemptEncryption = false`. Il codice esaminato usa framework Apple e non implementa crittografia propria: confermare nel flusso di upload l'uso dei servizi di sistema e l'eventuale esenzione, senza dichiarare assenza assoluta di crittografia nel trasporto. Non sono stati preparati documenti crittografici aggiuntivi.

Nome, email e gratuità sono confermati. Restano personali: telefono review, territori, stato commerciale/DSA ove richiesto, accettazione accordi e titolarità/licenze degli asset forniti. Non inventare dichiarazioni commerciali o fiscali.

Accessibilità: testo oltre ai colori, pulsanti alternativi e Reduce Motion sono implementati; non spuntare dichiarazioni di pieno supporto VoiceOver, Larger Text o altre etichette senza completare la valutazione relativa sul dispositivo.
