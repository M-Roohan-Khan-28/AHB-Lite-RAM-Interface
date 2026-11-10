# Deterministic AHB-Lite UVM/SVA adapter

The reusable environment is in AMBA-Protocol-Verification at tested merged source
`e58c30428d2a6348d3983c8ee3fbf9e1905629d2`. This adapter documents the unchanged DUT lock
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
## Merged-source closeout - 10 November 2026

[AMBA #14](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/pull/14) merged at `e58c30428d2a6348d3983c8ee3fbf9e1905629d2`;
[AHB documentation #3](https://github.com/M-Roohan-Khan-28/AHB-Lite-RAM-Interface/pull/3) merged at `66b37e1b21506c46ce7e1e68e582ffdc716a2c57`.
The [new immutable evidence](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/SUMMARY.md), published through
[AMBA evidence PR](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/pull/15) at `b41b309ec887c58c7187c96de4452741c9bee115`,
records **44/44 named required PASS**, aggregate and actual outer wrapper exit 0.
The fresh GitHub clone explicitly detached at the tested AMBA merge above;
all 23 execution-input hashes match qualified implementation `3eb0e520a880b2cfb13d304bbeea119dbe917fb3`.
Runner last change remains `3eb0e520a880b2cfb13d304bbeea119dbe917fb3` and inventory last change
`33f33d6034165085833d5f16390f6a625d15a2bc`. The DUT remains locked to `659fba67ce85a01643cceca2c8d1e67ea3903995`
despite these documentation merges. The abnormal-process-exit defect is resolved.

The execution passed 48 synthetic record-fixture checks, 23 SVA controls,
six scoreboard controls, two functional groups containing 45 HDL scenarios /
10,497 comparisons, all 11 fault parents and the portable 924-comparison gate.
Every real fault child exits 1 with its exact intended diagnostic; its three
vlib/vlog/vsim commands each exit 0 without timeout. The six abnormal-exit SVA
fixtures are accepted by the historical guard and rejected by the corrected
guard; these fixtures are not induced simulator crashes.
All case results match the qualified corrective run and reconcile:

```text
1896 offered = 1879 accepted + 16 withdrawn + 1 reset-unaccepted
1879 accepted = 1858 successful + 17 errors + 4 reset-accepted
1858 successful = 766 writes + 1092 reads
```

The portable gate separately passed 924 comparisons, three malformed-master
detections and one legal hold. [Raw results](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/run/results.json),
[wrapper exit and executed command](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/run/wrapper.json),
[source/input locks](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/SOURCE_LOCKS.json) and
[capture byte audit](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/BYTE_AUDIT.json) belong to this new merged execution.
The earlier corrective report and original measured figures linked above retain
their original identities. No historical capture is relabelled as a new figure.
[Exact reproduction instructions](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/REPRODUCE.md) use unused short paths,
a normal Git clone and an explicit detached checkout.

```powershell
$python = 'C:\Users\CG\AppData\Local\Python\pythoncore-3.14-64\python.exe'
git clone --config core.longpaths=true --config core.autocrlf=false https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification.git C:\short\ahb-merged-source-new
git -C C:\short\ahb-merged-source-new checkout --detach e58c30428d2a6348d3983c8ee3fbf9e1905629d2
& $python C:\short\ahb-merged-source-new\scripts\run_ahb_uvm.py --expected-env-sha e58c30428d2a6348d3983c8ee3fbf9e1905629d2 --output C:\short\ahb-merged-results-new
if ($LASTEXITCODE -ne 0) { throw 'Required AHB milestone failed or was blocked' }
```

The qualified configuration is Questa Altera Starter FPGA Edition 2025.2 with
bundled `QUESTA_UVM-1.2.3`; all sessions run serially. The portable substep uses
ModelSim Intel FPGA Starter Edition 2020.1. See the AMBA report for logs, input
hashes, measured VCD-derived figures and byte provenance. Use fresh output paths.

Functional coverage, constrained randomization and original advanced ALU/APB are
NOT RUN. Full AHB compliance, bursts/interconnect, new sizes, coverage closure,
synthesis, timing, FPGA and hardware remain separate milestones.
