insert into countries(code, name, currency) values
('IT','Italia','EUR'),('FR','Francia','EUR'),('DE','Germania','EUR'),('ES','Spagna','EUR'),
('AT','Austria','EUR'),('BE','Belgio','EUR'),('NL','Paesi Bassi','EUR'),('PT','Portogallo','EUR'),('PL','Polonia','PLN')
on conflict (code) do nothing;

-- Creare prima organizzazione e profilo owner dall'applicazione o sostituire gli UUID.
-- Questo seed evita volutamente credenziali e segreti.
