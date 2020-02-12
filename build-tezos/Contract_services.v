(** Generated by coq-of-ocaml *)
Require Import OCaml.OCaml.

Local Open Scope string_scope.
Local Open Scope Z_scope.
Local Open Scope type_scope.
Import ListNotations.

Unset Positivity Checking.
Unset Guard Checking.

Require Import Tezos.Environment.
Require Tezos.Alpha_context_mli. Module Alpha_context := Alpha_context_mli.
Require Tezos.Michelson_v1_primitives.
Require Tezos.Script_expr_hash.
Require Tezos.Script_ir_translator.
Require Tezos.Script_typed_ir.
Require Tezos.Services_registration.

Import Alpha_context.

Definition custom_root : RPC_path.context RPC_context.t :=
  RPC_path.op_div (RPC_path.op_div RPC_path.open_root "context") "contracts".

Definition big_map_root : RPC_path.context RPC_context.t :=
  RPC_path.op_div (RPC_path.op_div RPC_path.open_root "context") "big_maps".

Module info.
  Record record := Build {
    balance : Alpha_context.Tez.t;
    delegate : option Alpha_context.public_key_hash;
    counter : option Alpha_context.counter;
    script : option Alpha_context.Script.t }.
  Definition with_balance balance (r : record) :=
    Build balance r.(delegate) r.(counter) r.(script).
  Definition with_delegate delegate (r : record) :=
    Build r.(balance) delegate r.(counter) r.(script).
  Definition with_counter counter (r : record) :=
    Build r.(balance) r.(delegate) counter r.(script).
  Definition with_script script (r : record) :=
    Build r.(balance) r.(delegate) r.(counter) script.
End info.
Definition info := info.record.

Definition info_encoding : Data_encoding.encoding info :=
  Pervasives.op_atat
    (let arg :=
      Data_encoding.conv
        (fun function_parameter =>
          let '{|
            info.balance := balance;
              info.delegate := delegate;
              info.counter := counter;
              info.script := script
              |} := function_parameter in
          (balance, delegate, script, counter))
        (fun function_parameter =>
          let '(balance, delegate, script, counter) := function_parameter in
          {| info.balance := balance; info.delegate := delegate;
            info.counter := counter; info.script := script |}) in
    fun eta => arg None eta)
    (Data_encoding.obj4
      (Data_encoding.req None None "balance" Alpha_context.Tez.encoding)
      (Data_encoding.opt None None "delegate"
        (|Signature.Public_key_hash|).(S.SPublic_key_hash.encoding))
      (Data_encoding.opt None None "script" Alpha_context.Script.encoding)
      (Data_encoding.opt None None "counter" Data_encoding.n)).

