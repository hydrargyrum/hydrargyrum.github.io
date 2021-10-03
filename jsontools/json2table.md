---
layout: mine
---

# json2table

json2table pretty-prints JSON data (list of objects) in an ASCII-art table.

# Example #

	% head -20 file.json
	[
	  {
	    "number": 31705,
	    "name": "31705 - CHAMPEAUX (BAGNOLET)",
	    "address": "RUE DES CHAMPEAUX (PRES DE LA GARE ROUTIERE) - 93170 BAGNOLET",
	    "latitude": 48.8645278209514,
	    "longitude": 2.416170724425901
	  },
	  {
	    "number": 10042,
	    "name": "10042 - POISSONNIÈRE - ENGHIEN",
	    "address": "52 RUE D'ENGHIEN / ANGLE RUE DU FAUBOURG POISSONIERE - 75010 PARIS",
	    "latitude": 48.87242006305313,
	    "longitude": 2.348395236282807
	  },
	  {
	    "number": 8020,
	    "name": "08020 - METRO ROME",
	    "address": "74 BOULEVARD DES BATIGNOLLES - 75008 PARIS",
	    "latitude": 48.882148945631904,
	% json2table < file.json
	+---------------------------------------------------+-------------------+---------------------------------------------------------------------------------------------------+--------+--------------------+
	|                        name                       |     longitude     |                                              address                                              | number |      latitude      |
	+---------------------------------------------------+-------------------+---------------------------------------------------------------------------------------------------+--------+--------------------+
	|            31705 - CHAMPEAUX (BAGNOLET)           | 2.416170724425901 |                   RUE DES CHAMPEAUX (PRES DE LA GARE ROUTIERE) - 93170 BAGNOLET                   | 31705  |  48.8645278209514  |
	|           10042 - POISSONNIÈRE - ENGHIEN          | 2.348395236282807 |                 52 RUE D'ENGHIEN / ANGLE RUE DU FAUBOURG POISSONIERE - 75010 PARIS                | 10042  | 48.87242006305313  |
	|                 08020 - METRO ROME                | 2.319860054774211 |                             74 BOULEVARD DES BATIGNOLLES - 75008 PARIS                            |  8020  | 48.882148945631904 |
	|               01022 - RUE DE LA PAIX              | 2.330493511399174 |                                   37 RUE CASANOVA - 75001 PARIS                                   |  1022  |  48.8682170167744  |
	|             35014 - DE GAULLE (PANTIN)            | 2.412715733388685 |                   139 AVENUE JEAN LOLIVE / MAIL CHARLES DE GAULLE - 93500 PANTIN                  | 35014  | 48.893268664697416 |
	|             20040 - PARC DE BELLEVILLE            | 2.384222472712587 |                              57 & 36 RUE JULIEN LACROIX - 75020 PARIS                             | 20040  | 48.870393671603765 |
	|           28002 - SOLJENITSYNE (PUTEAUX)          |     2.24772065    |                          BOULEVARD ALEXANDRE SOLJENITSYNE - 92800 PUTEAUX                         | 28002  |     48.884478      |
	...


The columns are displayed in the same order as in the file. It's possible to reorder the columns by giving their names on the command line:

	% json2table -f file.json number name address
	+--------+---------------------------------------------------+---------------------------------------------------------------------------------------------------+-------------------+--------------------+
	| number |                        name                       |                                              address                                              |     longitude     |      latitude      |
	+--------+---------------------------------------------------+---------------------------------------------------------------------------------------------------+-------------------+--------------------+
	| 31705  |            31705 - CHAMPEAUX (BAGNOLET)           |                   RUE DES CHAMPEAUX (PRES DE LA GARE ROUTIERE) - 93170 BAGNOLET                   | 2.416170724425901 |  48.8645278209514  |
	| 10042  |           10042 - POISSONNIÈRE - ENGHIEN          |                 52 RUE D'ENGHIEN / ANGLE RUE DU FAUBOURG POISSONIERE - 75010 PARIS                | 2.348395236282807 | 48.87242006305313  |
	|  8020  |                 08020 - METRO ROME                |                             74 BOULEVARD DES BATIGNOLLES - 75008 PARIS                            | 2.319860054774211 | 48.882148945631904 |
	|  1022  |               01022 - RUE DE LA PAIX              |                                   37 RUE CASANOVA - 75001 PARIS                                   | 2.330493511399174 |  48.8682170167744  |
	| 35014  |             35014 - DE GAULLE (PANTIN)            |                   139 AVENUE JEAN LOLIVE / MAIL CHARLES DE GAULLE - 93500 PANTIN                  | 2.412715733388685 | 48.893268664697416 |
	| 20040  |             20040 - PARC DE BELLEVILLE            |                              57 & 36 RUE JULIEN LACROIX - 75020 PARIS                             | 2.384222472712587 | 48.870393671603765 |
	| 28002  |           28002 - SOLJENITSYNE (PUTEAUX)          |                          BOULEVARD ALEXANDRE SOLJENITSYNE - 92800 PUTEAUX                         |     2.24772065    |     48.884478      |
	...

# Download #

[Project repository](https://gitlab.com/hydrargyrum/attic/tree/master/json2table)

json2table uses Python 3 and PrettyTable and is licensed under the [WTFPLv2](../wtfpl).
