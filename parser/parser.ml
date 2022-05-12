
(* We have to set the felix version first. *)
Flx_version_hook.set_version ()
;;

let compiler_options = Flxg_options.parse_args ()
;;

print_endline ("force-recompile=" ^ Bool.to_string compiler_options.force_recompile)
;;

print_endline ("Files to parse = " ^ String.concat ", " compiler_options.files)
;;

let parser_state = Flxg_parse.load_syntax compiler_options 
;;

if List.length compiler_options.files > 0 then
  List.iter (fun file -> 
    print_endline ("Parsing file " ^ file);
    let sexs =  Flxg_parse.parse_file compiler_options parser_state file in
    List.iter (fun sex ->
      print_endline "OCS scheme term converted to s-expression:";
      Sex_print.sex_print sex
    ) sexs;
  ) compiler_options.files 
else
  print_endline ("No input files");

  


print_endline ("Hello world from parser exe")
;;

