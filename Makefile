.PHONY: build clean test
.DEFAULT: build

build:
	python setup.py build_ext -i && python setup.py develop --no-deps

deps:
	conda install  -c numba/label/dev llvmlite
	conda install numpy pyyaml colorama scipy jinja2 cffi ipython 
	conda install clang_osx-64 clangxx_osx-64
	conda install -c conda-forge ipdb
	pip install pre-commit git-spindle
	# conda install llvm-openmp intel-openmp

n37:
	conda create -n numba_3.7 python=3.7

n38:
	conda create -n numba_3.8 python=3.8

clean:
	git clean -dfX

test:
	python -m numba.runtests -m 12
