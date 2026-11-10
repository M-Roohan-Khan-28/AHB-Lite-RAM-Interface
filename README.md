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

## Separate deterministic UVM/SVA milestone

The [AMBA-hosted adapter and exact run procedure](docs/DETERMINISTIC_AHB_UVM.md)
qualify the unchanged RTL with 45 functional scenarios / 10,497 comparisons,
23 SVA controls, six scoreboard controls and 11 expected fault failures. The
44 required substeps add 48 runner-fixture qualification checks and retain the
separate existing 924-comparison portable gate.
Coverage, randomization and original advanced ALU/APB remain NOT RUN. This bounded
milestone does not establish full AHB compliance or physical implementation.
