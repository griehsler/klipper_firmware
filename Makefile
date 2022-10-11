.PHONY: clear build_rpi flash_rpi build_skr flash_skr build_ercf flash_ercf stop all power_on

KLIPPER_DIR=~/klipper
KLIPPER_MAKE=make -C ${KLIPPER_DIR}
KLIPPER_CONFIG=${KLIPPER_DIR}/.config
SCRIPTS_DIR=~/scripts

power_on:
	${SCRIPTS_DIR}/psu_on.sh

clean:
	${KLIPPER_MAKE} clean

build_rpi: clean
	cp rpi.config ${KLIPPER_CONFIG}
	${KLIPPER_MAKE}

flash_rpi: build_rpi stop
	sudo ${KLIPPER_MAKE} flash

build_skr: clean
	cp skr_1.4.config ${KLIPPER_CONFIG}
	${KLIPPER_MAKE}

flash_skr: build_skr stop
	${KLIPPER_DIR}/scripts/flash-sdcard.sh /dev/serial/by-id/usb-Klipper_lpc1768_16C0FF13820C25AE36111C52851E00F5-if00 btt-skr-v1.4
	${KLIPPER_DIR}/scripts/flash-sdcard.sh /dev/serial/by-id/usb-Klipper_lpc1768_17140F0F5B1652532260C54C050000F5-if00 btt-skr-v1.4

build_ercf: clean
	cp ercf.config ${KLIPPER_CONFIG}
	${KLIPPER_MAKE}

flash_ercf: build_ercf stop
	@read -p "Please short ERCF reset pads twice. Press any key when done..." result
	sudo /usr/local/bin/bossac -i -d -p /dev/serial/by-id/usb-Seeed_Studio_Seeeduino_XIAO_83FEDA1550553439392E3120FF0F2141-if00 -e -w -v -R --offset=0x2000 ${KLIPPER_DIR}/out/klipper.bin

stop:
	service klipper stop

all: flash_rpi flash_skr #flash_ercf
	service klipper start
