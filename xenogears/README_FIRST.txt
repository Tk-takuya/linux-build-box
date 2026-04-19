Manual push package for Tk-takuya/linux-build-box (v4 refresh)

Replace these repository paths as-is:
- .github/workflows/xenogears_fft118_build.yml
- xenogears/patches/0001-FFTSeq-runtime-seed-bank-policy.patch
- xenogears/patches/0002-FFTColl-bank-remap.patch
- xenogears/patches/0003-FFTMatcher-extra-wds-banks.patch
- xenogears/patches/0004-FFTFormat-wire-custom-matcher-coll.patch
- xenogears/scripts/run_118_export.sh
- xenogears/scripts/compare_midis.py
- xenogears/inputs/118 Invasion.PSF
- xenogears/inputs/shinnyu_fft118_fixed.mid
- xenogears/inputs/shinnyu_fixed_pc0.mid
- xenogears/inputs/shinnyu_fft118_fixed.sf2

Workflow name:
- Xenogears FFT118 Build

Expected artifact:
- xenogears-fft118-build
  contains out/shinnyu.mid, out/shinnyu.sf2, shell_output, midi_compare_summary, metadata, and built vgmtrans-shell

Notes:
- checkout/upload-artifact updated to Node24-safe majors
- run_118_export.sh now drives the interactive shell via stdin commands
- output names are normalized back to shinnyu.mid/sf2 when export names differ
- v4 patch set is expected to be applied against clean upstream ce2b641e953589a7b30a40094a38ecdd3278580d
