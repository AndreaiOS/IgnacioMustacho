# Premi, finali e verifica — 31 ottobre 2026

Sei soglie numeriche: 10 Tiny Flex, 23 MJ-ish, 33 Bench Legend, 50 Self-Applause, 81 Imaginary MVP, 100 Hall of Me. Ogni reazione ha 12 pose, una battuta inglese e una breve fanfara di organo originale. Cinque finali dipendono dal punteggio. La pausa celebrativa congela input e clock; il comando seguente dispone di un countdown intero. Nessuna rappresentazione o voce di atleti reali.

- [Video delle sei animazioni](Ignacio-Rewards-Review.mp4): review DEBUG su iPhone 18 Pro; nessun punteggio simulato usato negli screenshot promozionali.
- [Schermata dei sei premi](../AppStore/RawScreenshots/RewardAnimations.png).
- [Finale reale a zero punti](../AppStore/RawScreenshots/GameOver.png).
- [Materiali App Store](../AppStore/README.md), quattro screenshot promozionali, icona e sei badge Game Center.

## Verifica

28 test Domain superati. Suite completa iPhone 18 Pro Max: 15 test app e 8 UI superati. Dopo l’ultima correzione che interrompe il suono quando si salta una celebrazione: 15 test app e 2 UI mirati superati su iPhone 18 Pro. Swift-format lint senza errori; SwiftLint non installato. Verificati visivamente griglia reazioni su entrambi i formati, schermata finale, badge e screenshot promozionale. Controllati RGB/dimensioni, limiti dei metadati e assenza di clipping PCM nei sei stacchi audio.

I test coprono attraversamento soglie, deduplica, reset per run, esclusione tutorial, pausa lunga e ripresa del countdown, persistenza offline, errore di rete con retry, cambio giocatore e nuovi progressi durante un invio in corso. Il trasporto Game Center nei test è iniettato: l’integrazione reale con Apple resta da verificare.

Archivio corrente `BuildArtifacts/Ignacio-1.0-1-Current.xcarchive`, nuovo bundle ID `com.ignaciomustacho.shadowbasketball`, packaging e firma di sviluppo verificati. Nessun upload Apple e nessuna installazione su telefono fisico effettuati dall’agente.

## Provenienza

Reazioni generate con imagegen integrato, seguendo l’identità canonica fornita dall’utente. Prompt esatti in [Celebration-Prompts.json](Celebration-Prompts.json) e [Celebration-Extra-Prompts.json](Celebration-Extra-Prompts.json), inclusa la correzione di inquadratura di Bench Legend. I PNG creativi restano intatti; `Scripts/analyze_sprite_layout.py` legge alpha e geometria per produrre i ritagli runtime. Badge originali vettoriali esportati da `Scripts/make_achievement_badges.swift`. Organo originale generato da `Scripts/make_arena_audio.py`. Nessuna licenza di terzi o dichiarazione di diritti commerciali inventata.
