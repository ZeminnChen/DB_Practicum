% Ľúbi/2 → likes/2
likes(Drunkard, Alcohol) :- lubi(Drunkard, Alcohol).

% Navštívil/4 → visited/4
visited(VisitId, Drunkard, Pub, From) :- navstivil(VisitId, Drunkard, Pub, From).

% Vypil/3 → drank/3
drank(VisitId, Alcohol, Quantity) :- vypil(VisitId, Alcohol, Quantity).

% Čapuje/3 → serves/3
serves(Pub, Alcohol, Cost) :- capuje(Pub, Alcohol, Cost).
