# Architettura funzionale

## 1. Data Engine

Responsabilità:

- importare cataloghi e costi;
- normalizzare EAN, SKU, brand, categorie e valute;
- importare offerte competitor;
- importare listini corrieri, provider e marketplace;
- mantenere dati grezzi separati dai dati normalizzati;
- assegnare stato di qualità e data di aggiornamento.

Il Data Engine non prende decisioni di pricing.

## 2. Rule Engine

Tutte le regole condividono una struttura comune:

- tipo;
- ambito;
- condizioni;
- effetto;
- priorità;
- periodo di validità;
- versione;
- stato;
- fonte;
- approvazione.

Gli ambiti possono includere prodotto, brand, categoria, fornitore, Paese, canale, metodo di pagamento e corriere.

### Ordine iniziale di valutazione

1. blocchi commerciali e legali;
2. prezzo concordato, sconto massimo e margine dedicato;
3. qualità e completezza dei dati;
4. imposte e valuta;
5. costo prodotto o bundle;
6. costi logistici e di spedizione;
7. commissioni di pagamento e marketplace;
8. costo atteso dei resi e pubblicità;
9. margine minimo;
10. strategia commerciale;
11. competitor eleggibili;
12. proposta e livello di approvazione.

L'ordine è configurabile, ma le regole di sicurezza non possono essere spostate sotto le strategie commerciali.

## 3. Pricing Engine

Produce:

- ricavo netto;
- costo totale della vendita;
- margine in valuta;
- margine percentuale;
- prezzo minimo sostenibile;
- sconto massimo sostenibile;
- prezzo suggerito;
- confidence score;
- spiegazione strutturata;
- elenco delle regole applicate.

Il calcolo e la strategia sono separati:

- il calcolo stabilisce l'intervallo consentito;
- la strategia seleziona un prezzo dentro quell'intervallo.

## 4. Workflow Engine

Gestisce:

- creazione proposta;
- assegnazione;
- approvazione o rifiuto;
- override owner motivato;
- applicazione tramite adapter;
- verifica dell'esito;
- rollback;
- notifiche;
- audit ed eventi.

## 5. AI Assistant

Può:

- spiegare una proposta;
- rilevare dati mancanti o incoerenti;
- confrontare una tariffa interna con una fonte ufficiale;
- leggere listini caricati;
- proporre una regola in bozza;
- raggruppare anomalie;
- suggerire priorità.

Non può:

- attivare regole;
- modificare costi verificati;
- approvare proposte;
- applicare sconti;
- ignorare un vincolo commerciale.

## Adapter

Ogni integrazione implementa un contratto stabile:

- catalog adapter;
- sales channel adapter;
- payment adapter;
- carrier adapter;
- competitor source adapter;
- notification adapter.

Il dominio centrale non dipende da Shopify, Amazon, Stripe o DHL.
