# AHB-Lite RAM Interface and Directed Verification

**SystemVerilog · 16-word RAM · Registered address and control**

A 16-word, 32-bit RAM interface that captures address and transfer-control information before processing the corresponding data phase. The implementation accepts aligned word transfers and includes a directed simulation testbench.

The corrected endpoint gives a two-cycle ERROR response for unsupported
size, misalignment, or range: `HRESP=1,HREADYOUT=0` followed by
`HRESP=1,HREADYOUT=1`. The [bounded specification](docs/SPECIFICATION.md)
describes its word-only interface and its global-ready pipeline behavior.
Complete AHB-Lite protocol compliance has not been established.

At tested source commit `8d482a8da9c28d91d10beb51e826d884090b7372`,
the [new independent regression](docs/RESULTS.md) passed 924 pin comparisons
over 139 accepted addresses, including reset of an externally stalled write.
Three reset-isolated malformed-master waits were detected. Disposable old-response,
live-address and master-monitor faults each caused nonzero wrapper exits. Its raw
logs, JSON and [measured waveform](reports/technical-completion-2026-11-07/master-monitor/ahb16-contract.svg)
are separate from historical reports. The legacy bench retains its old
single-cycle response expectations and is historical, not the corrected
response oracle.

See [original source documentation](SOURCE_README.md) for the baseline files and the verification-status section below for the retained simulation evidence.

## Run

From the repository root, with ModelSim/Questa executables and Python 3:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/run_regression.ps1 -OutputDir C:\short\ahb16-run-unique -CaptureWave
```

Choose a new output directory for each run. The original `sim/run.sh` and
`scripts/run_sim.ps1` remain for the inherited bench and its historical
single-cycle response; use the new runner for corrected-RTL qualification.
Check [the retained validation report](source-docs/VALIDATION.md) and the
original README for the earlier baseline.

## Verification status

The original `reports/` logs are historical extraction evidence. The new
contract's executed results are under `reports/technical-completion-2026-11-07/`.
Verification-feature licence restrictions are unchanged.

## Provenance and changes

Source commit: `df8d6f66898a08df75cd2071ddac7bbba9ba9b16`. Source path: `projects/ahb-lite-ram`.

[SOURCE_PROVENANCE.json](SOURCE_PROVENANCE.json) records checksums of every original file. `SOURCE_README.md` is the unchanged original README. No RTL or testbench functionality was changed during extraction. Source history remains available in the original repository; this is a snapshot, not a rewrite of its authorship.

## Next engineering work

Planned work focuses on checking address/data phasing, HREADY stalls, transfer-size and alignment handling, and error-response behaviour against the selected AHB-Lite specification before extending compliance claims.

## Separate deterministic UVM/SVA milestone - merged

The [AMBA-hosted adapter guide](docs/DETERMINISTIC_AHB_UVM.md) links the
[merged-source closeout](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/SUMMARY.md): **44/44 required PASS**,
aggregate and actual outer wrapper exit 0, from tested AMBA merge
`e58c30428d2a6348d3983c8ee3fbf9e1905629d2`. The unchanged DUT lock is `659fba67ce85a01643cceca2c8d1e67ea3903995`.
Results: 48 runner-fixture checks; 45 HDL scenarios / 10,497 independent
comparisons; 23 SVA controls; six scoreboard controls; 11 fault parents; and
the separate portable 924-comparison / three-negative / one-legal gate.
Every real fault child exits 1 for its exact diagnostic while vlib/vlog/vsim
each finish with exit 0 and no timeout. The abnormal-process-exit qualifier
defect is resolved. Both reviewed milestone PRs are merged.
[Normal-clone reproduction](https://github.com/M-Roohan-Khan-28/AMBA-Protocol-Verification/blob/b41b309ec887c58c7187c96de4452741c9bee115/reports/ahb-uvm-merged-2026-11-10/REPRODUCE.md) selects the tested detached merge.
Historical reports and measured figures remain linked from the guide.
Functional coverage, constrained randomization and original advanced ALU/APB
remain **NOT RUN**. Full AHB compliance and physical implementation remain
separate milestones.
