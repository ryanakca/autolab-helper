(* From: https://github.com/msullivan/sml-util                                   *)
(* Copyright (c) 2011-2015 Michael J. Sullivan                                   *)
(*                                                                               *)
(* Permission is hereby granted, free of charge, to any person obtaining a copy  *)
(* of this software and associated documentation files (the "Software"), to deal *)
(* in the Software without restriction, including without limitation the rights  *)
(* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     *)
(* copies of the Software, and to permit persons to whom the Software is         *)
(* furnished to do so, subject to the following conditions:                      *)
(*                                                                               *)
(* The above copyright notice and this permission notice shall be included in    *)
(* all copies or substantial portions of the Software.                           *)
(*                                                                               *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *)
(* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      *)
(* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   *)
(* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        *)
(* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, *)
(* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     *)
(* THE SOFTWARE.                                                                 *)


signature TIMEOUT =
sig
  exception Timeout

  (* Run a function with a timeout. *)
  val runWithTimeout : Time.time -> ('a -> 'b) -> 'a -> 'b option

  (* Run a function with a timeout, raising Timeout if it triggers *)
  val runWithTimeoutExn : Time.time -> ('a -> 'b) -> 'a -> 'b

end

structure Timeout :> TIMEOUT =
struct
  exception Timeout

  fun finally f final =
      f () before ignore (final ())
      handle e => (final (); raise e)

  fun runWithTimeout t f x =
      let val timer = SMLofNJ.IntervalTimer.setIntTimer
	  fun cleanup () =
	      (timer NONE;
	       Signals.setHandler (Signals.sigALRM, Signals.IGNORE); ())

	  val ret = ref NONE
	  fun doit k =
	      let fun handler _ = k
		  val _ = Signals.setHandler (Signals.sigALRM,
					      Signals.HANDLER handler)
		  val () = timer (SOME t)
	      in ret := SOME (f x) end
	  val () = finally (fn () => SMLofNJ.Cont.callcc doit) cleanup
      in !ret end

  fun runWithTimeoutExn t f x =
      case runWithTimeout t f x
	   of SOME x => x
	    | NONE => raise Timeout
end
