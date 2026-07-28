# Skleep

**Skleep – Pricing & Margin Intelligence** è una piattaforma privata di price intelligence, controllo margini e gestione degli sconti per più negozi, Paesi e canali.

## Identità del prodotto

- **Nome:** Skleep
- **Payoff:** Pricing & Margin Intelligence
- **Principio:** Skleep non abbassa semplicemente i prezzi: aiuta a prendere la migliore decisione economica.

## Obiettivo

Determinare il prezzo sostenibile e lo sconto consigliato per ogni combinazione:

`Prodotto × Paese × Canale × Metodo di pagamento × Corriere`

La piattaforma non modifica mai il prezzo di listino Shopify. Può proporre e, solo dopo autorizzazione, aggiornare lo sconto o il prezzo promozionale consentito dal canale.

## I cinque motori

1. **Data Engine** – raccoglie e normalizza prodotti, costi, offerte, listini e ordini.
2. **Rule Engine** – applica regole commerciali, fiscali, logistiche ed economiche versionate.
3. **Pricing Engine** – calcola costo totale, margine, prezzo minimo e proposta.
4. **Workflow Engine** – gestisce approvazioni, audit, notifiche e pubblicazione.
5. **AI Assistant** – cerca anomalie, spiega e propone; non applica modifiche operative.

## Principi non negoziabili

- List price invariato.
- Vincoli commerciali prima dei competitor.
- Nessuna proposta senza dati minimi affidabili.
- Ogni calcolo deve essere spiegabile e riproducibile.
- Le configurazioni sono versionate e con date di validità.
- L'AI non sostituisce l'approvazione umana.
- Shopify, Amazon, eBay e altri sistemi sono adapter, non il cuore della piattaforma.

## Avvio rapido

1. Leggere `docs/STEP_BY_STEP.md`.
2. Creare un progetto Supabase vuoto.
3. Eseguire `supabase/schema.sql` nel SQL Editor.
4. Eseguire facoltativamente `supabase/seed_demo.sql`.
5. Creare l'interfaccia con i prompt in `lovable/`.
6. Implementare i contratti backend presenti in `backend/`.

## Struttura

- `docs/` – architettura, regole, MVP, UX, roadmap e guida operativa.
- `supabase/` – schema consolidato e dati demo.
- `backend/` – contratti TypeScript e scheletro dei motori.
- `lovable/` – prompt ordinati per costruire l'interfaccia.
- `templates/` – CSV per importazioni iniziali.
