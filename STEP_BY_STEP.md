# Guida passo per passo

## Fase 0 — Decisioni iniziali

Per il primo MVP usare:

- un solo negozio;
- Italia come Paese principale;
- EUR;
- Shopify come canale proprietario;
- approvazione manuale obbligatoria;
- 50–100 SKU rappresentativi;
- almeno 5 bundle;
- almeno 5 prodotti con vincolo commerciale.

Non partire con 4.500 SKU: prima verificare qualità dei dati, calcoli e usabilità.

## Fase 1 — Supabase

1. Creare un nuovo progetto Supabase.
2. Aprire SQL Editor.
3. Incollare ed eseguire `supabase/schema.sql`.
4. Controllare che le tabelle siano state create.
5. Eseguire `supabase/seed_demo.sql` solo nell'ambiente di test.
6. Creare il primo utente tramite Supabase Auth.
7. Assegnargli il ruolo `owner` nella tabella `profiles`.

Risultato atteso: database pronto, senza ancora collegamenti esterni.

## Fase 2 — Interfaccia Lovable

Usare in ordine:

1. `lovable/STEP_1_FOUNDATION.md`
2. `lovable/STEP_2_COSTS_RULES.md`
3. `lovable/STEP_3_PRICING_WORKFLOW.md`

Non inserire logica economica complessa nel frontend. Lovable deve chiamare funzioni backend o RPC e mostrare i risultati.

## Fase 3 — Dati minimi

Importare:

- prodotti;
- identificatori;
- costi;
- bundle;
- Paesi;
- aliquote fiscali;
- provider di pagamento;
- canali;
- corrieri e fasce tariffarie;
- regole di margine;
- vincoli commerciali.

I template CSV sono nella cartella `templates/`.

## Fase 4 — Backend

Implementare nell'ordine:

1. `Data Engine`: validazione e normalizzazione.
2. `Rule Engine`: selezione delle regole applicabili.
3. `Cost Calculator`: dettaglio completo dei costi.
4. `Pricing Engine`: prezzo minimo e proposta.
5. `Explain Engine`: motivazione leggibile.
6. `Workflow Engine`: approvazione e audit.
7. Adapter Shopify in modalità test.

## Fase 5 — Collaudo

Creare almeno questi casi:

- prodotto senza costi;
- prodotto con hard lock;
- prezzo sotto minimo concordato;
- bundle equivalente e non equivalente;
- PayPal rispetto a bonifico;
- Shopify rispetto ad Amazon;
- Italia rispetto a Francia;
- spedizione gratuita rispetto a contributo cliente;
- corriere con peso volumetrico;
- proposta sotto margine.

Ogni caso deve produrre sia numeri sia spiegazione.

## Fase 6 — Pilot

1. Attivare 50–100 SKU.
2. Non applicare automaticamente nulla.
3. Confrontare per 2–4 settimane i risultati con calcoli manuali.
4. Correggere dati e regole.
5. Solo dopo estendere il catalogo.

## Fase 7 — Automazione controllata

Automatizzare inizialmente solo prodotti a basso rischio:

- nessun vincolo commerciale;
- dati completi;
- confidence alto;
- variazione entro una soglia ridotta;
- margine ampiamente sopra il minimo;
- rollback disponibile.
