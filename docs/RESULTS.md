# AHB16 response-contract results — 7 November 2026

Tested source commit: `3a0262b5e871a15d86ba532273b244672294bd0a`.
ModelSim Intel FPGA Starter Edition `vsim 2020.1 Simulator 2020.02
Feb 28 2020`. Deterministic xorshift32 seed `0x28A81607`.

The [independent model](../tb/ahb16_contract_test.sv) passed **810** pin
comparisons, **122** accepted address phases, **119** retired phases,
**40** write commits, **12** invalid transfers and **8** external stall
edges. It covers every word, distinct read/write/overwrite patterns,
full-rate address/data pairing, selected NONSEQ/SEQ, guards, all eight
`HSIZE` codes, misalignment and range errors, two-cycle ERROR and cancelled
speculative address, recovery, and reset in idle/pending write/both ERROR
phases. Counts are different kinds of observations, not coverage percentages.
The original legacy bench and its historical 18 checks were preserved; its
one-cycle ERROR assumption is superseded for the corrected RTL.

The [raw passing log and JSON](../reports/technical-completion-2026-11-07/)
record source hashes, actual command, zero compile errors/warnings, exact
PASS marker, `$finish`, simulator version and wrapper exit 0. Each command
has a 120-second external timeout; the bench also has a simulation watchdog.

Two disposable controls failed as expected, both with wrapper exit **1**:

| Fault | Exact detection |
| --- | --- |
| Baseline one-cycle ERROR RTL | `AHB16_MISMATCH` at first ERROR phase: expected `HREADYOUT=0`, observed `1` |
| Write through live `HADDR` instead of saved index | `AHB16_MISMATCH` on independent readback |

Their mutant source, source hash, raw logs, JSON and fault summary are in
the separate `fault-*` report directories. The tested branch contains neither
mutant. ModelSim can return process exit 0 on a simulator `$fatal`; the
wrapper rejects the fatal transcript and missing marker.

The [measured SVG](../reports/technical-completion-2026-11-07/ahb16-contract.svg)
was rendered from the [actual VCD](../reports/technical-completion-2026-11-07/ahb16-contract.vcd).
The adjacent JSON records its VCD SHA-256, top, time unit and selected pins.
The SVG renderer does not assess functional PASS.

Reproduce from a clean checkout at the tested source with a fresh directory:

```powershell
$env:MODELSIM_BIN = 'C:\intelFPGA\20.1\modelsim_ase\win32aloem'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/run_regression.ps1 -OutputDir C:\short\ahb16-run-unique -CaptureWave
if ($LASTEXITCODE -ne 0) { throw 'AHB16 regression failed or blocked' }
```

The installed Starter simulator did not qualify licensed UVM, covergroups
or SVA. No full burst/interconnect compliance, coverage closure, synthesis,
timing, FPGA or hardware result is claimed. The original advanced ALU/APB
environments are separate optional NOT RUN suites.
