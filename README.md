Note: This repo is largely a snapshop record of bring Wikidata
information in line with Wikipedia, rather than code specifically
deisgned to be reused.

The code and queries etc here are unlikely to be updated as my process
evolves. Later repos will likely have progressively different approaches
and more elaborate tooling, as my habit is to try to improve at least
one part of the process each time around.

---------

Step 1: Check the Position Item
===============================

The Wikidata item: https://www.wikidata.org/wiki/Q373548
contains all the data expected already, although Jeanine Áñez was not
yet at preferred rank.

Step 2: Tracking page
=====================

PositionHolderHistory already exists; current version is
https://www.wikidata.org/w/index.php?title=Talk:Q373548&oldid=1187914165
with 57 dated memberships and 31 undated; and 74 warnings.

Step 3: Set up the metadata
===========================

The first step in the repo is always to edit [add_P39.js script](add_P39.js)
to configure the Item ID and source URL.

Step 4: Get local copy of Wikidata information
==============================================

    wd ee --dry add_P39.js | jq -r '.claims.P39.value' |
      xargs wd sparql office-holders.js | tee wikidata.json

Step 5: Scrape
==============

Comparison/source = https://fr.wikipedia.org/wiki/Liste_des_présidents_de_la_Bolivie

    wb ee --dry add_P39.js  | jq -r '.claims.P39.references.P4656' |
      xargs bundle exec ruby scraper.rb | tee wikipedia.csv

Small tweaks needed, but trivial to scrape.

I had to manually combine the three terms of Evo Morales, though, as
Wikidata already had those as a single statement.

Step 6: Create missing P39s
===========================

    bundle exec ruby new-P39s.rb wikipedia.csv wikidata.json |
      wd ee --batch --summary "Add missing P39s, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

5 new additions as officeholders -> https://tools.wmflabs.org/editgroups/b/wikibase-cli/346f2f8b89aba/

Step 7: Add missing qualifiers
==============================

    bundle exec ruby new-qualifiers.rb wikipedia.csv wikidata.json |
      wd aq --batch --summary "Add missing qualifiers, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

146 additions made as https://tools.wmflabs.org/editgroups/b/wikibase-cli/72fd807371deb/

Step 8: Select qualifier updates
================================

I accepted the following suggestions:

    Q286657$E0573A2B-C136-439B-83F0-A99207F1083A P1366 Q467959 Q373873
    Q734711$3674A6A1-5419-4C3A-ABE8-1FD2636937D1 P580 1841-01-01 1841-09-27
    Q734711$3674A6A1-5419-4C3A-ABE8-1FD2636937D1 P582 1847-01-01 1847-12-23
    Q888590$3F9EDF17-FF27-4ADD-B465-523E2F6FAFC9 P1366 Q11091800 Q886251
    Q886958$AB0E6E47-CFAC-4636-AD7F-33FEA8ABDA66 P582 1873-05-07 1873-05-09
    Q364994$0839237A-5E8E-40E1-A0E0-6E035A1A4BD6 P580 1873-01-01 1873-05-09
    Q364994$0839237A-5E8E-40E1-A0E0-6E035A1A4BD6 P582 1874-01-01 1874-01-31
    Q3309380$5035FD03-D23C-4452-A3A2-05407AC91114 P580 1880-01-01 1880-01-19
    Q3309380$5035FD03-D23C-4452-A3A2-05407AC91114 P582 1884-01-01 1884-09-04
    q770323$78d9155e-499d-0bdb-c54a-c60fe769277e P580 1892-01-01 1892-08-11
    q770323$78d9155e-499d-0bdb-c54a-c60fe769277e P582 1896-01-01 1896-08-19
    Q734690$9EBB9A9E-672F-49C8-919E-7B31BCD88276 P580 1899-10-01 1899-10-25
    Q734690$9EBB9A9E-672F-49C8-919E-7B31BCD88276 P582 1904-08-01 1904-08-14
    Q2511035$D99DC56B-618E-40C8-A823-DE4D4122FE22 P1366 Q734606 Q3292030
    Q3292030$AAD26248-F020-44DB-BD30-E7E00194CBDB P1545 42 41
    Q3292030$AAD26248-F020-44DB-BD30-E7E00194CBDB P1365 Q734606 Q2511035
    Q734606$1fce8106-496f-0f3a-5359-8ff03bad3399 P1545 43 42
    Q886523$D05F5299-5A2C-4170-AA0F-FC19861E97AE P1545 48 44
    Q886495$89BA4E2B-100F-49AF-AE2F-860522D7403D P1545 46 45
    Q471313$51591d58-45e6-2f52-d383-202cac028231 P1545 54 52
    Q312055$733d7e33-4c9c-1792-e679-d50e78ce5eda P1545 54 53
    Q332074$B7C11479-4069-4388-8E64-BB69C07B8345 P1545 56 55
    Q1780127$98724ADC-3D0E-4386-96FB-8DC44E3DEA90 P1366 Q332074 Q1780127
    Q195762$18FF2A07-37CA-4BAD-B207-3FAF2C3BC48F P1545 61 60

with

    pbpaste | fgrep -v MISMATCH | wd uq --batch --summary "Update qualifiers from https://fr.wikipedia.org/wiki/Liste_des_pr%C3%A9sidents_de_la_Bolivie"

as https://tools.wmflabs.org/editgroups/b/wikibase-cli/ac74d93931415/

Step 8: Refresh the Tracking Page
=================================

New version at https://www.wikidata.org/w/index.php?title=Talk:Q3477306&oldid=1237592658

Step 9: Final tidying
=====================

There were quite a few people still listed with date-less periods. Some
of these were actually vice-president, but others were part of various
military triumverates etc. This makes the history quite gnarly.

There's still some tidying to do, but I'll leave that for someone else.

Final version: https://www.wikidata.org/w/index.php?title=Talk:Q373548&oldid=1238263133
