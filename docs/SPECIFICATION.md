# Bounded 16-word AHB-Lite RAM contract

The endpoint has 16 32-bit words at aligned byte addresses `00`–`3C`.
Selected NONSEQ/SEQ (`HTRANS[1]`) address phases are accepted only when
global `HREADY` is high. The corresponding write data is retired in the
following data phase using the saved index; `HREADY=0` holds normal pipeline
state and prevents a write commit. Unselected/IDLE/BUSY phases are ignored.
The implemented size is word (`HSIZE=010`). Misalignment, out-of-range
addresses, and other sizes return an ERROR and cannot update RAM. Invalid
and unselected reads return zero. Active-low asynchronous reset clears RAM
and pending response state.

The baseline source had a single ready ERROR cycle. The new response FSM
produces `HRESP=1,HREADYOUT=0` in the first ERROR cycle and
`HRESP=1,HREADYOUT=1` in the second. The inserted wait advances independently
of global `HREADY`; the completion phase waits for global `HREADY` before
retiring. A speculative following address held during the first phase is
ignored and may be cancelled before completion. Successful operations retain
zero local wait cycles.

The verification-only master monitor requires address/control and write data to
remain stable across externally imposed global HREADY waits. It permits the
specified cancellation at the first-to-second ERROR phase and is qualified
against three reset-isolated malformed-master cases. A reset cancels a pending
externally stalled write.

This endpoint has no `HBURST` port or full interconnect. The tests establish
the bounded behavior above, not complete AHB-Lite compliance. Historical
source, attribution, provenance and prior one-cycle-error evidence remain in
Git history and their original report paths.
