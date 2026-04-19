Manual push package for Tk-takuya/linux-build-box

Put these paths into the repository as-is:
- .github/workflows/xenogears_fft118_build.yml
- xenogears/patches/0001-FFTSeq.h.patch
- xenogears/patches/0002-FFTSeq.cpp.patch
- xenogears/patches/0003-FFTInstr.cpp.patch
- xenogears/scripts/run_118_export.sh
- xenogears/scripts/compare_midis.py
- xenogears/inputs/118 Invasion.PSF
- xenogears/inputs/shinnyu_fft118_fixed.mid
- xenogears/inputs/shinnyu_fixed_pc0.mid

After commit+push, the workflow name is:
Xenogears FFT118 Build

Expected artifact:
- xenogears-fft118-build
  contains out/shinnyu.mid, out/shinnyu.sf2, midi_compare_summary.txt, and vgmtrans-shell
