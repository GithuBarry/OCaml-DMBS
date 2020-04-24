open Command
open Iohandler
open Datatable
open Hashtbl
(* The user interactive command line *)

(** [print_array array] prints every element in [array]*)
let print_array array =
  Array.iter print_string array

(** [print_2D_array array] prints [array]  in a matrix format*)
let print_2D_array (array:string array array) = 
  array |> Array.iter (fun x -> 
      Array.iter (fun x -> print_string x; print_string "  ") x; 
      print_endline "")

(** [get_table_name command_subject_lst] is the [table_name] represented in 
    the [command_subject_lst] 
    Requires: first element of [command_subject_lst] should be "From table_name"
    Raise: Malformed when requirement not met. 
*)
let get_table_name command_subject_lst = 
  match command_subject_lst with 
  | (From table_name) :: tail -> table_name
  | _-> raise Malformed

let database = Hashtbl.create 100 

let rec rep_loop () : unit=
  print_string "\n\n Enter command: \n\n > ";
  try begin 
    let (command_verb, command_subject_lst, command_formatter_lst) = 
      parse (read_line ()) 
    in 
    match command_verb with 
    | Select column_objects ->
      let table_name = get_table_name command_subject_lst in
      begin
        match column_objects with
        | Wildcard -> 
          (Hashtbl.find database table_name)|> print_2D_array;rep_loop () 
        | Columns cols -> 
          table_name|> Hashtbl.find database|> get_cols_data cols
          |>print_2D_array; rep_loop ()
      end
    | InsertInto (table_name, column_objects_opt) -> failwith("Unimplemented")
    | Update table_name -> failwith("Unimplemented")
    | Delete-> failwith("Unimplemented")
    | Quit -> print_endline("Quiting database"); exit 0
  end 
  with 
  | Empty -> 
    print_endline " Please enter non empty command \n > ";
    rep_loop ()
  | Malformed ->       
    print_endline " Invalid command \n > ";
    rep_loop ()
  | Not_found ->       
    print_endline " Invalid table/column name \n > ";
    rep_loop ()

(** [main ()] prompts for the directory/folder to open, then initiates REPL. *)
let main () =
  ANSITerminal.(print_string [ red ] "\n\n Welcome to the OCaml-DBMS.\n");
  print_endline " Please enter the directory of the Database.\n";
  print_string "> ";
  let rec get_database () =  
    match read_line () with 
    | str when String.trim str = ""-> 
      print_string " Please enter non empty command \n > "; get_database()
    | str when Sys.is_directory str = false -> 
      print_string " Please enter valid directory \n > "; get_database()
    | dir -> Iohandler.csvs_in_hastbl dir database
  in
  get_database (); 
  rep_loop ()

(** Start the program *)
let () = main ()
