DROP SCHEMA IF EXISTS carsharing CASCADE;
CREATE SCHEMA carsharing;
SET search_path TO carsharing;

CREATE TABLE Indirizzo (
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	PRIMARY KEY(nazione, citta, cap, civico,via)
);

CREATE TABLE Categoria (
	categoria varchar (20) PRIMARY KEY
);

CREATE TABLE Modello (
	NomeModello varchar(20) PRIMARY KEY,
	lunghezza numeric(6,2) NOT NULL,
	larghezza numeric(6,2) NOT NULL,
	altezza	numeric(6,2) NOT NULL,
	Nporte smallint NOT NULL,	
	consumo	numeric(4,2),
	velocita smallint NOT NULL,	
	motorizzazione smallint,
	capBagagliaio numeric(6,2) NOT NULL,	
	Toraria	numeric(5,2) NOT NULL,
	Tgiornaliera numeric(5,2) NOT NULL,	
	Tsettimanale numeric(5,2) NOT NULL,
	Tchilometrica numeric(5,2) NOT NULL,
	TgiornalieraAggiuntiva numeric(6,2) NOT NULL,
	categoria  varchar (20) NOT NULL 
	REFERENCES Categoria
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	aria bool NULL,
	servoS bool NULL,
	airBag bool NULL
);

CREATE TABLE Fatturazione (
	numeroFattura serial PRIMARY KEY,
	penale numeric,
	totaleFatt numeric,
	chilometriPercorsi numeric, 
	TempoNonUsufruito numeric,
	TempoUsufruito numeric,
	TempoAnnullato numeric,
	CHECK(TempoUsufruito + TempoNonUsufruito > 0)
);
/* check TempoUsufruito + TempoNonUsufruito > 0 */
/* trigger TempoAnnullato > 0 ==> TempoNonUsufruito > 0*/
CREATE TABLE Tipo (
	periodo	varchar(20) PRIMARY KEY,
	ngiorni int, /* aggiunto per insertAbbonamento, numero di giorni */
	costo numeric NOT NULL,
	riduzioneEta numeric NuLL
);
/* periodo annuale, bimestrale, semestrale, mensile, settimanale...*/

CREATE TABLE Carta (
	numero numeric(16,0) NOT NULL, 
	circuito varchar(16) NOT NULL,
	intestatario varchar(30) NOT NULL,
	scadenza date NOT NULL ,
	PRIMARY KEY(numero,circuito,intestatario,scadenza)
	
);

CREATE TABLE Rid (
	codIban char(27) NOT NULL, 
	intestatario varchar(30) NOT NULL,
	PRIMARY KEY(codIban,Intestatario)
);

CREATE TABLE MetodoDiPagamento (
	numSmartCard serial PRIMARY KEY,
	versato numeric, 
	numeroCarta numeric(16,0), 
	intestatarioCarta varchar(30),		
	circuitoCarta varchar(10),
	scadenzaCarta date,
	codIban char(27), 
	intestatarioConto varchar(30),
	FOREIGN KEY(codIban,IntestatarioConto) 
	REFERENCES Rid(codIban,intestatario)
	ON UPDATE CASCADE
	ON DELETE CASCADE,	
	FOREIGN KEY (numeroCarta,circuitoCarta,IntestatarioCarta,scadenzaCarta)
	REFERENCES Carta(numero, circuito, intestatario,scadenza)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	
);

/* TRIGGER se versato non e' null prepagato */
CREATE TABLE Abbonamento (
	dataInizio timestamp NOT NULL,	
	dataFine timestamp NOT NULL,
	dataBonus date,
	bonusRottamazione numeric(3,0),
	pinCarta	numeric(4,0) NOT NULL,
	numSmartCard integer NOT NULL references MetodoDiPagamento,
	tipo varchar(20) NOT NULL references Tipo,
	PRIMARY KEY (numSmartCard),
	UNIQUE (numSmartCard, dataInizio)
	
);

