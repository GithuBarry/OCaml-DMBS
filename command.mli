(**
   Parsing of user commands.
*)


(** The type [expr_objects] represents a value of boolean or table data
    when representing a boolean, it should be [column_name operator value]
    as separate elements
    An [expr_objects] is not permitted to be the empty list. *)
type expr_objects = string list
(** The type [column_objects] represents column name(s) *)
type column_objects = string list
(** The type [element_phrases] represents a distinct table name
    accross different files *)
type table_name = string

(** The type [command_verb] represents a necessary identifer of the command
    and the necessary reference it operates on*)
type command_verb = 
  | Select of column_objects
  | InsertInto of table_name * (column_objects option)
  | Update of table_name
  | Delete
  | Quit

(** The type [command_subject] represents a necessary identifer of the command
    and the necessary reference of the subject the [command_verb] operates on*)
type command_subject =   
  | From of table_name
  | Where of expr_objects
  | Values of expr_objects
  | Set of expr_objects

(** The type [command_formatter] represents an identifer for whether the output
    needs some formatting *)
type command_formatter = 
  | OrderBy of column_objects
  | Distinct

(** The type [command] represents a user command, It is decomposed
    into a [command_verb], non-empty [command_subject] list and an optional 
    [command_formatter] *)
type command = command_verb * command_subject list 
               * command_formatter list

(** Raised when an empty command is parsed. *)
exception Empty

(** Raised when a malformed command is encountered. *)
exception Malformed

(** [parse str] parses a user's input into a [command], as follows. The first
    word (i.e., consecutive sequence of non-space characters) of [str] becomes 
    the verb. The rest of the words, if any, become the object phrase.
    Examples: 
    - [parse " SELECT column_name1, column_name2 FROM    table_name;  "] is 
      [Select [column_name1; column_name2] from [table_name]]
    - [parse "quit"] is [Quit]. 

    Requires: [str] contains only alphanumeric (A-Z, a-z, 0-9) and space 
    characters (only ASCII character code 32; not tabs or newlines, etc.) and
    ends with [;].

    Raises: [Empty] if [str] is the empty string or contains only spaces. 

    Raises: [Malformed] if the command is malformed. A command
    is {i malformed} if the combination is not valid (e.g. Delete Values "s")
    or unknown words are parsed *)
val parse : string -> command
