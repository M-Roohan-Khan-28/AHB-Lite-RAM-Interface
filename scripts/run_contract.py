#!/usr/bin/env python3
"""Fail-closed AHB16 regression with fresh work and an optional measured VCD."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


def tool(name):
    prefix = os.environ.get("MODELSIM_BIN")
    choices = ([str(Path(prefix) / (name + ".exe")), str(Path(prefix) / name)]
               if prefix else []) + [name, name + ".exe"]
    for candidate in choices:
        found = shutil.which(candidate)
        if found:
            return found
    raise RuntimeError("Missing simulator tool: " + name)


def invoke(args, cwd, logpath, timeout=120):
    try:
        result = subprocess.run(args, cwd=cwd, capture_output=True,
                                timeout=timeout, check=False)
    except subprocess.TimeoutExpired as exc:
        logpath.write_bytes((exc.stdout or b"") + (exc.stderr or b""))
        raise RuntimeError("Command timed out after %d seconds" % timeout) from exc
    data = result.stdout + result.stderr
    logpath.write_bytes(data)
    return result.returncode, data.decode("utf-8", errors="replace")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--output-dir", type=Path, required=True)
    ap.add_argument("--rtl", type=Path, help="disposable source override")
    ap.add_argument("--capture-wave", action="store_true")
    args = ap.parse_args()
    root = Path(__file__).resolve().parents[1]
    out = args.output_dir.resolve()
    if out.exists():
        raise RuntimeError("Output directory exists: " + str(out))
    out.mkdir(parents=True)
    rtl = (args.rtl or root / "rtl/design.sv").resolve()
    bench = root / "tb/ahb16_contract_test.sv"
    source = [rtl, bench]
    report = {
        "repository": "AHB-Lite-RAM-Interface",
        "source_revision": subprocess.check_output(
            ["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip(),
        "source_dirty": bool(subprocess.check_output(
            ["git", "-C", str(root), "status", "--porcelain"])),
        "sources": [{"path": str(p), "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
                    for p in source],
        "seed": "0x28A81607 xorshift32", "timeout_seconds_per_command": 120,
        "simulations": [], "overall": "FAIL"
    }
    started = time.monotonic()
    try:
        vlib, vlog, vsim = (tool(n) for n in ("vlib", "vlog", "vsim"))
        report["simulator_version"] = invoke([vsim, "-version"], out,
                                              out / "version.log")[1].strip()
        if invoke([vlib, "work"], out, out / "library.log")[0]:
            raise RuntimeError("vlib failed")
        code, log = invoke([vlog, "-sv", *map(str, source)], out,
                           out / "compile.log")
        if code or "Errors: 0, Warnings: 0" not in log:
            raise RuntimeError("vlog failed or reported diagnostics")
        do = "run -all; quit -code 0"
        if args.capture_wave:
            pins = "HCLK HRESETn HSEL HADDR HTRANS HWRITE HSIZE HWDATA HREADY HRDATA HREADYOUT HRESP".split()
            do = ("vcd file ahb16-contract.vcd; " + "; ".join(
                  "vcd add /ahb16_contract_test/" + pin for pin in pins) + "; " + do)
        command = [vsim, "-c", "-onfinish", "exit", "ahb16_contract_test", "-do", do]
        code, log = invoke(command, out, out / "simulation.log")
        entry = {"top": "ahb16_contract_test", "command": command,
                 "simulator_exit_code": code, "status": "FAIL"}
        report["simulations"].append(entry)
        marker = ("AHB16_CONTRACT_PASS checks=810 accepted=122 retired=119 "
                  "commits=40 errors=12 stalls=8 seed=0x28A81607")
        if (code or re.search(r"\*\*\s+(?:Error|Fatal):", log) or
                "# Errors: 0, Warnings: 0" not in log or "$finish" not in log or
                len(re.findall(re.escape(marker), log)) != 1):
            raise RuntimeError("AHB16 contract failed or exact marker missing")
        entry["status"] = "PASS"
        entry["marker"] = marker
        if args.capture_wave:
            vcd = out / "ahb16-contract.vcd"
            if not vcd.is_file() or not vcd.stat().st_size:
                raise RuntimeError("Requested VCD missing")
            report["waveform"] = {"path": str(vcd),
                                  "sha256": hashlib.sha256(vcd.read_bytes()).hexdigest()}
            signals = ["ahb16_contract_test." + p for p in
                       "HCLK HRESETn HSEL HADDR HTRANS HWRITE HSIZE HWDATA HREADY HRDATA* HREADYOUT HRESP".split()]
            renderer = root / "tools/vcd_to_svg.py"
            render = [sys.executable, str(renderer), "--vcd", str(vcd),
                      "--signals", *signals, "--output", str(out / "ahb16-contract.svg"),
                      "--origin", "simulator", "--title", "Measured AHB16 transaction phases"]
            if invoke(render, out, out / "render.log")[0]:
                raise RuntimeError("VCD render failed")
        report["overall"] = "PASS"
        print("PASS " + marker)
    except Exception as exc:
        report["error"] = str(exc)
        print("FAIL: " + str(exc), file=sys.stderr)
    finally:
        report["elapsed_seconds"] = round(time.monotonic() - started, 3)
        (out / "results.json").write_text(json.dumps(report, indent=2) + "\n",
                                          encoding="utf-8")
    return 0 if report["overall"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
