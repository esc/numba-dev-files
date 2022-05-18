.PHONY: build clean test
.DEFAULT: build

build:
	python setup.py build_ext -i && python setup.py develop --no-deps

dbgbuild:
	python setup.py build_ext -i --debug --noopt && python setup.py develop --no-deps

conda-build:
	conda build ${EXTRA_CHANNELS} --no-test --python=3.9 --numpy=1.16 buildscripts/condarecipe.local

deps:
	conda install  -c numba/label/dev llvmlite
	conda install numpy pyyaml colorama scipy jinja2 cffi ipython flake8
	if [ "$(shell uname)" = "Darwin" ] ; then conda install clang_osx-64 clangxx_osx-64 ; fi
	if [ "$(shell uname)" = "Linux" ] ; then conda install gcc_linux-64 gxx_linux-64 ; fi
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

n36:
	conda create -n numba_3.6 python=3.6

clean:
	git clean -dfX

test:
	python -m numba.runtests -m 12

test-individual:
	for x in "$(shell ./runtests.py -l|grep ^numba)"; do ./runtests.py "$x"; done ;
