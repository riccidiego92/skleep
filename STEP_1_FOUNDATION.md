# Prompt Lovable — Skleep Step 1: Fondazione

Crea **Skleep**, una web app privata B2B per price intelligence e controllo margini.

## Vincoli tecnici

- Usa Supabase per autenticazione e dati.
- Accesso solo su invito.
- Ruoli: owner, admin, pricing_manager, operator, viewer.
- Non implementare formule economiche complesse nel frontend.
- Il frontend deve consumare risultati già calcolati dal backend.
- Non consentire mai la modifica del prezzo di listino Shopify.

## Branding

- Nome visibile: **Skleep**.
- Sottotitolo: **Pricing & Margin Intelligence**.
- Usa il nome Skleep nel login, nella sidebar, nel titolo pagina e nelle email di invito.
- Mantieni un’identità pulita, professionale e B2B.

## Layout

Navigazione:

1. Attività
2. Catalogo
3. Proposte
4. Costi e regole
5. Competitor
6. Simulatori
7. Report
8. Impostazioni

## Home

Mostra card operative, non molti grafici:

- sotto margine;
- proposte da approvare;
- dati mancanti;
- tariffe da verificare;
- sincronizzazioni fallite;
- opportunità di aumento prezzo.

## Catalogo

Tabella con:

- immagine;
- EAN/SKU;
- titolo;
- tipo single/bundle;
- brand;
- list price;
- sconto corrente;
- prezzo finale;
- costo disponibile;
- margine indicativo;
- stato regole;
- qualità dati.

Aggiungi filtri e ricerca globale.
