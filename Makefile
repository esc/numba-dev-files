.PHONY: build clean test
.DEFAULT: build

build:
	python setup.py build_ext -i && python setup.py develop

deps:
	conda install  -c numba/label/dev llvmlite
	conda install numpy pyyaml colorama scipy jinja2 cffi ipython
	conda install clang_osx-64 clangxx_osx-64
	pip install pre-commit git-spindle
	# conda install llvm-openmp intel-openmp

n37:
	conda create -n numba_3.7 python=3.7

clean:
	git clean -dfX

test:
	python -m numba.runtests -m 12