Module S.
  Import Data_encoding.
  
  Definition balance
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit
      Alpha_context.Tez.t :=
    RPC_service.get_service (Some "Access the balance of a contract.")
      RPC_query.empty Alpha_context.Tez.encoding
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "balance").
  
  Definition manager_key
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit
      (option (|Signature.Public_key|).(S.SPublic_key.t)) :=
    RPC_service.get_service (Some "Access the manager of a contract.")
      RPC_query.empty
      (Data_encoding.__option_value
        (|Signature.Public_key|).(S.SPublic_key.encoding))
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "manager_key").
  
  Definition delegate
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit
      (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) :=
    RPC_service.get_service (Some "Access the delegate of a contract, if any.")
      RPC_query.empty
      (|Signature.Public_key_hash|).(S.SPublic_key_hash.encoding)
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "delegate").
  
  Definition counter
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit Z.t :=
    RPC_service.get_service (Some "Access the counter of a contract, if any.")
      RPC_query.empty Data_encoding.z
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "counter").
  
  Definition script
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit
      Alpha_context.Script.t :=
    RPC_service.get_service (Some "Access the code and data of the contract.")
      RPC_query.empty Alpha_context.Script.encoding
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "script").
  
  Definition storage
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit
      Alpha_context.Script.expr :=
    RPC_service.get_service (Some "Access the data of the contract.")
      RPC_query.empty Alpha_context.Script.expr_encoding
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "storage").
  
  Definition entrypoint_type
    : RPC_service.service (* `GET *) unit RPC_context.t
      ((RPC_context.t * Alpha_context.Contract.contract) * string) unit unit
      Alpha_context.Script.expr :=
    RPC_service.get_service
      (Some "Return the type of the given entrypoint of the contract")
      RPC_query.empty Alpha_context.Script.expr_encoding
      (RPC_path.op_divcolon
        (RPC_path.op_div
          (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
          "entrypoints") RPC_arg.__string_value).
  
  Definition list_entrypoints
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit
      (list (list Michelson_v1_primitives.prim) *
        list (string * Alpha_context.Script.expr)) :=
    RPC_service.get_service
      (Some "Return the list of entrypoints of the contract") RPC_query.empty
      (Data_encoding.obj2
        (Data_encoding.dft None None "unreachable"
          (Data_encoding.__list_value None
            (Data_encoding.obj1
              (Data_encoding.req None None "path"
                (Data_encoding.__list_value None
                  Michelson_v1_primitives.prim_encoding)))) nil)
        (Data_encoding.req None None "entrypoints"
          (Data_encoding.assoc Alpha_context.Script.expr_encoding)))
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "entrypoints").
  
  Definition contract_big_map_get_opt
    : RPC_service.service (* `POST *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit
      (Alpha_context.Script.expr * Alpha_context.Script.expr)
      (option Alpha_context.Script.expr) :=
    RPC_service.post_service
      (Some
        "Access the value associated with a key in a big map of the contract (deprecated).")
      RPC_query.empty
      (Data_encoding.obj2
        (Data_encoding.req None None "key" Alpha_context.Script.expr_encoding)
        (Data_encoding.req None None "type" Alpha_context.Script.expr_encoding))
      (Data_encoding.__option_value Alpha_context.Script.expr_encoding)
      (RPC_path.op_div
        (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg)
        "big_map_get").
  
  Definition big_map_get
    : RPC_service.service (* `GET *) unit RPC_context.t
      ((RPC_context.t * Alpha_context.Big_map.id) * Script_expr_hash.t) unit
      unit Alpha_context.Script.expr :=
    RPC_service.get_service
      (Some "Access the value associated with a key in a big map.")
      RPC_query.empty Alpha_context.Script.expr_encoding
      (RPC_path.op_divcolon
        (RPC_path.op_divcolon big_map_root Alpha_context.Big_map.rpc_arg)
        Script_expr_hash.rpc_arg).
  
  Definition info
    : RPC_service.service (* `GET *) unit RPC_context.t
      (RPC_context.t * Alpha_context.Contract.contract) unit unit info :=
    RPC_service.get_service (Some "Access the complete status of a contract.")
      RPC_query.empty info_encoding
      (RPC_path.op_divcolon custom_root Alpha_context.Contract.rpc_arg).
  
  Definition __list_value
    : RPC_service.service (* `GET *) unit RPC_context.t RPC_context.t unit unit
      (list Alpha_context.Contract.t) :=
    RPC_service.get_service
      (Some "All existing contracts (including non-empty default contracts).")
      RPC_query.empty
      (Data_encoding.__list_value None Alpha_context.Contract.encoding)
      custom_root.
End S.

Definition register (function_parameter : unit) : unit :=
  let '_ := function_parameter in
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  let register_field {A : Set}
    (s :
      RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) Updater.rpc_context
        (Updater.rpc_context * Alpha_context.Contract.contract) unit unit A)
    (f :
      Alpha_context.t -> Alpha_context.Contract.contract ->
      Lwt.t (Error_monad.tzresult A)) : unit :=
    Services_registration.register1 s
      (fun ctxt =>
        fun contract =>
          fun function_parameter =>
            let '_ := function_parameter in
            fun function_parameter =>
              let '_ := function_parameter in
              Error_monad.op_gtgteqquestion
                (Alpha_context.Contract.__exists ctxt contract)
                (fun function_parameter =>
                  match function_parameter with
                  | true => f ctxt contract
                  | false => Pervasives.raise extensible_type_value
                  end)) in
  let register_opt_field {A : Set}
    (s :
      RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) Updater.rpc_context
        (Updater.rpc_context * Alpha_context.Contract.contract) unit unit A)
    (f :
      Alpha_context.t -> Alpha_context.Contract.contract ->
      Lwt.t (Error_monad.tzresult (option A))) : unit :=
    register_field s
      (fun ctxt =>
        fun a1 =>
          Error_monad.op_gtgteqquestion (f ctxt a1)
            (fun function_parameter =>
              match function_parameter with
              | None => Pervasives.raise extensible_type_value
              | Some v => Error_monad.__return v
              end)) in
  let do_big_map_get
    (ctxt : Alpha_context.context) (id : Alpha_context.Big_map.id)
    (__key_value : Script_expr_hash.t)
    : Lwt.t
      (Error_monad.tzresult (Micheline.canonical Alpha_context.Script.prim)) :=
    let ctxt := Alpha_context.Gas.set_unlimited ctxt in
    Error_monad.op_gtgteqquestion (Alpha_context.Big_map.__exists ctxt id)
      (fun function_parameter =>
        let '(ctxt, types) := function_parameter in
        match types with
        | None => Pervasives.raise extensible_type_value
        | Some (_, value_type) =>
          Error_monad.op_gtgteqquestion
            (Lwt.__return
              (Script_ir_translator.parse_ty ctxt true false false true
                (Micheline.root value_type)))
            (fun function_parameter =>
              let '(Script_ir_translator.Ex_ty value_type, ctxt) :=
                function_parameter in
              let 'existT _ __Ex_ty_'a [value_type, ctxt] :=
                existT
                  (fun __Ex_ty_'a : Set =>
                    [(Script_typed_ir.ty __Ex_ty_'a) ** Alpha_context.context])
                  _ [value_type, ctxt] in
              Error_monad.op_gtgteqquestion
                (Alpha_context.Big_map.get_opt ctxt id __key_value)
                (fun function_parameter =>
                  let '(_ctxt, value) := function_parameter in
                  match value with
                  | None => Pervasives.raise extensible_type_value
                  | Some value =>
                    Error_monad.op_gtgteqquestion
                      (Script_ir_translator.parse_data None ctxt true value_type
                        (Micheline.root value))
                      (fun function_parameter =>
                        let '(value, ctxt) := function_parameter in
                        Error_monad.op_gtgteqquestion
                          (Script_ir_translator.unparse_data ctxt
                            Script_ir_translator.Readable value_type value)
                          (fun function_parameter =>
                            let '(value, _ctxt) := function_parameter in
                            Error_monad.__return
                              (Micheline.strip_locations value)))
                  end))
        end) in
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  (* ❌ Sequences of instructions are ignored (operator ";") *)
  (* ❌ instruction_sequence ";" *)
  register_field S.info
    (fun ctxt =>
      fun contract =>
        Error_monad.op_gtgteqquestion
          (Alpha_context.Contract.get_balance ctxt contract)
          (fun balance =>
            Error_monad.op_gtgteqquestion
              (Alpha_context.Delegate.get ctxt contract)
              (fun delegate =>
                Error_monad.op_gtgteqquestion
                  match Alpha_context.Contract.is_implicit contract with
                  | Some manager =>
                    Error_monad.op_gtgteqquestion
                      (Alpha_context.Contract.get_counter ctxt manager)
                      (fun counter => Error_monad.return_some counter)
                  | None => Error_monad.__return None
                  end
                  (fun counter =>
                    Error_monad.op_gtgteqquestion
                      (Alpha_context.Contract.get_script ctxt contract)
                      (fun function_parameter =>
                        let '(ctxt, script) := function_parameter in
                        Error_monad.op_gtgteqquestion
                          match script with
                          | None => Error_monad.__return (None, ctxt)
                          | Some script =>
                            let ctxt := Alpha_context.Gas.set_unlimited ctxt in
                            Error_monad.op_gtgteqquestion
                              (Script_ir_translator.parse_script None ctxt true
                                script)
                              (fun function_parameter =>
                                let
                                  '(Script_ir_translator.Ex_script script, ctxt) :=
                                  function_parameter in
                                let 'existT _ [__Ex_script_'a2, __Ex_script_'b2]
                                  [script, ctxt] :=
                                  existT
                                    (fun '[__Ex_script_'a2, __Ex_script_'b2] =>
                                      [(Script_typed_ir.script __Ex_script_'a2
                                        __Ex_script_'b2) **
                                        Alpha_context.context]) _ [script, ctxt]
                                  in
                                Error_monad.op_gtgteqquestion
                                  (Script_ir_translator.unparse_script ctxt
                                    Script_ir_translator.Readable script)
                                  (fun function_parameter =>
                                    let '(script, ctxt) := function_parameter in
                                    Error_monad.__return ((Some script), ctxt)))
                          end
                          (fun function_parameter =>
                            let '(script, _ctxt) := function_parameter in
                            Error_monad.__return
                              {| info.balance := balance;
                                info.delegate := delegate;
                                info.counter := counter; info.script := script
                                |})))))).

Definition __list_value {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  : Lwt.t (Error_monad.shell_tzresult (list Alpha_context.Contract.t)) :=
  RPC_context.make_call0 S.__list_value ctxt block tt tt.

Definition info {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t (Error_monad.shell_tzresult info) :=
  RPC_context.make_call1 S.info ctxt block contract tt tt.

Definition balance {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t (Error_monad.shell_tzresult Alpha_context.Tez.t) :=
  RPC_context.make_call1 S.balance ctxt block contract tt tt.

Definition manager_key {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (mgr : Alpha_context.public_key_hash)
  : Lwt.t
    (Error_monad.shell_tzresult
      (option (|Signature.Public_key|).(S.SPublic_key.t))) :=
  RPC_context.make_call1 S.manager_key ctxt block
    (Alpha_context.Contract.implicit_contract mgr) tt tt.

Definition delegate {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t
    (Error_monad.shell_tzresult
      (|Signature.Public_key_hash|).(S.SPublic_key_hash.t)) :=
  RPC_context.make_call1 S.delegate ctxt block contract tt tt.

Definition delegate_opt {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t
    (Error_monad.shell_tzresult
      (option (|Signature.Public_key_hash|).(S.SPublic_key_hash.t))) :=
  RPC_context.make_opt_call1 S.delegate ctxt block contract tt tt.

Definition counter {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (mgr : Alpha_context.public_key_hash)
  : Lwt.t (Error_monad.shell_tzresult Z.t) :=
  RPC_context.make_call1 S.counter ctxt block
    (Alpha_context.Contract.implicit_contract mgr) tt tt.

Definition script {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t (Error_monad.shell_tzresult Alpha_context.Script.t) :=
  RPC_context.make_call1 S.script ctxt block contract tt tt.

Definition script_opt {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t (Error_monad.shell_tzresult (option Alpha_context.Script.t)) :=
  RPC_context.make_opt_call1 S.script ctxt block contract tt tt.

Definition storage {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t (Error_monad.shell_tzresult Alpha_context.Script.expr) :=
  RPC_context.make_call1 S.storage ctxt block contract tt tt.

Definition entrypoint_type {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract) (entrypoint : string)
  : Lwt.t (Error_monad.shell_tzresult Alpha_context.Script.expr) :=
  RPC_context.make_call2 S.entrypoint_type ctxt block contract entrypoint tt tt.

Definition list_entrypoints {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t
    (Error_monad.shell_tzresult
      (list (list Michelson_v1_primitives.prim) *
        list (string * Alpha_context.Script.expr))) :=
  RPC_context.make_call1 S.list_entrypoints ctxt block contract tt tt.

Definition storage_opt {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  : Lwt.t (Error_monad.shell_tzresult (option Alpha_context.Script.expr)) :=
  RPC_context.make_opt_call1 S.storage ctxt block contract tt tt.

Definition big_map_get {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (id : Alpha_context.Big_map.id) (__key_value : Script_expr_hash.t)
  : Lwt.t (Error_monad.shell_tzresult Alpha_context.Script.expr) :=
  RPC_context.make_call2 S.big_map_get ctxt block id __key_value tt tt.

Definition contract_big_map_get_opt {D E G I K L a b c i o q : Set}
  (ctxt :
    (((RPC_service.t
      ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
        (* `POST *) unit + (* `PUT *) unit) RPC_context.t RPC_context.t q i o ->
    D -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) * (E * q * i * o)) *
      (((RPC_service.t
        ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
          (* `POST *) unit + (* `PUT *) unit) RPC_context.t (RPC_context.t * a)
        q i o -> D -> a -> q -> i -> Lwt.t (Error_monad.shell_tzresult o)) *
        (G * a * q * i * o)) *
        (((RPC_service.t
          ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
            (* `POST *) unit + (* `PUT *) unit) RPC_context.t
          ((RPC_context.t * a) * b) q i o -> D -> a -> b -> q -> i ->
        Lwt.t (Error_monad.shell_tzresult o)) * (I * a * b * q * i * o)) *
          (((RPC_service.t
            ((* `DELETE *) unit + (* `GET *) unit + (* `PATCH *) unit +
              (* `POST *) unit + (* `PUT *) unit) RPC_context.t
            (((RPC_context.t * a) * b) * c) q i o -> D -> a -> b -> c -> q ->
          i -> Lwt.t (Error_monad.shell_tzresult o)) *
            (K * a * b * c * q * i * o)) * L)))) * L * D) (block : D)
  (contract : Alpha_context.Contract.contract)
  (__key_value : Alpha_context.Script.expr * Alpha_context.Script.expr)
  : Lwt.t (Error_monad.shell_tzresult (option Alpha_context.Script.expr)) :=
  RPC_context.make_call1 S.contract_big_map_get_opt ctxt block contract tt
    __key_value.
