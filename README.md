# numba-dev-files

My personal development files for Numba.

## Files

* `Makefile` — targets for building Numba (`build`, `dbgbuild`,
  `conda-build`), installing dependencies (`deps`, `doc-deps`), creating
  per-Python conda environments (`n38`…`n313`), cleaning (`clean`) and
  running the test suite (`test`, `POST`, `test-individual`). Symlink it
  into a Numba source checkout.
* `conda_search_all.sh` — search a conda package spec across all
  supported architectures by iterating `CONDA_SUBDIR` over linux-64,
  osx-64, osx-arm64, win-64, linux-aarch64, linux-ppc64le and more.
* `.numba_config.yaml` — Numba runtime configuration: `dark_bg` color
  scheme, all debug/dump options disabled.
* `numba-review-agent.md` — instructions for AI agents reviewing
  Numba/llvmlite pull-requests: conda environment and git worktree
  conventions, read-only `gh` access to GitHub, testing procedure and
  the review output format.
* `LICENSE.txt` — WTFPL, version 2.
