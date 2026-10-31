# Progressione estesa

La velocità cresce ogni quattro comandi: 100, 120, 140, 160, 180 BPM, poi +5 BPM per stadio fino a 320 BPM al comando 129 / PACE 33. Quattro beat per richiesta, da 2,40 s a 0,75 s nominali. Comandi 17/33/65/97: 180/200/240/280 BPM. Tutorial e primi quattro comandi restano accessibili. Il progresso è basato sui comandi: a 57 punti non si entra in un plateau.

Good parte da ±400 ms e arriva a ±159 ms, Perfect da ±140 a ±80 ms. Indicatore e accettazione usano lo stesso intervallo. Uno swipe iniziato nella finestra mantiene fino a 450 ms per concludersi; un contatto vecchio non può giudicare il comando successivo. Se il riconoscimento termina molto tardi, il nuovo bersaglio viene distanziato per garantire tre beat di preavviso. Dopo celebrazioni: quattro beat nuovi, senza penalità.

Note d’organo da 320 ms accorciate fino a circa 169 ms tramite playback rate, entro il fattore 2 supportato. `enableRate` viene impostato prima di `prepareToPlay`, come richiede [AVAudioPlayer](https://developer.apple.com/documentation/avfaudio/avaudioplayer/enablerate). Animazioni di gioco da 850 a 391 ms; tutte le dodici pose visitate anche a 60 Hz. Reazioni celebrative invariate a 1,35 s. Battuta game over solo scritta; annunci delle mosse mantenuti.

Regressioni: crescita oltre il vecchio ceiling, 160 comandi, bordi NOW a tutti gli stadi, swipe/tap tardivi alla massima velocità, nessuna doppia penalità, spazio tra note e tra animazioni, partita completa con sei celebrazioni, pausa e ripresa. 31 test Domain, 19 app e 8 UI superati. Verifica audio finale mirata dopo l’impostazione AVAudioPlayer. La latenza touch/audio reale su iPhone resta da misurare; non viene dichiarata precisione sample-accurate.

Per provare: Play, osservare PACE/BPM e il countdown. L’incremento è ogni quattro comandi, anche dopo il vecchio PACE 5. Il test `testLongRunKeepsAcceleratingAcrossAllCelebrationsAndPause` attraversa automaticamente tutti gli stadi con clock iniettato, senza creare record reali o inviare punteggi Game Center. L’anteprima audio storica `Arena-Audio-Preview.wav` è precedente a questa curva e non viene usata dall’app.
