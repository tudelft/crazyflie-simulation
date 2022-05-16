SHELL := /bin/bash

CF_FIRMWARE_TAG ?= 2022.05


all: .venv controllers/pid_controller.py crazyflie-firmware/cffirmware.py
.PHONY: all

run: all
	source .venv/bin/activate && webots webots/worlds/crazyflie_cyberzoo_world.wbt
.PHONY: run

clean:
	rm -r controllers/build || true
	rm controllers/_pid_controller* || true
	rm controllers/pid_controller_wrap.c || true
	rm controllers/pid_controller.py || true
.PHONY: clean

purge: clean
	rm -r .venv || true
	rm -rf crazyflie-firmware || true
.PHONY: purge

freeze:
	source .venv/bin/activate && pip freeze -l | grep -v "pkg_resources" > requirements.txt
.PHONY: freeze

###########################################################

.venv: requirements.txt
	virtualenv -p python3 .venv
	source .venv/bin/activate && pip install -r requirements.txt
	touch .venv

controllers/pid_controller.py: controllers/pid_controller.i controllers/pid_controller.c controllers/pid_controller.h controllers/setup.py
	cd controllers && swig -python pid_controller.i && python3 setup.py build_ext --inplace

crazyflie-firmware:
	git submodule update --init --recursive crazyflie-firmware

crazyflie-firmware/cffirmware.py: crazyflie-firmware
	cd crazyflie-firmware && git checkout $(CF_FIRMWARE_TAG)
	cd crazyflie-firmware && git submodule update --init
	$(MAKE) -C crazyflie-firmware cf2_defconfig bindings_python
	touch $@
