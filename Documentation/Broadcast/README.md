# Revisione broadcast — 31 ottobre 2026

[Confronto prima/dopo](index.html) con la versione verde/arancio/oro effettiva del commit `23ea317`. Il riferimento è la grafica delle trasmissioni di basket americano: nessun logo NBA, squadra o affiliazione aggiunto.

## Design implementato

- Navy profondo `#091329`, rosso atletico `#C9172B`, bianco freddo e carbone. Accenti decorativi verdi, arancioni e dorati rimossi dalle schermate pubbliche.
- Titoli Helvetica Neue Bold e testo di sistema, con numeri a larghezza fissa. Ridotte dimensioni, tracking e ripetizioni degli slogan; eliminati font condensati pesanti, ombre del titolo e timbri inclinati.
- Home con nome allineato a sinistra, marchio tipografico IM e azione principale rossa. Il personaggio conserva le pose esistenti; i testi ironici restano come dettagli secondari.
- Scheda comando con barra laterale rossa, punteggio bianco e pannello timing chiaro. La finestra valida resta delineata, con il centro del beat e NOW espliciti. Successo ed errore hanno testo e simboli di conferma/croce, oltre al colore.
- Celebrazioni senza alone dorato, con piccoli elementi rossi e argento. Finale e record usano la stessa gerarchia da tabellone. Guida, pausa e Sound check aggiornati coerentemente.
- L’arena originale è composta con una sfumatura navy in SwiftUI: spalti attenuati e parquet naturale visibile. Anche il launch screen usa una copertura navy. Nessuna ricolorazione dei raster tramite script, nessuna nuova interpretazione del personaggio o delle animazioni. Divisa, volto e icona illustrata del personaggio rimangono quelli originali; il ritratto con cornice dorata non è più usato come marchio nella Home.
- Screenshot promozionali e sei badge vettoriali locali aggiornati alla nuova palette e tipografia. Nessun contenuto pubblicato su Apple.

Il bianco sul rosso principale ha contrasto circa 5,49:1; argento su navy circa 11,08:1. I comandi testuali delle barre scure usano bianco, evitando il rosso su navy per il testo piccolo. Non è una certificazione completa di accessibilità: Dynamic Type estremo e percorso VoiceOver richiedono ancora QA dedicata.

## Provenienza delle immagini

`Before` conserva le catture grandi della rifinitura precedente. `After-Large` e `After-Small` contengono allegati XCUITest dei nuovi layout. I manifest associano file e test; `manifest-final.json` e poi `manifest-input.json` sostituiscono le immagini omonime dopo gli ultimi aggiustamenti.

Milestone10, Pace320 e GestureRecognitionQA sono scene DEBUG a clock fermo con stato sintetico, destinate esclusivamente al controllo del layout. Non producono record e non vengono usate nei quattro screenshot promozionali. Home, guida, timing e finale promozionali provengono dai normali percorsi UI.

## Ambito

Nessuna modifica a Domain, punteggio, progressione 100–320 BPM, durata delle animazioni, regole dei gesti, preferenze persistenti o rimozione della voce finale. Nessuna modifica di firma/account. La build firmata storica resta precedente a queste revisioni; la consegna verificata è per simulatore.

## Verifiche

- 22 test app superati sulla revisione, nuovamente superati sulla versione finale nel controllo piccolo; include audio, preferenze, punteggio, animazioni, premi e font realmente usato.
- Tutti i 12 percorsi UI verificati su iPhone 18 Pro e iPhone 18 Pro Max, combinando suite completa e ripetizioni mirate dei test corretti. Home, partita, guida, pausa, audio, record, finale, celebrazione e 320 BPM hanno catture aggiornate.
- Durante le prime suite sono emerse dipendenze dal tempo reale nei test: quattro swipe potevano attraversare un cambio comando e l’esportazione dello screenshot del tutorial poteva consumare la prima finestra NOW. Il test di riconoscimento ora usa la scena DEBUG esistente a clock fermo, con gli stessi quattro assert sui gesti fisici. Il test tutorial attende una finestra NOW reale prima di acquisire lo screenshot, senza richiedere che sia il primo comando. Scoring, contatti scaduti e transizioni restano coperti dai test con clock iniettato. Nessuna regola di produzione modificata per far passare i test.
- Sul piccolo: suite iniziale 10/12 UI, poi entrambi i test corretti superati insieme ai 22 test app (`/tmp/ignacio-broadcast-small-input.xcresult`). Sul grande: suite iniziale 22 app e 11/12 UI, quattro controlli mirati superati dopo il contrasto, poi entrambi i test UI corretti superati (`/tmp/ignacio-broadcast-large-input.xcresult`). Una precedente esecuzione piccola concorrente è stata interrotta per ridurre il carico.
- I 32 test Domain della baseline precedente restano validi: nessun file Domain, Data o GameModel è cambiato in questa revisione.
- Build Release finale per simulatore generico superata (`/tmp/ignacio-broadcast-release-final.log`), incluse le ultime modifiche di contrasto.
- Formattazione Swift rigorosa, `git diff --check`, collegamenti della galleria, quattro PNG promozionali 1320×2868 RGB e sei badge 1024×1024 RGB verificati. SwiftLint non installato.

Le catture sono versionate; i risultati Xcode temporanei in `/tmp` no. Verifica hardware, latenza audio/touch e Game Center online restano da eseguire. Questa revisione viene salvata in un commit locale; nessun nuovo push o upload Apple durante la consegna.
