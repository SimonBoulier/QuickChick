Set Warnings "-extraction-opaque-accessed,-extraction".
Set Warnings "-notation-overridden,-parsing".

Require Import ZArith.
Require Import mathcomp.ssreflect.ssreflect.
From mathcomp Require Import ssrfun ssrbool ssrnat eqtype seq.

From QuickChick Require Import
     GenLowInterface RandomQC Sets.

Set Bullet Behavior "Strict Subproofs".

(* High-level Generators *)

Module Type Sig (GenLow : GenLowInterface.Sig).
Import GenLow.

Parameter liftGen : forall {A B : Type}, (A -> B) -> G A -> G B.
Parameter liftGen2 : forall {A1 A2 B : Type},
                       (A1 -> A2 -> B) -> G A1 -> G A2 -> G B.
Parameter liftGen3 : forall {A1 A2 A3 B : Type},
                       (A1 -> A2 -> A3 -> B) -> G A1 -> G A2 -> G A3 -> G B.
Parameter liftGen4 : forall {A1 A2 A3 A4 B : Type},
                       (A1 -> A2 -> A3 -> A4 -> B) ->
                       G A1 -> G A2 -> G A3 -> G A4 -> G B.
Parameter liftGen5 : forall {A1 A2 A3 A4 A5 B : Type},
                       (A1 -> A2 -> A3 -> A4 -> A5 -> B) ->
                       G A1 -> G A2 -> G A3 -> G A4-> G A5 -> G B.
Parameter sequenceGen: forall {A : Type}, list (G A) -> G (list A).
Parameter foldGen :
  forall {A B : Type}, (A -> B -> G A) -> list B -> A -> G A.
Parameter oneOf_ : forall {A : Type}, list (G A) -> G A.
Parameter freq_ : forall {A : Type}, list (nat * G A) -> G A.

Parameter vectorOf : forall {A : Type}, nat -> G A -> G (list A).
Parameter listOf : forall {A : Type}, G A -> G (list A).
Parameter elems_ : forall {A : Type}, list A -> G A.

(* Parameter shuffle : forall {A : Type}, list (nat * G A) -> G A. *)
(* Parameter backtrack : forall {A : Type}, list (nat * G A) -> G A. *)

(* Correctness for derived generators *)

Parameter semLiftGen :
  forall {A B} (f: A -> B) (g: G A),
    semGen (liftGen f g) <--> f @: semGen g.

Parameter semLiftGenSize :
  forall {A B} (f: A -> B) (g: G A) size,
    semGenSize (liftGen f g) size <--> f @: semGenSize g size.

Declare Instance liftGenUnsized {A B} (f : A -> B) (g : G A) 
        `{Unsized _ g} : Unsized (liftGen f g).

Parameter semLiftGen2Size :
  forall {A1 A2 B} (f: A1 -> A2 -> B) (g1 : G A1) (g2 : G A2) s,
    semGenSize (liftGen2 f g1 g2) s <-->
    f @2: (semGenSize g1 s, semGenSize g2 s).

Parameter semLiftGen2Unsized1 :
  forall {A1 A2 B} (f: A1 -> A2 -> B) (g1 : G A1) (g2 : G A2),
    Unsized g1 ->
    semGen (liftGen2 f g1 g2) <--> f @2: (semGen g1, semGen g2).

Parameter semLiftGen2Unsized2 :
  forall {A1 A2 B} (f: A1 -> A2 -> B) (g1 : G A1) (g2 : G A2) `{Unsized _ g2},
    semGen (liftGen2 f g1 g2) <--> f @2: (semGen g1, semGen g2).

Parameter semLiftGen2SizeMonotonic :
  forall {A1 A2 B} (f: A1 -> A2 -> B)
         (g1 : G A1) (g2 : G A2) `{SizeMonotonic _ g1} `{SizeMonotonic _ g2},
  semGen (liftGen2 f g1 g2) <--> f @2: (semGen g1, semGen g2).

Declare Instance liftGen2Unsized {A1 A2 B} (f : A1 -> A2 -> B) (g1 : G A1)
        `{Unsized _ g1} (g2 : G A2) `{Unsized _ g2} : Unsized (liftGen2 f g1 g2).

Declare Instance liftGen2Monotonic {A1 A2 B} (f : A1 -> A2 -> B) (g1 : G A1)
        `{SizeMonotonic _ g1} (g2 : G A2) `{SizeMonotonic _ g2} : SizeMonotonic (liftGen2 f g1 g2).


