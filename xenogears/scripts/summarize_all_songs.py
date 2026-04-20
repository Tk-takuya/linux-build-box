from __future__ import annotations
import csv
import json
import sys
from pathlib import Path
import mido
import struct

def parse_sf2_banks(sf2_path: Path) -> dict[int, int]:
    data = sf2_path.read_bytes()
    phdr_off = data.find(b'phdr')
    if phdr_off < 0:
        return {}
    size = struct.unpack_from('<I', data, phdr_off + 4)[0]
    chunk = data[phdr_off + 8: phdr_off + 8 + size]
    rec_size = 38
    out: dict[int, int] = {}
    for i in range(0, len(chunk), rec_size):
        rec = chunk[i:i+rec_size]
        if len(rec) < rec_size:
            break
        name = rec[:20].split(b'\x00', 1)[0].decode('ascii', 'ignore')
        preset, bank = struct.unpack_from('<HH', rec, 20)
        if name == 'EOP':
            continue
        out[bank] = out.get(bank, 0) + 1
    return dict(sorted(out.items()))

def summarize_midi(mid_path: Path):
    mid = mido.MidiFile(mid_path)
    tracks = len(mid.tracks)
    note_on = 0
    program_changes = 0
    bank_msb = 0
    for tr in mid.tracks:
        for msg in tr:
            if msg.type == 'note_on' and getattr(msg, 'velocity', 0) > 0:
                note_on += 1
            elif msg.type == 'program_change':
                program_changes += 1
            elif msg.type == 'control_change' and msg.control == 0:
                bank_msb += 1
    return tracks, note_on, program_changes, bank_msb

def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: summarize_all_songs.py RESULTS_DIR OUT_DIR")
    results_dir = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    rows = []
    for d in sorted(p for p in results_dir.iterdir() if p.is_dir()):
        shell_log = d / "shell.log"
        cmds = d / "cmds.txt"
        psf = ""
        if cmds.exists():
            for line in cmds.read_text(encoding="utf-8", errors="ignore").splitlines():
                if line.startswith('load "'):
                    psf = line[6:-1]
                    break
        psf_name = Path(psf).name if psf else ""
        mids = sorted(d.glob("*.mid"))
        sf2s = sorted(d.glob("*.sf2"))
        collections = []
        if shell_log.exists():
            for line in shell_log.read_text(encoding="utf-8", errors="ignore").splitlines():
                if line.startswith("[#"):
                    collections.append(line.strip())
        row = {
            "index": d.name,
            "psf": psf_name,
            "collections": collections,
            "mid_count": len(mids),
            "sf2_count": len(sf2s),
            "mid_name": mids[0].name if mids else "",
            "sf2_name": sf2s[0].name if sf2s else "",
            "tracks": "",
            "note_on": "",
            "program_changes": "",
            "bank_msb": "",
            "sf2_banks": {},
        }
        if mids:
            tracks, note_on, pcs, bank = summarize_midi(mids[0])
            row["tracks"] = tracks
            row["note_on"] = note_on
            row["program_changes"] = pcs
            row["bank_msb"] = bank
        if sf2s:
            row["sf2_banks"] = parse_sf2_banks(sf2s[0])
        rows.append(row)

    (out_dir / "batch_results.json").write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8")
    with (out_dir / "batch_results.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["index","psf","mid_count","sf2_count","mid_name","sf2_name","tracks","note_on","program_changes","bank_msb","sf2_banks","collections"])
        for r in rows:
            w.writerow([
                r["index"], r["psf"], r["mid_count"], r["sf2_count"], r["mid_name"], r["sf2_name"],
                r["tracks"], r["note_on"], r["program_changes"], r["bank_msb"],
                json.dumps(r["sf2_banks"], ensure_ascii=False),
                " | ".join(r["collections"]),
            ])

    total = len(rows)
    ok = sum(1 for r in rows if r["mid_count"] == 1 and r["sf2_count"] == 1)
    no_collection = [r["psf"] for r in rows if r["mid_count"] == 0 and r["sf2_count"] == 0]
    multi_bank = [r["psf"] for r in rows if len(r["sf2_banks"]) > 1]
    summary = [
        "[Xenogears all songs summary]",
        f"analysed={total}",
        f"ok_mid_sf2={ok}",
        f"no_output={len(no_collection)}",
        f"multi_bank={len(multi_bank)}",
        "",
        "no_output_titles:",
        *[f"- {x}" for x in no_collection],
        "",
        "multi_bank_titles:",
        *[f"- {x}" for x in multi_bank],
    ]
    (out_dir / "batch_summary.txt").write_text("\n".join(summary), encoding="utf-8")

if __name__ == "__main__":
    main()
