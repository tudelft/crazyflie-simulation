SHELL := /bin/bash


all: .venv python_controller
.PHONY: all

run: python_controller .venv
	source .venv/bin/activate && webots
.PHONY: run


.venv: requirements.txt
	virtualenv -p python3 .venv
	source .venv/bin/activate && pip install -r requirements.txt
	touch .venv

python_controller: controllers/pid_controller.i
	cd controllers && swig -python pid_controller.i && python3 setup.py build_ext --inplace
.PHONY: python_controller