Parameter semLiftGen3Size :
forall {A1 A2 A3 B} (f: A1 -> A2 -> A3 -> B)
       (g1: G A1) (g2: G A2) (g3: G A3) size,
  semGenSize (liftGen3 f g1 g2 g3) size <-->
  [set b : B | exists a1, semGenSize g1 size a1 /\
                          (exists a2, semGenSize g2 size a2 /\
                                      (exists a3, semGenSize g3 size a3 /\
                                                  (f a1 a2 a3) = b))].

Parameter semLiftGen4Size : forall A1 A2 A3 A4 B (f : A1 -> A2 -> A3 -> A4 -> B)
       (g1 : G A1) (g2 : G A2) (g3 : G A3) (g4 : G A4) s,
  semGenSize (liftGen4 f g1 g2 g3 g4) s <-->
  [set b : B | exists a1 a2 a3 a4, semGenSize g1 s a1 /\ semGenSize g2 s a2 /\
                 semGenSize g3 s a3 /\ semGenSize g4 s a4 /\ f a1 a2 a3 a4 = b].

Parameter semLiftGen4SizeMonotonic :
  forall A1 A2 A3 A4 B (f : A1 -> A2 -> A3 -> A4 -> B)
         (g1 : G A1) (g2 : G A2) (g3 : G A3) (g4 : G A4) 
  `{SizeMonotonic _ g1} `{SizeMonotonic _ g2}
  `{SizeMonotonic _ g3} `{SizeMonotonic _ g4},
  semGen (liftGen4 f g1 g2 g3 g4) <-->
  [set b : B | exists a1 a2 a3 a4, semGen g1 a1 /\ semGen g2 a2 /\
                 semGen g3 a3 /\ semGen g4 a4 /\ f a1 a2 a3 a4 = b].

Declare Instance liftGen4Monotonic {A B C D E} 
        (f : A -> B -> C -> D -> E)
        (g1 : G A) (g2 : G B) (g3 : G C) (g4 : G D) 
        `{ SizeMonotonic _ g1} `{ SizeMonotonic _ g2}
        `{ SizeMonotonic _ g3} `{ SizeMonotonic _ g4} 
: SizeMonotonic (liftGen4 f g1 g2 g3 g4). 


Parameter semLiftGen5Size :
forall {A1 A2 A3 A4 A5 B} (f: A1 -> A2 -> A3 -> A4 -> A5 -> B)
       (g1: G A1) (g2: G A2) (g3: G A3) (g4: G A4) (g5: G A5) size,
  semGenSize (liftGen5 f g1 g2 g3 g4 g5) size <-->
  [set b : B |
   exists a1, semGenSize g1 size a1 /\
              (exists a2, semGenSize g2 size a2 /\
                          (exists a3, semGenSize g3 size a3 /\
                                      (exists a4, semGenSize g4 size a4 /\
                                                  (exists a5, semGenSize g5 size a5 /\
                                                              (f a1 a2 a3 a4 a5) = b))))].

Parameter semSequenceGenSize:
  forall {A} (gs : list (G A)) n,
    semGenSize (sequenceGen gs) n <-->
    [set l | length l = length gs /\
      List.Forall2 (fun y => semGenSize y n) gs l].

Parameter semSequenceGenSizeMonotonic : 
  forall A (gs : list (G A)),
    (gs \subset SizeMonotonic) ->
    semGen (sequenceGen gs) <-->
           [set l | length l = length gs /\
                    List.Forall2 semGen gs l].


Parameter semFoldGen_right :
  forall {A B : Type} (f : A -> B -> G A) (bs : list B) (a0 : A) (s : nat),
    semGenSize (foldGen f bs a0) s <-->
    [ set an |
      foldr (fun b p => [set a_prev | exists a, a \in (semGenSize (f a_prev b) s :&: p)]) 
            [set an] bs a0 ].

Parameter semOneOfSize : forall {A} (l : list (G A)) s,
  semGenSize (oneOf_ l) s <--> \bigcup_(x in l) semGenSize x s.

Parameter semOneOf : forall {A} (l : list (G A)),
  semGen (oneOf_ l) <--> \bigcup_(x in l) semGen x.

