from __future__ import annotations
import sys
from pathlib import Path
import mido


def summarize(path: Path):
    mid = mido.MidiFile(path)
    tracks = []
    for i, tr in enumerate(mid.tracks):
        abs_time = 0
        programs = []
        bank_msb = []
        notes = 0
        for msg in tr:
            abs_time += msg.time
            if msg.type == 'program_change':
                programs.append((abs_time, msg.program))
            elif msg.type == 'control_change' and msg.control == 0:
                bank_msb.append((abs_time, msg.value))
            elif msg.type == 'note_on' and msg.velocity > 0:
                notes += 1
        tracks.append({
            'index': i,
            'name': tr.name,
            'program_changes': programs,
            'bank_msb': bank_msb,
            'note_on_count': notes,
        })
    return tracks


def dump(label: str, tracks):
    print(f'## {label}')
    for tr in tracks:
        print(f"TRACK {tr['index']:02d} | name={tr['name']!r} | notes={tr['note_on_count']} | pc={len(tr['program_changes'])} | bank0={len(tr['bank_msb'])}")
        if tr['bank_msb']:
            print('  bank_msb:', tr['bank_msb'][:16])
        if tr['program_changes']:
            print('  programs:', tr['program_changes'][:32])
    print()


def main():
    if len(sys.argv) != 4:
        raise SystemExit('usage: compare_midis.py GENERATED FIXED_FFT118 FIXED_PC0')
    generated = summarize(Path(sys.argv[1]))
    fixed_fft = summarize(Path(sys.argv[2]))
    fixed_pc0 = summarize(Path(sys.argv[3]))
    dump('GENERATED', generated)
    dump('FIXED_FFT118', fixed_fft)
    dump('FIXED_PC0', fixed_pc0)


if __name__ == '__main__':
    main()
