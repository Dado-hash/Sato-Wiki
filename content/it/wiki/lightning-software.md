---
id: wiki.lightning-software
slug: lightning-software
language: it
category: software
subcategory: lightning
title: Software Lightning
description: Implementazioni di nodo Lightning e wallet, come interoperano grazie alle specifiche BOLT e che cosa possono proteggere backup dei canali e watchtower.
difficulty: base
readTimeMinutes: 5
tags:
  - Lightning
  - Software
  - Backup dei canali
  - Custodia
related:
  - wiki.lightning-network
  - wiki.payment-channels
  - wiki.bolt-specifications
  - wiki.watchtowers
  - wiki.lightning-service-providers
sources:
  - title: Lightning Network Specifications (BOLTs)
    url: https://github.com/lightning/bolts
    author: Lightning Network developers
  - title: Static channel backups
    url: https://bitcoinops.org/en/topics/static-channel-backups/
    author: Bitcoin Optech
  - title: Watchtowers
    url: https://bitcoinops.org/en/topics/watchtowers/
    author: Bitcoin Optech
  - title: Backup your wallet - Core Lightning
    url: https://docs.corelightning.org/docs/backup
    author: Core Lightning contributors
  - title: LDK, a Lightning implementation packaged as an SDK
    url: https://lightningdevkit.org/
    author: LDK contributors
  - title: Eclair, a Scala implementation of the Lightning Network
    url: https://github.com/ACINQ/eclair
    author: ACINQ
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

Il software Lightning è l'insieme dei programmi che aprono canali di pagamento e inviano pagamenti attraverso di essi. Ci sono due grandi famiglie. Un'implementazione di nodo Lightning gestisce la logica dei canali, l'instradamento e le operazioni on-chain. Un wallet Lightning è l'app con cui una persona invia e riceve, e può far girare un proprio nodo oppure appoggiarsi a quello di qualcun altro. Esempi di implementazioni di nodo sono LND, Core Lightning, Eclair e LDK, che è pensato come libreria per gli sviluppatori.

Questi programmi possono parlarsi perché seguono le specifiche BOLT, un insieme condiviso di regole per messaggi e comportamento dei canali. L'interoperabilità è il motivo per cui puoi aprire un canale con un nodo realizzato da un team diverso.

I wallet differiscono per chi controlla i fondi. In un wallet self-custodial hai tu le chiavi dei tuoi canali. In un wallet custodial i fondi sono di una società, che registra il tuo saldo. Alcuni wallet stanno a metà strada e usano un fornitore di servizi che aiuta ad aprire e gestire i canali. Ogni modello cambia ciò di cui devi fidarti e che cosa succede se il fornitore va offline.

I canali Lightning richiedono attenzione quando sei lontano. Un canale può essere usato per barare se l'altra parte pubblica uno stato vecchio, quindi il software deve essere online per rispondere, oppure serve un altro servizio che lo controlli.

## medium

Un canale è recuperabile solo quanto i dati che conservi su di esso. I static channel backup (SCB) sono file che devono essere aggiornati solo quando un canale viene aperto o chiuso. Se il tuo nodo perde il proprio stato, un SCB gli permette di chiedere al peer di chiudere il canale usando l'ultimo stato che il peer possiede. Così si possono recuperare fondi, ma Bitcoin Optech elenca due rischi. Il peer può sospettare che il tuo nodo sia obsoleto e tentare di chiudere con uno stato vecchio, e un nodo che ha perso i dati può non essere in grado di dimostrarlo. E se entrambe le parti perdono lo stato, o il peer scompare, un SCB non può recuperare il canale.

Il recupero dal seed copre meno di quanto spesso si pensi. La documentazione di Core Lightning separa le sue voci di backup. Il segreto HSM, memorizzato nel file hsm_secret, è sufficiente per recuperare i fondi on-chain del wallet, ed è necessario ma non sufficiente per i fondi bloccati nei canali. Servono anche lo stato dei canali e i file del database.

Una watchtower è un servizio che controlla la blockchain alla ricerca di uno stato vecchio di canale trasmesso. Quando ne vede uno, può pubblicare per tuo conto una transazione di penalità. Le watchtower non detengono i tuoi fondi. Il loro compito è controllare e trasmettere, quindi non possono spendere il saldo del tuo canale. Questo schema ti permette di restare offline per lunghi periodi senza lasciare il canale esposto, ma una watchtower resta una terza parte che vede parte della tua attività sui canali, e serve solo se la penalità è possibile.

Anche le scelte implementative incidono sull'utente. Un nodo che gestisci tu ti dà controllo su commissioni, canali e impostazioni di privacy. Leggi la documentazione per sapere quali backup crea il software, con quale frequenza li aggiorna e come ripristinare dopo un guasto.

## advanced

L'interoperabilità dipende dalle BOLT e dalle funzioni che due peer concordano. Due implementazioni possono supportare entrambe una stessa funzione pur differendo per default, tempistiche o comportamento nel recupero, quindi un pagamento che funziona tra una coppia di nodi può comportarsi in modo diverso con un'altra.

I backup dei canali hanno un compromesso chiaro. Un SCB conserva abbastanza informazioni sul canale da chiedere al peer di chiuderlo, quindi funziona senza la storia completa dello stato, ma è aggiornato solo fino al tuo ultimo salvataggio. Il meccanismo option_data_loss_protect dà al peer un motivo per chiudere in modo onesto quando sente un nodo obsoleto. Questa protezione dipende dal peer, e fallisce se anche il peer ha perso il proprio stato. Un backup completo dello stato del canale è più solido, ma deve restare sincronizzato con il nodo in funzione, un compito operativo più difficile.

Le watchtower proteggono da un attacco specifico: la controparte che trasmette uno stato revocato mentre tu sei offline. Una torre conserva transazioni di breach remedy che le permettono di reclamare i fondi in quel caso. Optech osserva che le transazioni di breach remedy possono essere progettate in modo che la torre riceva una parte dei fondi protetti, il che le dà un incentivo ad agire. Una torre offline, censurata o irraggiungibile non offre protezione, e una torre che vede gli aggiornamenti del tuo canale apprende qualcosa sui tuoi pagamenti. Alcune implementazioni permettono agli utenti di eliminare le sessioni, altre tengono prove di responsabilità, il che riflette che il servizio è una relazione di fiducia e non una garanzia gratuita.

I modelli custodial e self-custodial hanno modalità di guasto diverse. Un wallet custodial può congelare, perdere o riportare in modo errato i fondi, e l'utente dipende dalla sua solvibilità e dai suoi registri. Un wallet self-custodial tiene le chiavi nelle mani dell'utente, il che elimina quel rischio di controparte ma aggiunge il rischio operativo di backup, disponibilità e gestione della liquidità. Un wallet con fornitore di servizi sta nel mezzo: il fornitore gestisce canali e liquidità per l'utente, quindi l'utente deve fidarsi della contabilità e della disponibilità del fornitore pur tenendo le chiavi.

La scelta del software fa quindi parte del disegno di sicurezza. Leggi come l'implementazione gestisce lo stato dei canali, con quale frequenza salva i backup, se può far girare una watchtower e che cosa richiede per restare online. Non dare per scontato che il comportamento di un'implementazione in uno scenario valga anche in un altro.
