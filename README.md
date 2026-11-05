# AHB-Lite RAM Interface and Directed Verification

**SystemVerilog · 16-word RAM · Registered address and control**

A 16-word, 32-bit RAM interface that captures address and transfer-control information before processing the corresponding data phase. The implementation accepts aligned word transfers and includes a directed simulation testbench.

`HREADYOUT` remains high, including during error conditions. The implemented response behaviour is documented as a bounded model; complete AHB-Lite protocol compliance has not been established.

See [original source documentation](SOURCE_README.md) for the baseline files and the verification-status section below for the retained simulation evidence.

## Run

From the repository root, with the required ModelSim/Questa executables and appropriate licence available:

```bash
bash sim/run.sh
```

Existing Windows instructions, where supplied, are retained in `scripts/`. Do not assume the testbench will run in every edition of a simulator. Check [the retained validation report](source-docs/VALIDATION.md) and the original README.

## Verification status

The included logs are historical evidence copied from the source repository. **The extracted copy has not been simulated by this extraction script.** Re-run before reporting fresh results. Some original exercises were blocked by verification-feature licence restrictions; those restrictions are not changed by packaging.

## Provenance and changes

Source commit: `df8d6f66898a08df75cd2071ddac7bbba9ba9b16`. Source path: `projects/ahb-lite-ram`.

[SOURCE_PROVENANCE.json](SOURCE_PROVENANCE.json) records checksums of every original file. `SOURCE_README.md` is the unchanged original README. No RTL or testbench functionality was changed during extraction. Source history remains available in the original repository; this is a snapshot, not a rewrite of its authorship.

## Next engineering work

Planned work focuses on checking address/data phasing, HREADY stalls, transfer-size and alignment handling, and error-response behaviour against the selected AHB-Lite specification before extending compliance claims.
