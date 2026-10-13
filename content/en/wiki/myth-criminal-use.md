---
id: wiki.myth-criminal-use
slug: myth-criminal-use
language: en
category: myths
title: '"Bitcoin is mostly used by criminals"'
description: Illicit use of bitcoin is real and documented, but published estimates differ widely by method and year, and none of those cited here shows that criminal use is the majority.
coverImage: media/wiki/myth-criminal-use/myth-criminal-use-hero.svg
difficulty: base
readTimeMinutes: 6
tags:
  - Myths
  - Crime
  - Chain Analysis
  - Estimates
related:
  - wiki.myth-anonymous
  - wiki.common-input-ownership
  - wiki.coinjoin
  - wiki.threat-model
  - wiki.address-reuse
sources:
  - title: Chainalysis 2026 crypto crime report - introduction
    url: https://www.chainalysis.com/blog/2026-crypto-crime-report-introduction/
    author: Chainalysis
  - title: "Sex, Drugs, and Bitcoin: How Much Illegal Activity Is Financed through Cryptocurrencies?"
    url: https://www.pure.ed.ac.uk/ws/files/82111413/Sex_drugs_and_bitcoin_20181214.pdf
    author: Sean Foley, Jonathan R. Karlsen, Talis J. Putnins
  - title: "A Fistful of Bitcoins: Characterizing Payments Among Men with No Names"
    url: https://cseweb.ucsd.edu/~smeiklejohn/files/imc13.pdf
    author: Sarah Meiklejohn, Marjori Pomarole, Grant Jordan, Kirill Levchenko, Damon McCoy, Geoffrey M. Voelker, Stefan Savage
    publishedAt: 2013-10-23
  - title: Silk Road - Bitcoin Wiki
    url: https://en.bitcoin.it/wiki/Silk_Road
    author: Bitcoin Wiki contributors
reviewedAt: 2026-10-13
updatedAt: 2026-10-13T00:00:00Z
---

## base

False as a general statement, although illicit use is real. Criminals have used bitcoin, and published estimates of how much activity is illicit differ widely by method and year. None of the estimates cited here shows that criminal use is the majority of bitcoin activity.

Think of a payment system used by millions of people, where a small number of users commit crimes. The useful question is how much of all the activity is illegal, not whether crimes happen. A public ledger changes what can be measured, because every payment is recorded. The same record also lets investigators follow coins, which is why bitcoin has been traced in many cases.

The best-known illicit market, Silk Road, accepted bitcoin for its listings from its launch in February 2011 until the FBI shut it down in October 2013. Ransomware operators have also used cryptocurrency to collect payments. These cases are documented.

The size of illicit use depends on what is counted. A 2019 academic study, using data that ends in 2017, estimated that close to half of bitcoin transactions by number were linked to illegal activity. The blockchain-analysis company Chainalysis reports that illicit addresses received less than 1 percent of attributed volume in 2025, across all cryptocurrencies and not bitcoin alone. Each estimate has limits, which the medium and advanced sections explain.

## medium

One common method is to take coins linked to known illicit addresses and divide their value by total activity. The result depends on which addresses are known. Chainalysis's 2026 report estimates that illicit addresses received at least $154 billion in 2025, and that the illicit share of attributed transaction volume rose slightly from 2024 but stayed below 1 percent. The report calls the figure a lower bound, because it counts only addresses the firm has identified, and it excludes crime that does not use cryptocurrency natively. The firm also revised its 2024 total from $40.9 billion to $57.2 billion. These figures cover all cryptocurrencies: the report says stablecoins account for 84 percent of illicit transaction volume, so they are not a measure of bitcoin alone.

The increase in 2025 came mainly from value received by sanctioned entities, which the report says rose by 694 percent. The report mentions ransomware operators but gives no figure for them.

A different method gives a different picture. Foley, Karlsen and Putnins, in The Review of Financial Studies (2019), used bitcoin seizures and cluster analysis to build a sample of known illegal users, with data ending in April 2017. They estimated that about 46 percent of bitcoin transactions, and about a quarter of users, were associated with illegal activity, around $76 billion a year. The share of dollar volume was lower, about 23 percent. Their classification relies on algorithms that group addresses, so the result describes association, not verified crimes. The authors also find that the illegal share declines as mainstream interest in bitcoin grows.

The public ledger does help investigators. In 2013, Meiklejohn and colleagues grouped addresses that were spent together and made purchases from several services to identify the operators of some of them. The Silk Road case ended with an arrest in 2013, after investigators identified the site's operator. The same traceability is what makes illicit activity measurable at all, which is why estimates exist and can be checked against each other.

## advanced

The strongest version of the claim is that bitcoin attracts crime for reasons built into its design. Payments are irreversible and cross borders without a bank's approval, which suits fraud and money laundering. On this reading, the value that analysts cannot see, such as flows through unregistered services or cash-based conversions, is probably larger than the published estimates suggest. The visible share could then be small while the real share is a majority. Meiklejohn and colleagues wrote about the concern that scalable, irrevocable and anonymous payments would appeal to criminals.

The reply above has serious objections. First, the Chainalysis figures are a lower bound built from identified addresses. The report says totals will rise as more addresses are found, so the small share reflects what has been labelled, not everything that happens. Second, the firm sells investigation services, and the report itself says that investigators with off-chain information can use its solutions. That does not make the numbers wrong, but a reader should weigh them with that in mind. Third, the academic estimate points the other way, with close to half of transactions by number. Its method has weaknesses of its own: it relies on seized coins to build a sample, and clustering can err in either direction.

Fourth, the denominators differ. A share of transactions by number, a share of dollar value and a share of users give different pictures, so "mostly" needs a definition. The Foley share of dollar value was about 23 percent in 2017, which is not a majority, and the Chainalysis share is under 1 percent for 2025. Neither figure supports the claim as a majority.

The defender's reply is that most activity is legal and that illicit use has existed in every payment system. That is fair as a point about proportion, but it does not answer whether the claim holds for a particular measure. The claim would become true if an independent method, with a documented sample and disclosed error rates, showed that illicit flows make up most of the transactions or the value over a sustained period. It would become clearly false if several independent methods, each with its limits stated, kept finding a small share of value. Between those two outcomes, the answer depends on the year, the method and the measure.