Declare Instance oneOfMonotonic {A} (l : list (G A))
        `(l \subset SizeMonotonic) : SizeMonotonic (oneOf_ l). 

Parameter semFrequency:
  forall {A} (l : list (nat * G A)),
    semGen (freq_ l) <-->
    let l' := [seq x <- l | x.1 != 0] in
    \bigcup_(x in l') semGen x.2.

Parameter frequencySizeMonotonic : forall {A} (lg : list (nat * G A)),
  List.Forall (fun p => SizeMonotonic (snd p)) lg ->
  SizeMonotonic (freq_ lg).

Declare Instance frequencySizeMonotonic_alt 
  :
  forall {A : Type} (lg : seq (nat * G A)),
    lg \subset [set x | SizeMonotonic x.2 ] ->
    SizeMonotonic (freq_ lg).

Parameter semFrequencySize:
  forall {A} (l : list (nat * G A)) (size: nat),
  semGenSize (freq_ l) size <-->
             let l' := [seq x <- l | x.1 != 0] in
             \bigcup_(x in l') (semGenSize x.2 size).

(*
(** [backtrack] generates Some's unless all of the input generators are empty *)
Parameter semBacktrackSize:
  forall {A} (l : list (nat * G (option A))) size,
  semGenSize (backtrack l) size <--> 
  (\bigcup_(x in (l :&: (fun x => x.1 <> 0))) (isSome :&: (semGenSize x.2 size))) :|:
  ([set None] :&: (\bigcap_(x in l :&: (fun x => x.1 <> 0)) (semGenSize x.2 size))).

Parameter backtrackSizeMonotonic: 
  forall {A : Type} (lg : seq (nat * G (option A))),
    lg \subset [set x | SizeMonotonic x.2 ] ->
    SizeMonotonic (backtrack lg).

(*
Parameter backtrackSizeMonotonicOpt :
  forall {A : Type} (lg : seq (nat * G (option A))),
    lg \subset [set x | SizeMonotonicOpt x.2 ] ->
    SizeMonotonicOpt (backtrack lg).
*)

Parameter bigcup_cons_setI_subset_compat_backtrack :
  forall {A} (n : nat) (g g' : G (option A)) (l l' : seq (nat * G (option A))) s,
    isSome :&: semGenSize g s  \subset isSome :&: semGenSize g' s ->
    \bigcup_(x in (l :&: (fun x => x.1 <> 0))) (isSome :&: semGenSize x.2 s) \subset
    \bigcup_(x in (l' :&: (fun x => x.1 <> 0))) (isSome :&: semGenSize x.2 s) ->
    \bigcup_(x in (((n, g) :: l) :&: (fun x => x.1 <> 0))) (isSome :&: semGenSize x.2 s) \subset
    \bigcup_(x in (((n, g') :: l') :&: (fun x => x.1 <> 0))) (isSome :&: semGenSize x.2 s).

Parameter bigcup_cons_setI_subset_pres_backtrack :
  forall {A} (n : nat) (g : G (option A)) (l l' : seq (nat * G (option A))) s,
    \bigcup_(x in (l :&: (fun x => x.1 <> 0))) (isSome :&: semGenSize x.2 s) \subset
    \bigcup_(x in (l' :&: (fun x => x.1 <> 0))) (isSome :&: semGenSize x.2 s) ->
    \bigcup_(x in (l :&: (fun x => x.1 <> 0))) (isSome :&: semGenSize x.2 s) \subset
    \bigcup_(x in ((n, g) :: l') :&: (fun x => x.1 <> 0)) (isSome :&: semGenSize x.2 s).

Parameter semBacktrack_sound :
  forall (A : Type) (l : seq (nat * G (option A))),
    semGen (backtrack l) \subset
    (\bigcup_(x in (l :&: (fun x => x.1 <> 0))) (isSome :&: (semGen x.2))) :|:
    ([set None] :&: (\bigcap_(x in l :&: (fun x => x.1 <> 0)) (semGen x.2))).

Parameter semBacktrack_complete :
  forall (A : Type) (l : seq (nat * G (option A))),
    \bigcup_(x in (l :&: (fun x => x.1 <> 0))) (isSome :&: (semGen x.2)) \subset
    semGen (backtrack l).
*)

Parameter semVectorOfSize:
  forall {A : Type} (k : nat) (g : G A) size,
    semGenSize (vectorOf k g) size <-->
    [set l | length l = k /\ l \subset semGenSize g size].

Parameter semVectorOfUnsized : 
  forall {A} (g : G A) (k : nat) `{Unsized _ g}, 
    semGen (vectorOf k g) <--> [set l | length l = k /\ l \subset semGen g ]. 

