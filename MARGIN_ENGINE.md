# Motore del margine

## Unità di calcolo

`Prodotto × Paese × Canale × Metodo di pagamento × Corriere × Data`

## Componenti

### Ricavi

- prezzo lordo;
- sconto;
- spedizione pagata dal cliente;
- altri contributi;
- IVA o imposte indirette;
- conversione valuta.

### Costi

- prodotto o componenti bundle;
- packaging;
- logistica;
- spedizione;
- supplementi corriere;
- commissione provider di pagamento;
- commissione marketplace;
- costo pubblicitario attribuito;
- costo atteso dei resi;
- dazi e oneri;
- altri costi variabili.

## Formule operative

- `prezzo_finale = prezzo_listino × (1 - sconto_pct)`
- `ricavo_netto_imposte = prezzo_finale / (1 + aliquota_imposta)` quando il prezzo è IVA inclusa
- `spedizione_netto_azienda = max(0, costo_corriere - contributo_cliente)`
- `costo_totale = somma di tutti i costi applicabili`
- `margine_valore = ricavo_netto_imposte - costo_totale`
- `margine_pct = margine_valore / ricavo_netto_imposte × 100`

La base percentuale deve essere esplicita e configurabile per ogni commissione: lordo, netto imposte, totale ordine, spedizione inclusa o esclusa.

## Margine per nazione

Ogni Paese può avere:

- aliquote differenti;
- costi di spedizione differenti;
- resi attesi differenti;
- commissioni differenti;
- regole di margine differenti;
- valuta differente;
- vincoli commerciali differenti.

Non copiare automaticamente prezzi o sconti tra Paesi.

## Bundle

Il costo del bundle include:

- somma dei componenti per quantità;
- eventuali override di costo;
- packaging del bundle;
- logistica;
- uno o più colli;
- spedizione calcolata sul collo finale;
- commissioni applicate alla vendita del bundle.

## Snapshot

Non usare un campo margine statico come fonte. Ogni proposta salva un `calculation_snapshot` con input, regole, versioni e risultato, per poter ricostruire la decisione storica.
