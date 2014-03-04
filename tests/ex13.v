Require Import CoqOfOCaml.

Local Open Scope Z_scope.
Import ListNotations.
Set Implicit Arguments.

Definition tail {A : Type} (l : list A) : M [ Failure ] (list A) :=
  match l with
  | cons _ xs => ret xs
  | [] => failwith "Cannot take the tail of an empty list." % string
  end.

Fixpoint print_list_rec (counter : nat) (match_var_0 : list string) :
  M [ IO; NonTermination ] unit :=
  match counter with
  | 0 % nat => lift [_;_] "01" (not_terminated tt)
  | S counter =>
    match match_var_0 with
    | [] => ret tt
    | cons x xs =>
      let! _ := lift [_;_] "10" (print_string x) in
      (print_list_rec counter) xs
    end
  end.

Definition print_list (match_var_0 : list string) :
  M [ Counter; IO; NonTermination ] unit :=
  let! counter := lift [_;_;_] "100" (read_counter tt) in
  lift [_;_;_] "011" ((print_list_rec counter) match_var_0).

Definition f : (list string) -> M [ Counter; IO; NonTermination ] unit :=
  print_list.

Definition x {A : Type} (z : A) :
  M [ Counter; Failure; IO; NonTermination ] unit :=
  let! x :=
    lift [_;_;_;_] "0100"
      (tail
        (cons "Stop" % string
          (cons "Hello" % string (cons " " % string (cons "world" % string [])))))
    in
  lift [_;_;_;_] "1011" (f x).