Declare Instance vectorOfUnsized {A} (k : nat) (g : G A) 
        `{Unsized _ g } : Unsized (vectorOf k g).

Declare Instance vectorOfMonotonic {A} (k : nat) (g : G A) 
        `{SizeMonotonic _ g } : SizeMonotonic (vectorOf k g).

Parameter semListOfSize:
  forall (A : Type) (g : G A) (size : nat),
    semGenSize (listOf g) size <-->
    [set l | length l <= size /\ l \subset semGenSize g size].

Parameter semListOfUnsized: 
  forall {A} (g : G A) (k : nat) `{Unsized _ g}, 
    semGen (listOf g) <--> [set l | l \subset semGen g ]. 

Declare Instance listOfMonotonic {A} (g : G A) 
        `{SizeMonotonic _ g } : SizeMonotonic (listOf g).

Parameter semElems :
  forall {A} (l: list A),
    (semGen (elems_ l)) <--> l.

Parameter semElemsSize:
  forall {A} (l: list A) s,
    (semGenSize (elems_ l) s) <--> l.

Declare Instance elemsUnsized {A} (l : list A)  : Unsized (elems_ l).

Definition genPair {A B : Type} (ga : G A) (gb : G B) : G (A * B) :=
  liftGen2 pair ga gb.

Definition uncurry {A B C : Type} (f : A -> B -> C) (ab : A * B) :=
  match ab with
  | (a,b) => f a b
  end.

Definition curry {A B C : Type} (f : A * B -> C) (a : A) (b : B) := f (a,b).

Parameter mergeBinds :
  forall A B C (ga : G A) (gb : G B) (f : A -> B -> G C),
    semGen (bindGen ga (fun x => bindGen gb (f x))) <-->
    semGen (bindGen (genPair ga gb) (uncurry f)).

(* LEO: Leaving the notation in for future-proofing: unit-thunking *)
Module QcDefaultNotation.

(* Noone would write a literal singleton. *)
Notation " 'elems' [ x ] " := (elems_ (cons x nil)) : qc_scope.
Notation " 'elems' [ x ; y ] " := (elems_ (cons x (cons y nil))) : qc_scope.
Notation " 'elems' [ x ; y ; .. ; z ] " :=
  (elems_ (cons x (cons y .. (cons z nil) ..))) : qc_scope.
(* Why not [elems (x :: l)]? *)
Notation " 'elems' ( x ;; l ) " :=
  (elems_ (cons x l)) (at level 201, no associativity) : qc_scope.

(* We insert thunks ([etaG]) to delay the execution of
   each element until it actually gets chosen. *)

Notation " 'oneOf' [ x ] " := x : qc_scope.
Notation " 'oneOf' [ x ; y ] " :=
  (oneOf_ (cons x (cons y nil))) : qc_scope.
Notation " 'oneOf' [ x ; y ; .. ; z ] " :=
  (oneOf_ (cons x
    (cons y .. (cons z nil) ..))) : qc_scope.
Notation " 'oneOf' ( x ;; l ) " :=
  (oneOf_ (cons x l))  (at level 1, no associativity) : qc_scope.

(* freq [ 4 %: g1 ; 6 %: g2 ] *)
Notation " 'freq' [ x ] " := ((x : nat * G _).2) : qc_scope.
Notation " 'freq' [ x ; y ] " :=
  (freq_ (cons x (cons y nil))) : qc_scope.
Notation " 'freq' [ x ; y ; .. ; z ] " :=
  (freq_ (cons x (cons y .. (cons z nil) ..))) : qc_scope.
Notation " 'freq' ( x ;; l ) " :=
  (freq_ (cons x l)) (at level 1, no associativity) : qc_scope.

Notation "w %: g" := (w, etaG g)
  (at level 100) : qc_scope.

Delimit Scope qc_scope with qc.

End QcDefaultNotation.

Import QcDefaultNotation. Open Scope qc_scope.

(*
Parameter semElemsSize : forall A (x : A) xs s,
  semGenSize (elems (x ;; xs)) s <--> x :: xs.

Parameter semElems : forall A (x : A) xs,
  semGen (elems (x ;; xs)) <--> x :: xs.

Parameter semOneOfSize : forall A (g0 : G A) (gs : list (G A)) s,
  semGenSize (oneOf (g0 ;; gs)) s  <--> \bigcup_(g in (g0 :: gs)) semGenSize g s.

Parameter semOneOf : forall A (g0 : G A) (gs : list (G A)),
  semGen (oneOf (g0 ;; gs))  <--> \bigcup_(g in (g0 :: gs)) semGen g.
*)
End Sig.
