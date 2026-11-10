# Deterministic AHB-Lite UVM/SVA adapter

The reusable environment is in AMBA-Protocol-Verification at tested source
`d403d88a71e7c55a46641366007ebd0af9e444a4`. This adapter documents the unchanged DUT lock
`659fba67ce85a01643cceca2c8d1e67ea3903995` and retains existing `LICENSE_STATUS.md`, attribution,
notices and history. No new licence is assigned.

The [public-pin adapter](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/d403d88a71e7c55a46641366007ebd0af9e444a4/verification/ahb_uvm/ahb_uvm_top.sv) connects every
DUT port directly to `ahb_bus`; `HREADY=external_ready && HREADYOUT`. External
waits cannot override the local ERROR wait. The passive monitor samples before
the clock edge using a clocking-block `#1step` input. The scoreboard retires the
saved data owner before accepting the next address on the same edge. Request
intentions and expected RAM do not derive from observed addresses or DUT internals.

The focused `ignored_unselected` scenario demonstrates that a pending selected
read still returns its data when live HSEL=0 describes the next address phase.
The specification wording is clarified accordingly; RTL is unchanged.

The [immutable report](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/faf8291b5d7b40362f30c79f12ed49453158dfc4/reports/ahb-uvm-2026-11-10/SUMMARY.md) and [AMBA review PR](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/pull/14)
records 43/43 required PASS, 45 scenarios / 10,497 comparisons, 23 SVA controls,
six scoreboard controls and 11 nonzero fault children. Its portable gate separately
reproduced 924 pin comparisons plus three malformed-master controls and one legal
hold. The historical portable result is not relabelled as UVM coverage.

```powershell
$python = 'C:\Users\CG\AppData\Local\Python\pythoncore-3.14-64\python.exe'
git clone --config core.longpaths=true --config core.autocrlf=false https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification.git C:\short\ahb-uvm-reproduce-new
git -C C:\short\ahb-uvm-reproduce-new checkout --detach d403d88a71e7c55a46641366007ebd0af9e444a4
& $python C:\short\ahb-uvm-reproduce-new\scripts\run_ahb_uvm.py --expected-env-sha d403d88a71e7c55a46641366007ebd0af9e444a4 --output C:\short\ahb-uvm-run-new
if ($LASTEXITCODE -ne 0) { throw 'Required AHB milestone failed or was blocked' }
```

The qualified configuration is Questa Altera Starter FPGA Edition 2025.2 with
bundled `QUESTA_UVM-1.2.3`; all sessions run serially. The portable substep uses
ModelSim Intel FPGA Starter Edition 2020.1. See the AMBA report for logs, input
hashes, measured VCD-derived figures and byte provenance. Use fresh output paths.

Functional coverage, constrained randomization and original advanced ALU/APB are
NOT RUN. Full AHB compliance, bursts/interconnect, new sizes, coverage closure,
synthesis, timing, FPGA and hardware remain separate milestones.
