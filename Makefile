.PHONY: clean build_rpi flash_rpi build_skr flash_skr flash_skr1 flash_skr2 build_ercf flash_ercf stop all power_on

KLIPPER_DIR=~/klipper
KLIPPER_MAKE=make -C ${KLIPPER_DIR}
KLIPPER_CONFIG=${KLIPPER_DIR}/.config
SCRIPTS_DIR=~/scripts

power_on:
	curl -X POST http://localhost/machine/device_power/on?printer >/dev/null

clean:
	${KLIPPER_MAKE} clean

build_rpi: clean
	cp rpi.config ${KLIPPER_CONFIG}
	${KLIPPER_MAKE}

flash_rpi: build_rpi stop
	${KLIPPER_MAKE} flash

build_skr: clean
	cp skr_1.4.config ${KLIPPER_CONFIG}
	${KLIPPER_MAKE}

flash_skr: flash_skr1 flash_skr2

flash_skr1: power_on stop build_skr
	${KLIPPER_DIR}/scripts/flash-sdcard.sh /dev/serial/by-id/usb-Klipper_lpc1768_16C0FF13820C25AE36111C52851E00F5-if00 btt-skr-v1.4

flash_skr2: power_on stop build_skr
	${KLIPPER_DIR}/scripts/flash-sdcard.sh /dev/serial/by-id/usb-Klipper_lpc1768_17140F0F5B1652532260C54C050000F5-if00 btt-skr-v1.4

build_ercf: clean
	cp ercf.config ${KLIPPER_CONFIG}
	${KLIPPER_MAKE}

flash_ercf: build_ercf stop
	@read -p "Please short ERCF reset pads twice. Press any key when done..." result
	/usr/local/bin/bossac -i -d -p /dev/serial/by-id/usb-Seeed_Studio_Seeeduino_XIAO_83FEDA1550553439392E3120FF0F2141-if00 -e -w -v -R --offset=0x2000 ${KLIPPER_DIR}/out/klipper.bin

stop:
	service klipper stop

all: flash_rpi flash_skr #flash_ercf
	service klipper start
