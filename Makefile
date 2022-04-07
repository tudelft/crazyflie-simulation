all: python_controller
.PHONY: all

python_controller: controllers/pid_controller.i
	cd controllers && swig -python pid_controller.i && python3 setup.py build_ext --inplace
.PHONY: python_controller
