# Verification notes

The supplied testbench is [tb_ahb_lite_slave_ram](../tb/tb_top.sv). Start with its existing stimulus and checks, then review reset, normal operations, boundaries, and invalid inputs against the actual RTL interface.

Packaging has preserved the original testbench. There is no measured code-coverage report or new standalone assertion suite. Record failures as well as passes in the simulation log; inspect whether each check is automatic or requires waveform review before expanding the test plan.

## Corrected response contract

The new [specification](SPECIFICATION.md), [model](../tb/ahb16_contract_test.sv)
and [actual results](RESULTS.md) supersede the inherited bench's ERROR timing
assumption. The original source remains available in history.

| Requirement | Model or directed check | Result |
| --- | --- | --- |
| All 16 words and data-phase pairing | Independent reference array updated from accepted addresses and following HWDATA; readback of each word | 924 pin comparisons, 40 write commits |
| Pipeline and transfer controls | Full-rate W-W, W-R, R-W, R-R; NONSEQ/SEQ; unselected/IDLE/BUSY guards | Included in 139 accepted phases |
| Size, alignment, range | All eight HSIZE encodings and invalid addresses | 12 ERROR transfers, including two reset probes |
| Global-ready stalls | Hold address/data phases for 1, 2 and 5 cycles | 9 stall edges |
| Two-cycle ERROR | Compare both phases, cancel speculative next address, recover | Old RTL fault detected with wrapper exit 1 |
| Saved write index | Independent readback after pipeline | Live-address mutant detected with wrapper exit 1 |
| Reset | Idle, pending write, externally stalled write, first and second ERROR phases | Model and pin checks |
| Master wait stability | Passive checker on legal waits; reset-isolated address, write-data and HTRANS mutations | Three detected, one legal path, mutant wrapper exit 1 |

The runner requires an exact terminal marker, zero simulator errors and a
finite wall-clock bound. A passive master-side checker runs on legal traffic and three reset-isolated
malformed waits; reset during an externally stalled write is in the positive model.
These scenario counts are not functional/code coverage measurements.

