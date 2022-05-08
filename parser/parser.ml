
(* We have to set the felix version first. *)
Flx_version_hook.set_version ()
;;

let compiler_options = Flxg_options.parse_args ()
;;

let parser_state = Flxg_parse.load_syntax compiler_options 
;;

print_endline ("Hello world from parser exe")
;;

