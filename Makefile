# This is esc's (https://github.com/esc) makefile for building Numba.
#
# Copyleft 2020 esc under WTFPL (https://en.wikipedia.org/wiki/WTFPL)
#
# About: This makefile has a set of simple targets for setting up development
# environments and compiling numba in various different ways. Look at the
# comments of each target to find out more.
#
# Your best bet is to symlink the makefile into your git source checkout of
# numba by using e.g. `ln -s <PATH-TO-THIS-MAKEFILE> makefile`. If you are
# using zsh, I recommend to setup `make` completion. Then, typing `make <TAB>`
# on the command line will offer all the targets from this makefile for
# completion, very handy when needing to setup and handle multiple
# environments.

.PHONY: build clean test
.DEFAULT: build

# Default build using pip. This is the recommend way. `-e` is for `--editable`
# and ensures any changes you make to the source checkout will become
# available. The effect is: you do not need to run `install` after every
# change. `-vv` is for double-verbose, all compiler messages will appear on the
# screen, so you can glance at what is being done. With enough experience you
# will "see" what is going on from the shape of the compiler output.
build:
	python -m pip install -vv -e .

# Build using `setup.py` -- an older and now discouraged way to build Numba.
# Still works sometimes though, especially on older Pythons.
build-setup.py:
	python setup.py build_ext -i && python setup.py develop --no-deps

# This will build a debug build, that is to say, debug symbols will be included
# via `--debug` and and there will be no optimization as per `--noopt`. The
# effect is that Numba is now easier to use in a deubgger like gdb, because the
# debug symbols have been included and nothing has been optimized away.
# Effectively inspecting Numba at runtime in gdb doesn't just yield meaningless
# messages about information being not included (debug symbols) or having been
# optimized way (no optimization). If you need to debug Numba using gdb, you
# WILL need this.
dbgbuild:
	python -m pip install --global-option build --global-option --debug --global-option --noopt -vv -e .

# Like dbgbuild, but using setup.py.
dbgbuild-setup.py:
	python setup.py build_ext -i --debug --noopt && python setup.py develop --no-deps

# Build using the tool `conda build`. This is how packages are compiled for
# distribution via the Numba channel at anaconda.org
# (https://anaconda.org/numba/). Adjust your Python accordingly.
conda-build:
	conda build ${EXTRA_CHANNELS} --no-test --python=3.11 --numpy=1.22 buildscripts/condarecipe.local

# Install dependencies.
deps:
	conda install  -c numba/label/dev llvmlite
	conda install numpy pyyaml colorama scipy jinja2 cffi ipython flake8
	if [ "$(shell uname -m)" = "arm64" ] ; then conda install clang_osx-arm64 clangxx_osx-arm64 ; fi
	if [ "$(shell uname)" = "Darwin" ] ; then conda install clang_osx-64 clangxx_osx-64 ; fi
	if [ "$(shell uname)" = "Linux" && "$(shell uname -i)" = "x86_64" ] ; then conda install gcc_linux-64 gxx_linux-64 ; fi
	if [ "$(shell uname)" = "Linux" && "$(shell uname -i)" = "ppc64le" ] ; then conda install gcc_linux-ppc64le gxx_linux-ppc64le ; fi
	conda install -c conda-forge ipdb
	pip install pre-commit git-spindle
	# conda install llvm-openmp intel-openmp

# Install dependencies for building the Numba documentation.
doc-deps:
	conda install sphinx pygments numpydoc sphinx_rtd_theme

# Create a conda environment with the correct Python.
n38:
	conda create -n numba_3.8 python=3.8

n39:
	conda create -n numba_3.9 python=3.9

n310:
	conda create -n numba_3.10 python=3.10

n311:
	conda create -n numba_3.11 python=3.11

n312:
	conda create -n numba_3.12 python=3.12

# Create an environment based on conda-forge. Adjust Python accordingly.
cfn:
	conda create -n cf_numba_3.9 -c conda-forge python=3.9 gdb

# Perform a `git clean` to obtain a pristine working directory w/o any build
# files. If you are unsure if this would delete things you still need, throw in
# a `-n` to perform a `--dry-run`.
clean:
	git clean -dfX

# Run Numba test-suite on 12 cores
test:
	python -m numba.runtests -m 12

# POST - Power On Self Test -- a sanity check
POST:
	python -m numba.misc.POST

# Run each test on it's own.
test-individual:
	for x in "$(shell ./runtests.py -l|grep ^numba)"; do ./runtests.py "$x"; done ;
