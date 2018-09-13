(* Copyright (C) 2017 Ryan Kavanagh <rkavanagh@cs.cmu.edu>       *)
(* Distributed under the ISC license, see COPYING for details.   *)

functor Helper (structure C : sig val handinPath : string end)
	:> HELPER =
struct

exception MissingFile of string

datatype checks = Check   of string * (unit -> unit)
		| Problem of string * (unit -> real)

val handinPath = C.handinPath

fun printLn s = print (s ^ "\n")

(* Puts strings in boxes... *)
fun stringsInBox strs =
  let fun repeatChar c n = String.implode (List.tabulate (n, fn _ => c))
      val maxLength = List.foldl (fn (s,themax) => Int.max (String.size s, themax)) 0 strs
      val edge = repeatChar #"#" (maxLength + 4)
  in
      edge :: (List.foldr (fn (s,thelist) => ("# "
					      ^ s
					      ^ (repeatChar #" " (maxLength - (String.size s)))
					      ^ " #") :: thelist)
			  [edge]
			  strs)
  end

(* Prints strings in boxes... *)
fun printInBox strs = List.app printLn (stringsInBox strs)

(* Generates an AutoLab json score string *)
fun scoresToString (scores, scoreboard) =
  let val scoreStrings = map (fn (problem, score) => "\"" ^ problem ^ "\": " ^ (Real.toString score)) scores
      val scores = String.concatWith ", " scoreStrings
      val scoreboard = case scoreboard
			of SOME l => ", \"scoreboard\": [" ^ (String.concatWith ", " (map Int.toString l)) ^ "]"
			 | NONE => ""
  in
      "{\"scores\": {" ^ scores ^ "}" ^ scoreboard ^ "}"
  end

(* Aborts the program by printing strs, and gives an empty score. *)
fun abortWithMessage strs =
  let val _ = List.app printLn strs
      val _ = printLn (scoresToString ([],NONE))
  in
      OS.Process.exit OS.Process.success
  end


(* Reads the lines of a file into a list *)
(* Each string in the file will always be contain a newline (#"\n") at the end. *)
fun readLines filename =
  let val inFile = TextIO.openIn filename
      fun readlines ins =
	case TextIO.inputLine ins
	 of SOME ln => ln :: readlines ins
	  | NONE => []
      val lines = readlines inFile
      val _ = TextIO.closeIn inFile
  in
      lines
  end

(* Check if the file exists *)
fun checkFileExists (name : string) : unit =
  if OS.FileSys.access (name, [OS.FileSys.A_READ])
  then ()
  else raise MissingFile name

fun joinHandinPath file =
  OS.Path.concat (handinPath, file)

fun stripHandinPath path =
  if String.isPrefix handinPath path then
      String.extract (path, String.size handinPath + 1, NONE)
  else
      path


(* Takes in a list of filenames, and checks if those files *)
(* exist in the handinPath directory. *)
(* Exits catastrophically if a file is missing. *)
fun checkFilesExist filenames =
  List.app (checkFileExists o joinHandinPath) filenames
  handle MissingFile name => (abortWithMessage o stringsInBox)
				 [ "File " ^ (stripHandinPath name) ^ " missing."
				 , "Please make sure you included all required files and resubmit."]

fun runCmd cmd = (printLn cmd; OS.Process.system cmd)

(* Reads from fd in n byte chunks and treats it all as strings. *)
fun readAllFDAsString (fd, n) =
  let val v = Posix.IO.readVec (fd, n)
  in if Word8Vector.length v = 0 then
	 ""
     else
	 (Byte.bytesToString v) ^ (readAllFDAsString (fd, n))
  end

(* Runs a command c (command and argument list) using Posix.Process.execp. *)
(* Return the program's output as a string, along with its exit status. *)
fun execpOutput (c : string * string list) : string * Posix.Process.exit_status =
  let val { infd = infd, outfd = outfd } = Posix.IO.pipe ()
  in case Posix.Process.fork ()
      of NONE => (* Child *)
	 (( Posix.IO.close infd
	  ; Posix.IO.dup2 { old = outfd, new = Posix.FileSys.stdout }
	  ; Posix.IO.dup2 { old = outfd, new = Posix.FileSys.stderr }
	  ; Posix.Process.execp c)
	  handle OS.SysErr (err, _) =>
		 ( print ("Fatal error in child: " ^ err ^ "\n")
		 ; OS.Process.exit OS.Process.failure ))
       | SOME pid => (* Parent *)
	 let val _ = Posix.IO.close outfd
	     val (_, status) = Posix.Process.waitpid (Posix.Process.W_CHILD pid, [])
	     val output = readAllFDAsString (infd, 100)
	     val _ = Posix.IO.close infd
	 in (output, status) end
  end


(* Check if a submitted file is a valid PDF using ghostscript. *)
fun checkPDF pdf =
  let val spdf = joinHandinPath pdf in
      case ( runCmd ("gs -o/dev/null -sDEVICE=nullpage " ^ spdf)
	   , Posix.FileSys.ST.size (Posix.FileSys.stat spdf) )
       of (_,0) => let val _ = printInBox [ "Warning: The empty file " ^ pdf ^ " is not a valid PDF document."
					  , "Please make sure to resubmit with a valid PDF document in its place." ]
		   in () end
	| (0,_) => ()
	| _ => (abortWithMessage o stringsInBox)
		   [ "The file " ^ pdf ^ " is not a valid PDF document."
		   , "Please resubmit with a valid PDF document (or an empty file) in its place."
		   , "If you are convinced you submitted a valid PDF, please contact the course staff." ]
  end

(* Runs all of the checks and grades all of the problems in "checks". *)
fun runChecks (checks : checks list) =
  List.foldl (fn (cs,results) =>
		 case cs
		  of (Check (n, c)) => let val _ = printLn ("\n\nRunning check " ^ n ^ "...")
					   val _ = c ()
					   val _ = printLn " Success.\n"
				       in results end
		   | (Problem (n, c)) => let val _ = printLn ("\n\nChecking problem " ^ n ^ "...")
					     val res = c ()
					     val _ = printLn (" Score: " ^ (Real.toString res) ^ ".\n")
					 in (n, res) :: results end)
	     []
	     checks


(* Returns a score of zero for all problems. *)
(* Useful when you need to abort but still provide a score. *)
fun failAll (checks : checks list) =
  List.foldr (fn (cs,results) =>
		 case cs
		  of Problem (n, c) => (n, 0) :: results
		   | _ => results)
	     []
	     checks

structure RE = RegExpFn(structure P = AwkSyntax
			structure E = ThompsonEngine)

fun matchesAwkRegex (r, s) =
  let val r = RE.find (RE.compileString r)
  in Option.isSome (StringCvt.scanString r s) end
end
