(** Generated by coq-of-ocaml *)
Require Import OCaml.OCaml.

Local Open Scope string_scope.
Local Open Scope Z_scope.
Local Open Scope type_scope.
Import ListNotations.

Unset Positivity Checking.
Unset Guard Checking.

Require Import Tezos.Environment.

Parameter num : forall (t : Set), Set.

Inductive n : Set :=
| Natural_tag : n.

Inductive z : Set :=
| Integer_tag : z.

Parameter zero_n : num n.

Parameter zero : num z.

Parameter compare : forall {a : Set}, num a -> num a -> Z.

Parameter to_string : forall {A : Set}, num A -> string.

Parameter of_string : string -> option (num z).

Parameter to_int64 : forall {A : Set}, num A -> option int64.

Parameter of_int64 : int64 -> num z.

Parameter to_int : forall {A : Set}, num A -> option Z.

Parameter of_int : Z -> num z.

Parameter of_zint : Z.t -> num z.

Parameter to_zint : forall {a : Set}, num a -> Z.t.

Parameter add_n : num n -> num n -> num n.

Parameter mul_n : num n -> num n -> num n.

Parameter ediv_n : num n -> num n -> option (num n * num n).

Parameter add : forall {A B : Set}, num A -> num B -> num z.

Parameter sub : forall {A B : Set}, num A -> num B -> num z.

Parameter mul : forall {A B : Set}, num A -> num B -> num z.

Parameter ediv : forall {A B : Set}, num A -> num B -> option (num z * num n).

Parameter abs : num z -> num n.

Parameter is_nat : num z -> option (num n).

Parameter neg : forall {A : Set}, num A -> num z.

Parameter __int_value : num n -> num z.

Parameter lognot : forall {A : Set}, num A -> num z.

Parameter shift_left_n : num n -> num n -> option (num n).

Parameter shift_right_n : num n -> num n -> option (num n).

Parameter shift_left : forall {a : Set}, num a -> num n -> option (num a).

Parameter shift_right : forall {a : Set}, num a -> num n -> option (num a).

Parameter logor : forall {a : Set}, num a -> num a -> num a.

Parameter logand : forall {A : Set}, num A -> num n -> num n.

Parameter logxor : num n -> num n -> num n.
