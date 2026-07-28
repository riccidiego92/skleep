# Rule Engine

## Obiettivo

Evitare logica sparsa nel codice e consentire l'aggiunta futura di nuove regole senza modificare il motore centrale.

## Modello

Ogni regola contiene:

- `rule_type`: cosa controlla;
- `scope`: dove si applica;
- `conditions`: condizioni JSON dichiarative;
- `effect`: risultato JSON dichiarativo;
- `priority`: ordine tra regole dello stesso livello;
- `valid_from` e `valid_to`;
- `version`;
- `status`: draft, pending_approval, active, suspended, expired, archived;
- `source_type`: contract, manual, official, ai_proposal, estimate;
- `approval_required`.

## Tipi iniziali

### Sicurezza commerciale

- `hard_lock`
- `monitor_only`
- `owner_approval`
- `fixed_price`
- `minimum_price`
- `maximum_discount`
- `minimum_margin`

### Costi

- `product_cost`
- `packaging_cost`
- `logistics_cost`
- `payment_fee`
- `marketplace_fee`
- `advertising_cost`
- `return_cost`
- `currency_conversion_cost`
- `tax_rate`
- `carrier_rate`
- `carrier_surcharge`

### Strategia

- `leader`
- `balanced`
- `premium`
- `margin_first`
- `clear_stock`
- `monitor_only_strategy`

## Gerarchia di specificità

A parità di tipo, prevale la regola più specifica:

1. prodotto + Paese + canale;
2. prodotto;
3. brand + Paese + canale;
4. categoria + Paese + canale;
5. fornitore + Paese;
6. canale + Paese;
7. Paese;
8. globale.

La priorità numerica risolve i conflitti nello stesso livello di specificità.

## Conflitti

- un hard lock prevale sempre;
- il prezzo minimo più alto prevale;
- lo sconto massimo più basso prevale;
- il margine minimo più alto prevale;
- una tariffa contrattuale prevale su una tariffa pubblica;
- una regola manuale verificata prevale su una proposta AI.

## Regole in bozza

L'AI può creare solo regole `draft` con `source_type = ai_proposal`. Un utente autorizzato deve approvarle.
