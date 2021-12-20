:- use_module(library(readutil)).
/* “I have neither given nor received unauthorized assistance on this assignment.*/
/*
Grammer parser and diagrammer

<sentence>    -->  <subject> <verb_phrase> <object>
<subject>     -->  <noun_phrase>
<verb_phrase> -->  <verb> | <verb> <adv>
<object>      -->  <noun_phrase>
<verb>        -->  definied in the Verbs list loaded via the definitions.pl
<adv>         -->  defined in the Adverbs list loaded via the definitions.pl
<noun_phrase> -->  [<adj_phrase>] <noun> [<prep_phrase>]
<noun>        -->  defined in the Nouns list loaded via the definitions.pl
<adj_phrase>  -->  <adj> | <adj> <adj_phrase>
<adj>         -->  defined in the Adjectives list loaded via the definitions.pl
<prep_phrase> -->  <prep> <noun_phrase>
<prep>        -->  defined in the Prepostions list loaded via the definitions.pl

*/
/* ==========================================================================================================================
Words we know are loaded using the consult.  definition.pl is the file that is loaded in the consult.
*========================================================================================================================== */

make_go_now() :- consult(definitions), read_sentence(S).

/* ==========================================================================================================================
Reading Sentences from file
*========================================================================================================================== */
read_sentence(Sentence) :- 
    read_file_to_string("input.txt", Sentence1, []),
    split_string(Sentence1," \n","\n",Sentence2),      
    convert_strings_to_atoms(Sentence2,[],Sentence),   
    parser(Sentence).

/* ==========================================================================================================================
Converting strings we read into atoms
*========================================================================================================================== */
convert_strings_to_atoms([],Sentence,Sentence).
convert_strings_to_atoms([Head|Tail],Builder,Sentence) :- 
    string_to_atom(Head,Atom), 
    append(Builder,[Atom],New_Builder),
    convert_strings_to_atoms(Tail,New_Builder,Sentence).

/* ==========================================================================================================================
Parsing Sentence to make diagram
*========================================================================================================================== */

parser(Sentence) :- 
    verbs(Verbs), 
    nouns(Nouns), 
    prepositions(Prepositions),
    adjectives(Adjectives),
    adverbs(Adverbs), 
    tell("output.txt",Stream),
    parse_sentence(Stream,Sentence,Diagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject),
    close(Stream),!.


parse_sentence(Stream,['.'|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, _) :- 
    
    append(Builder,[']', ')'], Y),
    print_list(Y, Stream),
    parse_sentence(Stream,T,New_Diagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, _) :-
    
    append(Builder,[']', ')'], Y),
    print_list(Y, Stream).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject) :-
    append(Builder,['(', '['], Y),
    parse_sentence(Stream,[H|T], Diagram,Y,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase) :-
    member(H, Adjectives),
    append(Builder, ['<'], X),
    append( X, [H], Y),
    append(Y, ['>'], New_Builder),
    parse_sentence(Stream,T,Diagram,New_Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase) :-
    member(H, Nouns),
    append(Builder, ['{'], X),
    append( X, [H], Y),
    append( Y, ['}'], New_Builder),
    parse_sentence(Stream,T,Diagram,New_Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, prep_or_verb).
   
parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase) :-
    member(H, Verbs),
    print_list(["input is not a sentence"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase) :-
    member(H, Prepositions),
    print_list(["input is not a sentence"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase) :-
    member(H, Adverbs),
    print_list(["input is not a sentence"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase) :-
    print_list(["input  has  invalid  tokens"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, prep_or_verb) :-
    member(H, Prepositions),
    append(Builder, ['*'], X),
    append(X, [H], Y),
    append(Y, ['*'], New_Builder),
    parse_sentence(Stream,T,Diagram,New_Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, prep_or_verb) :-
    member(H, Verbs),
    append(Builder, [']', ')', '[', '%'], X),
    append(X, [H], Y),
    append(Y, ['%'], New_Builder),
    parse_sentence(Stream,T,Diagram,New_Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, after_verb).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, prep_or_verb) :-
    member(H, Adverbs),
    print_list(["input is not a sentence"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, prep_or_verb) :-
    member(H, Nouns),
    print_list(["input is not a sentence"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, prep_or_verb) :-
    member(H, Adjectives),
    print_list(["input is not a sentence"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, prep_or_verb) :-
    print_list(["input  has  invalid  tokens"],Stream),
    skip_sentence([H|T], NewSentence),
    parse_sentence(Stream,NewSentence,aDiagram,[],Nouns,Verbs,Prepositions,Adjectives,Adverbs, subject).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, after_verb) :-
    member(H, Adverbs),
    append(Builder, ['$'], X),
    append( X, [H], Y),
    append(Y, ['$', ']', '(', '['], New_Builder),
    parse_sentence(Stream,T,Diagram,New_Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, after_verb) :-
    append(Builder, [ ']', '(', '[' ], Y),
    parse_sentence(Stream,[H|T],Diagram,Y,Nouns,Verbs,Prepositions,Adjectives,Adverbs, object).

parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, object) :-
    parse_sentence(Stream,[H|T],Diagram,Builder,Nouns,Verbs,Prepositions,Adjectives,Adverbs, noun_phrase).

skip_sentence([], []).
skip_sentence(['.'|Y], Y).
skip_sentence([X|Y] , NewSentence) :- 
    skip_sentence(Y, NewSentence), !.

tell(File,Stream) :- open(File,write, Stream).

print_list([]).
print_list([Head|Tail]) :- write(" "),write(Head), write(" "), print_list(Tail).

print_list([],Stream):- nl(Stream).
print_list([Head|Tail],Stream) :- write(Stream," "),write(Stream,Head), write(Stream," "), print_list(Tail,Stream).
