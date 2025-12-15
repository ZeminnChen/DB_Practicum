% likes(Drunkard, Alcohol) ---> ľúbi
% serves(Pub, Alcohol, Cost) --> čapuje
% visited(VisitId, Drunkard, Pub, From) --> navštívil
% drank(VisitId, Alcohol, Quantity) --> vypil

% Execution order: [pijani], [translate], [task1]


% 1-- answer_a(D, P). D is loyal to P
% D has drunk at least once in P
drank_in_pub(D, P) :- visited(V, D, P, _), drank(V, _, _).

% From2 > From1 where D drank A in another P?
elsewhere(D, P) :- visited(V1, D, P, From1), drank(V1, A, _), 
                   visited(V2, D, P2, From2), drank(V2, A, _), 
                   P \= P2, From2 > From1.

answer_a(D, P) :- distinct((D, P), (drank_in_pub(D, P), \+ elsewhere(D, P))).



% 2-- answer_b(D, A). D is strongly addicted to A 
decrease(D, A) :- visited(V1, D, _, From1), visited(V2, D, _, From2), From1 < From2,
                  drank(V1, A, Q1), drank(V2, A, Q2), Q2 < Q1.
answer_b(D, A) :- drank(V, A, _), visited(V, D, _, _), \+ decrease(D, A).




% 3-- answer_c(D, A). D is the sole record holder in alcohol A at one sitting in P
% There is no one who drank A more than D
record_holder(D, A, P) :- visited(V, D, P, _), drank(V, A, Q),
                        \+ (visited(V2, D2, P, _), drank(V2, A, Q2),
                              D2 \= D, Q2 >= Q).

% All pubs serving alcohol A
pub_serving(A, P) :- serves(P, A, _).

% D likes A. It does not exist any P, where D is not the record holder
answer_c(D, A) :- likes(D, A), \+ (pub_serving(A, P), \+ record_holder(D, A, P)).



% 4-- answer_d(D). Miser
% D drinks only the cheapest alcohols in P during visit V
cheapest(_, V, P, A) :- drank(V, A, _), serves(P, A, C1), \+ (serves(P, _, C2), C2 < C1).

% D never drank A at a cheaper price elsewhere before
no_cheaper(D, V, A, P) :- serves(P, A, Cost), \+ (visited(V2, D, P2, _), drank(V2, A, _), serves(P2, A, Cost2),
                                                    P2 \= P, V2 < V, Cost2 < Cost
                                                ).

% Miser conditions
miser_visit(D, V, P) :- visited(V, D, P, _),
                        \+ (drank(V, A, _), \+ likes(D, A)),            % drinks only liked alcohols
                        \+ (drank(V, A, _), \+ cheapest(D, V, P, A)),      % drinks only cheapest
                        \+ (drank(V, A, _), \+ no_cheaper(D, V, A, P)). % never cheaper before

answer_d(D) :- visited(_, D, _, _), \+ (visited(V, D, P, _), \+ miser_visit(D, V, P)).



