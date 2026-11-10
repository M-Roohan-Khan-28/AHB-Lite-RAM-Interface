# Deterministic AHB-Lite UVM/SVA adapter

The reusable environment is in AMBA-Protocol-Verification at tested source
`3eb0e520a880b2cfb13d304bbeea119dbe917fb3`. This adapter documents the unchanged DUT lock
`659fba67ce85a01643cceca2c8d1e67ea3903995` and retains existing `LICENSE_STATUS.md`, attribution,
notices and history. No new licence is assigned.

The [public-pin adapter](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/3eb0e520a880b2cfb13d304bbeea119dbe917fb3/verification/ahb_uvm/ahb_uvm_top.sv) connects every
DUT port directly to `ahb_bus`; `HREADY=external_ready && HREADYOUT`. External
waits cannot override the local ERROR wait. The passive monitor samples before
the clock edge using a clocking-block `#1step` input. The scoreboard retires the
saved data owner before accepting the next address on the same edge. Request
intentions and expected RAM do not derive from observed addresses or DUT internals.

The focused `ignored_unselected` scenario demonstrates that a pending selected
read still returns its data when live HSEL=0 describes the next address phase.
The specification wording is clarified accordingly; RTL is unchanged.

The [corrective report](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/e8eb02382c958a1297e2eb6811513b42336812b9/reports/ahb-runner-correction-2026-11-10/SUMMARY.md) records **44/44 required PASS**, wrapper exit 0.
The new required runner qualification executes 48 record-fixture checks, separately
from 45 HDL scenarios / 10,497 comparisons, 23 SVA controls, six scoreboard controls,
11 fault parents and the portable 924-comparison / three-negative / one-legal gate.
The common fault predicate requires tool exits 0 plus child-wrapper exit 1 and the
exact diagnostic. The historical qualifier accepted fabricated SVA process exits
211, 127 and -11; the corrected qualifier rejects them. These are runner fixtures,
not induced simulator crashes. Both real targeted SVA controls and all full-run
faults qualified with tool exits 0 and child-wrapper exits 1.
The [original report and measured captures](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/faf8291b5d7b40362f30c79f12ed49453158dfc4/reports/ahb-uvm-2026-11-10/SUMMARY.md) remain unchanged.
Both [AMBA PR #14](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/pull/14)
and this companion PR remain open and unmerged.

```powershell
$python = 'C:\Users\CG\AppData\Local\Python\pythoncore-3.14-64\python.exe'
git clone --config core.longpaths=true --config core.autocrlf=false https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification.git C:\short\ahb-corrected-source-new
git -C C:\short\ahb-corrected-source-new checkout --detach 3eb0e520a880b2cfb13d304bbeea119dbe917fb3
& $python C:\short\ahb-corrected-source-new\scripts\run_ahb_uvm.py --expected-env-sha 3eb0e520a880b2cfb13d304bbeea119dbe917fb3 --output C:\short\ahb-corrected-output-new
if ($LASTEXITCODE -ne 0) { throw 'Required AHB milestone failed or was blocked' }
```

The qualified configuration is Questa Altera Starter FPGA Edition 2025.2 with
bundled `QUESTA_UVM-1.2.3`; all sessions run serially. The portable substep uses
ModelSim Intel FPGA Starter Edition 2020.1. See the AMBA report for logs, input
hashes, measured VCD-derived figures and byte provenance. Use fresh output paths.

Functional coverage, constrained randomization and original advanced ALU/APB are
NOT RUN. Full AHB compliance, bursts/interconnect, new sizes, coverage closure,
synthesis, timing, FPGA and hardware remain separate milestones.
