(* Copyright (C) 2017 Ryan Kavanagh <rkavanagh@cs.cmu.edu>       *)
(* Distributed under the ISC license, see COPYING for details.   *)

structure Main :>
	  sig
	      val main : (string * string list) -> OS.Process.status
	  end
=
struct
structure H = Helper (structure C = struct val handinPath = "handin" end)
structure C = ChecksHelper(structure H = H)

fun main _ =
  let val scores = H.runChecks C.checks
      val scoreboard = C.scoreboard scores
      (* Make sure the scores are on the last line. *)
      val _ = print "\n\n\n"
      (* This below *must must must* be the last thing printed.. *)
      val _ = H.printLn (H.scoresToString (scores, scoreboard))
  in OS.Process.success end
  handle _ => (H.abortWithMessage o H.stringsInBox)
		  [ "Experienced uncaught exception!"
		  , "If you believe this to be in error, please contact your"
		    ^ " course staff." ]
end
