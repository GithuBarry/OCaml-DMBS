open Csv
open Hashtbl
open Sys

let rmv_csv_tl (s:string) = String.sub s 0 (String.length s -4)

let is_csv (s:string) : bool =
  let len = String.length s in
  if len < 4 then false
  else String.sub s (len-4) (4) = ".csv" 

let all_csv_files cur_directory =
  let all_files = cur_directory|>Sys.readdir|>Array.to_list in
  List.fold_left 
    (fun x e -> if is_csv e then e::x else x) [] all_files

(**[csv_array filename] is a string array array representation of [filename] *)
let csv_array filename = let csv_read = Csv.load filename in
  csv_read|>Csv.to_array

(**[csv_columns filename] is number rows in a [filename]*)
let csv_columns filename = Csv.(filename|>load|>lines)

(**[to_csv array_csv] is a csv from csv array representation [array_csv]. *)
let to_csv array_csv = let csv1 = Csv.(array_csv|>of_array)
  in csv1

(**[save fn array_csv] saves [array_csv] to filename [fn]. [fn] does not contain
   .csv at the end.*)
let save fn array_csv = Csv.save (fn^".csv") (to_csv array_csv)

(** [update_csv_files dir hastbl] updates the csv_files in [dir] with data from
    [hastbl].*)
let update_csv_files dir hastbl =
  let original_directory = Sys.getcwd () in
  Sys.chdir dir;
  (* get my hastbl values and call save on each *)
  Hashtbl.iter save hastbl;
  Sys.chdir original_directory

(**[is_dir dir] returns true if [dir] is existing dir. [false] otherewise.*)
let is_dir dir = 
  try is_directory dir with x -> false

let rec add_data_to_htbl tbl = function
  | [] -> ()
  | h::t -> 
    (Hashtbl.add tbl (rmv_csv_tl h) (csv_array h) );
    add_data_to_htbl tbl t

(** [csvs_in_hastbl dir tbl] changes first given [dir] to attain [csv] files
    Once files are attained, comes back to original directory*)
let csvs_in_hastbl dir tbl =
  let original_directory = Sys.getcwd () in
  let file_titles = (dir |> all_csv_files) in
  Sys.chdir dir;
  add_data_to_htbl tbl file_titles;
  Sys.chdir original_directory