CREATE TABLE Parcheggio (
	NomeParcheggio varchar(20) PRIMARY KEY,
	numPosti numeric NOT NULL,
	zona varchar(20) NOT NULL,
	longitudine numeric (14,7) NOT NULL,
	latitudine numeric(14,7) NOT NULL,
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	FOREIGN KEY(nazione,citta,cap,via,civico) 
		REFERENCES Indirizzo (nazione,citta,cap,via,civico)	
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE CategoriaParcheggio(
	id serial primary key,
	NomeParcheggio varchar(20) references Parcheggio,
	categoria varchar(20) References Categoria
);

CREATE TABLE Vettura (
	NomeVettura	varchar(10) PRIMARY KEY,
	targa varchar(7) UNIQUE NOT NULL,
	chilometraggio numeric NOT NULL,
	seggiolini numeric NuLL,
	colore varchar(20) NOT NULL,
	animali bool NOT NULL,
	modello varchar(20) REFERENCES Modello,
	sede varchar(20) REFERENCES Parcheggio
);


CREATE TABLE Prenotazione (
	NumeroPrenotazione serial PRIMARY KEY,
	numSmartCard int NOT NULL, 
	NomeVettura varchar(10) REFERENCES Vettura,
	dataOraInizio timestamp NOT NULL,
	dataOraFine timestamp NOT NULL,
	numeroFattura int
		REFERENCES Fatturazione
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	FOREIGN KEY(numSmartCard)
		REFERENCES Abbonamento(numSmartCard)
	
);

CREATE TABLE ModificaPrenotazione(
	NumeroPrenotazione int REFERENCES Prenotazione,
	dataOraRinuncia timestamp,
	nuovaDataOraInizio timestamp,
	nuovaDataOraRest timestamp,
	PRIMARY KEY(NumeroPrenotazione)
);

CREATE TABLE Rifornimenti (
	targa varchar(7) references Vettura(targa),
	chilometraggio numeric,	
	data date NOT NULL,
	litri numeric NOT NULL,
	PRIMARY KEY (chilometraggio,targa)
	
);

CREATE TABLE Utilizzo (
	NumeroPrenotazione int NOT NULL 
		REFERENCES Prenotazione 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,	
	chilometraggioRitiro numeric(6,0) NOT NULL,
	dataOraRitiro timestamp NOT NULL,
	dataOraRiconsegna timestamp NULL,
	chilometraggioRiconsegna numeric(6,0),
	PRIMARY KEY (NumeroPrenotazione,dataOraRitiro)
	
);



CREATE TABLE Sinistro (
	NumeroPrenotazione int REFERENCES Prenotazione(NumeroPrenotazione), 
	dataOra timestamp,	
	danni varchar NOT NULL,
	dinamica varchar NOT NULL,	
	conducente varchar (40) NOT NULL,
	luogo varchar (100) NOT NULL,
	PRIMARY KEY (numeroPrenotazione, dataOra)
	
);
/*sinistro notificato entro 10 giorni*/

CREATE TABLE Testimoni (
	contatto varchar(30) PRIMARY KEY,	
	nome varchar(10) NOT NULL,
	cognome varchar(15) NOT NULL,
	dataDiNascita date NOT NULL,
	luogoDiNascita varchar(20) NOT NULL
	
);


CREATE TABLE Terzi (
	targa char(7) PRIMARY KEY,
	conducente varchar(25) NOT NULL
);


CREATE TABLE SinistroTestimoni (
	NumeroPrenotazione int NOT NULL,
	dataOra timestamp NOT NULL,
	contatto varchar(20) NOT NULL REFERENCES Testimoni,
	FOREIGN KEY(numeroPrenotazione, dataOra) references Sinistro (numeroPrenotazione, dataOra)
);


CREATE TABLE SinistroTerzi (
	NumeroPrenotazione serial NOT NULL,
	dataOra timestamp NOT NULL,
	targa char(7) NOT NULL REFERENCES terzi,
	FOREIGN KEY(numeroPrenotazione, dataOra) references Sinistro(numeroPrenotazione, dataOra)
);


CREATE TABLE Referente (
	telefono varchar(10) PRIMARY KEY,	
	nome varchar(10) NOT NULL,
	cognome varchar(15) NOT NULL
);


CREATE TABLE Rappresentante (
	nome varchar(10),	
	cognome	varchar(15),
	dataDiNascita date,
	luogoDiNascita	varchar(20) NOT NULL,
	PRIMARY KEY(nome,cognome, dataDiNascita)
	
);

CREATE TABLE Azienda (
	piva numeric(11) PRIMARY KEY,
	ragSociale varchar(30) NOT NULL,
	telefono varchar(10) NOT NULL,	
	telefonoReferente varchar(10) REFERENCES Referente NOT NULL,
	nomeRappresentante varchar(10) NOT NULL,
	cognomeRappresentante varchar(15) NOT NULL,
	dataDiNascitaRappresentante date NOT NULL
	
);

CREATE TABLE Sede(
	idsede serial PRIMARY KEY,
	piva numeric(11) REFERENCES azienda,
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	tipoSede varchar(9) NOT NULL,
	FOREIGN KEY(nazione,citta,cap,via,civico) 
		REFERENCES Indirizzo (nazione,citta,cap,via,civico)	
		ON DELETE CASCADE
		ON UPDATE CASCADE
	
);
/* trigger una azienda non puo avere piu di 1 sede di tipo legale */

CREATE TABLE Documento (
	nrDocumento varchar(10) PRIMARY KEY,
	rilascio date NOT NULL,
	scadenza date NOT NULL,
	professione varchar(30) NOT NULL,
	nome varchar(10) NOT NULL,
	cognome varchar (15) NOT NULL,
	isPatente bool NOT NULL,
	luogoDiNascita varchar(20) NOT NULL,
	dataDiNascita date NOT NULL,
	CategoriaPatente char(1) NULL,
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	FOREIGN KEY (nazione,citta,	cap, civico, via) 
	REFERENCES 	Indirizzo (nazione,citta, cap, civico, via)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE Conducente (
	id_conducente serial PRIMARY KEY,
	piva numeric(11) NULL REFERENCES Azienda, 
	nrDocumento varchar(10) REFERENCES Documento 
	ON DELETE CASCADE 
	ON UPDATE CASCADE,
	nrPatente varchar (10) NOT NULL REFERENCES Documento 
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	UNIQUE (id_conducente,piva,nrDocumento,nrPatente)
);

CREATE TABLE Persona (
	codFisc char(16) NOT NULL PRIMARY KEY,
	id_conducente int references Conducente 
	ON DELETE CASCADE,	
	telefono varchar(11) NOT NULL,
	eta numeric, /* calcolato automaticamente */
	nrDocumento varchar(10) NOT NULL references Documento,
	nrPatente varchar(10) NOT NULL references Documento
	
);
/* numeri italiani 10 cifre nb */

CREATE TABLE Utente (
	email varchar(30) PRIMARY KEY, 
	piva integer REFERENCES Azienda 
	ON UPDATE CASCADE	
	ON DELETE CASCADE,
	codfisc char(16) REFERENCES Persona 
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	numSmartCard int REFERENCES MetodoDiPagamento
);

/** Funzioni utili per l'inserimento **/

SET search_path TO carsharing;

--insertParcheggio: 
CREATE OR REPLACE 
FUNCTION insertParcheggio(varchar(20),numeric,varchar(20),numeric(14,7),numeric(14,7),
		   /* indirizzo */varchar(20),varchar(20),numeric(5,0),numeric(4,0),varchar(20)) 
RETURNS VOID AS $$
DECLARE 
	BEGIN
		IF EXISTS( SELECT * FROM Indirizzo 
				  AS i 
				  WHERE i.nazione = $6 
				  AND i.citta = $7
				  AND i.cap = $8
				  AND i.civico = $9
				  AND i.via= $10)
		THEN
		INSERT INTO Parcheggio VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
		ELSE
			INSERT INTO Indirizzo VALUES ($6,$7,$8,$9,$10) ON CONFLICT DO NOTHING;
			INSERT INTO Parcheggio VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
		END IF;
	END;
$$ LANGUAGE plpgsql ;


--insertDocumento
CREATE OR REPLACE 
FUNCTION insertDocumento(
	nrDocumento varchar(10),rilascio date,scadenza date,professione varchar(30),nome varchar(10),
	cognome varchar (15),isPatente bool ,luogoDiNascita varchar(20), dataDiNascita date,
	CategoriaPatente char(1),nazione1 varchar(20), citta1 varchar(20), cap1 numeric(5,0),
	civico1 numeric(4,0), via1 varchar(20))
	
	RETURNS VOID AS $$ 
	BEGIN
		IF EXISTS( SELECT * FROM Indirizzo 
				  AS i 
				  WHERE i.nazione = nazione1 
				  AND i.citta = citta1
				  AND i.cap = cap1
				  AND i.civico = civico1
				  AND i.via= via1)
		THEN
   		INSERT INTO Documento VALUES (nrDocumento,rilascio,scadenza,professione,nome,cognome,
								 isPatente,luogoDiNascita,dataDiNascita,CategoriaPatente,
								 nazione1,citta1,cap1,civico1,via1);
		ELSE
		INSERT INTO Indirizzo VALUES (nazione1,citta1,cap1,civico1,via1) ON CONFLICT DO NOTHING;
		INSERT INTO Documento VALUES (nrDocumento,rilascio,scadenza,professione,nome,cognome,
								 isPatente,luogoDiNascita,dataDiNascita,CategoriaPatente,
								 nazione1,citta1,cap1,civico1,via1);
		END IF;
	END;
$$ LANGUAGE plpgsql; 

--insertSede
CREATE OR REPLACE 
FUNCTION insertSede(piva numeric(11),nazione1 varchar(20) ,
					citta1 varchar(20),cap1 numeric(5,0),civico1 numeric(4,0) ,
					via1 varchar(20),tipoSede1 varchar(9))

	RETURNS VOID AS $$ 
	BEGIN
		IF EXISTS( SELECT * FROM Indirizzo 
				  AS i 
				  WHERE i.nazione = nazione1 
				  AND i.citta = citta1
				  AND i.cap = cap1
				  AND i.civico = civico1
				  AND i.via= via1)
		THEN
   		INSERT INTO Sede(piva,nazione,citta,cap,civico,via,tipoSede) VALUES (piva,nazione1,citta1,cap1,civico1,via1,tipoSede1);
		ELSE
		INSERT INTO Indirizzo VALUES (nazione1,citta1,cap1,civico1,via1) ON CONFLICT DO NOTHING;
		INSERT INTO Sede(piva,nazione,citta,cap,civico,via,tipoSede) VALUES (piva,nazione1,citta1,cap1,civico1,via1,tipoSede1);
		END IF;
	END;
$$ LANGUAGE plpgsql;


--isSameAddres controlla se due persone Vivono insieme
CREATE OR REPLACE 
FUNCTION isSameAddress(nrPatCond varchar(10), nrDocPer varchar(10))
	RETURNS bool AS $$
	DECLARE
		ind1 record; /* record e` un rowtype assegnato dalla SELECT INTO -- */
		ind2 record;

	BEGIN
		SELECT nazione,citta,cap,civico,via FROM Documento
		natural join indirizzo 
		INTO ind1
		WHERE Documento.nrDocumento = nrPatCond;
		
		SELECT nazione,citta,cap,civico,via FROM Documento
		natural join indirizzo 
		INTO ind2
		WHERE Documento.nrDocumento = nrDocPer;
		
		IF 		ind1.nazione = ind2.nazione 
		AND		ind1.citta = ind2.citta
		AND		ind1.cap = ind2.cap
		AND		ind1.civico = ind2.civico
		AND		ind1.via = ind2.via
			
		THEN
			RAISE NOTICE 'Same addres...ok (%),(%)',ind1,ind2;
			RETURN true;
		ELSE 
			RAISE NOTICE 'Same addres...false (%),(%)',ind1,ind2;
			RETURN false;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--getIdConducente 
CREATE OR REPLACE
FUNCTION getIdConducente(_param_id varchar(10))
RETURNS int AS $$
DECLARE
BEGIN
	RETURN (SELECT id_conducente FROM conducente WHERE nrDocumento = _param_id);
END;
$$ LANGUAGE plpgsql;

--CalcolaEta
CREATE OR REPLACE 
FUNCTION calcolaEta(date)
RETURNS int as $$
DECLARE

BEGIN

	RETURN (SELECT EXTRACT(YEAR FROM age($1)));
END;
$$ LANGUAGE plpgsql;


-- InsertPersona Controlla che un conducente che non sia conducente per una azienda abiti insieme alla persona
CREATE OR REPLACE 
FUNCTION insertPersona(codFisc char(16) ,id_conducente1 int, telefono varchar(11), nrDocumento1 varchar(10),nrPatente varchar(10))
RETURNS VOID AS $$
	DECLARE
		docConduc varchar(10);
		datanascita date;
	BEGIN
		
		SELECT nrDocumento
		INTO docConduc
		FROM conducente 
		WHERE id_conducente = id_conducente1;
		
		SELECT documento.datadinascita 
		INTO datanascita
		FROM Documento
		WHERE documento.nrdocumento = nrDocumento1;
		
		IF id_conducente1 = 0 
		THEN 
			RAISE NOTICE 'nessun conducente aggiuntivo per (%)',codFisc;
			INSERT INTO Persona VALUES (codFisc, NULL, telefono ,calcolaEta(datanascita) , nrDocumento1 , nrPatente); 
		RETURN;
		END IF;
		
		IF docConduc = NULL
			THEN
				INSERT INTO Persona VALUES (codFisc, id_conducente1, telefono ,calcolaEta(datanascita) , nrDocumento1 , nrPatente); 
			ELSE IF isSameAddress(nrPatente,docConduc)
			THEN 
				INSERT INTO Persona VALUES (codFisc, id_conducente1, telefono ,calcolaEta(datanascita) , nrDocumento1 , nrPatente);  
			ELSE
				RAISE EXCEPTION 'Inserimento abortito '
				USING HINT = 'Il conducente scelto non Abita insieme o non esistente';
			END IF;
		END IF;
	END;
$$
LANGUAGE plpgsql;

/*overload carta shorcut */
CREATE OR REPLACE FUNCTION insertMetodo(card int, num numeric,inte varchar,circ varchar,scad date)
RETURNS VOID AS $$
BEGIN
	INSERT INTO carta(numero,circuito,intestatario,scadenza) VALUES (num, circ, inte, scad);
	INSERT INTO MetodoDiPagamento(numsmartcard,numeroCarta,IntestatarioCarta,circuitoCarta,scadenzaCarta) VALUES (card,num,inte,circ,scad);
END;
$$ LANGUAGE plpgsql;

/*overload rid shorcut */
CREATE OR REPLACE FUNCTION insertMetodo(card int,iban varchar,inte varchar)
RETURNS VOID AS $$
BEGIN
	INSERT INTO rid(codIban, Intestatario) VALUES (iban, inte);
	INSERT INTO MetodoDiPagamento(numSmartCard,codIban,intestatarioConto)
			VALUES (card,iban, inte);
END;
$$ LANGUAGE plpgsql;


/* overload prepagato shortcut per inserimento metodo prepagato */
CREATE OR REPLACE FUNCTION insertMetodo(card int,versato numeric)
RETURNS VOID AS $$
BEGIN
	INSERT INTO MetodoDiPagamento(numSmartCard,versato)
			VALUES (card,versato);
END;
$$ LANGUAGE plpgsql;

--InsertAbbonamento
CREATE OR REPLACE FUNCTION insertAbbonamento(dataInizio timestamp,databonus date,bonus numeric, pin numeric, card numeric, tipo1 varchar)
RETURNS VOID AS $$
DECLARE
	days int;
	etaU int;
	
BEGIN
	SELECT ngiorni INTO days FROM tipo WHERE periodo = tipo1;
	SELECT eta INTO etaU FROM utente NATURAL JOIN persona WHERE numSmartCard = card; 
	INSERT INTO Abbonamento(datainizio,datafine,dataBonus,bonusRottamazione,pincarta,numsmartcard,tipo) 
	VALUES (datainizio,datainizio + days * INTERVAL '1 day',databonus,bonus,pin,card,tipo1);
END;
$$ LANGUAGE plpgsql

