# Screenshot: scegliere il riquadro corretto

Aggiornamento 31 ottobre 2026. Caricare i quattro PNG della cartella corrispondente, non lo ZIP né le immagini di Verification/RawScreenshots.

| Riquadro App Store Connect | Dimensioni | Cartella |
| --- | --- | --- |
| iPhone con Dynamic Island — display medio (obbligatorio nelle specifiche attuali) | 1206 × 2622 | `Dynamic-Island-Medium-1206x2622/` |
| iPhone con Dynamic Island — display grande (precedentemente 6,9″) | 1320 × 2868 | i quattro PNG direttamente in questa cartella |
| iPhone con Face ID — display grande (precedentemente 6,5″) | 1242 × 2688 | `Face-ID-Large-1242x2688/` |

Non mescolare dimensioni nello stesso riquadro. I PNG sono RGB senza trasparenza. Il layout viene riesportato dal generatore originale mantenendo proporzioni e contenuti delle catture; nessuno stiramento dell'interfaccia.

La precedente indicazione del solo formato 6,9″ era incompleta rispetto alle specifiche attuali. I file 1320 × 2868 restano validi nel riquadro grande.

Fonte: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/

Rigenerazione dalla radice:

```sh
swift -module-cache-path /tmp/ignacio-screenshot-module-cache Scripts/make_store_screenshots.swift 1206 2622 AppStore/Screenshots/Dynamic-Island-Medium-1206x2622
swift -module-cache-path /tmp/ignacio-screenshot-module-cache Scripts/make_store_screenshots.swift 1242 2688 AppStore/Screenshots/Face-ID-Large-1242x2688
python3 Scripts/verify_publication.py
```
