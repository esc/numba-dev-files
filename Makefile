.PHONY: build clean test
.DEFAULT: build

build:
	python -m pip install -vv -e .

build-setup.py:
	python setup.py build_ext -i && python setup.py develop --no-deps

dbgbuild:
	python setup.py build_ext -i --debug --noopt && python setup.py develop --no-deps

conda-build:
	conda build ${EXTRA_CHANNELS} --no-test --python=3.11 --numpy=1.21 buildscripts/condarecipe.local

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

doc-deps:
	conda install sphinx pygments numpydoc sphinx_rtd_theme

n37:
	conda create -n numba_3.7 python=3.7

n38:
	conda create -n numba_3.8 python=3.8

n39:
	conda create -n numba_3.9 python=3.9

cfn39:
	conda create -n cf_numba_3.9 -c conda-forge python=3.9 gdb

n310:
	conda create -n numba_3.10 python=3.10

n311:
	conda create -n numba_3.11 python=3.11

n312:
	conda create -n numba_3.12 python=3.12

n36:
	conda create -n numba_3.6 python=3.6

clean:
	git clean -dfX

test:
	python -m numba.runtests -m 12

test-individual:
	for x in "$(shell ./runtests.py -l|grep ^numba)"; do ./runtests.py "$x"; done ;
