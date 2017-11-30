import csv
import spidev
import time
import tgat
import RPi.GPIO as GPIO

def spi_init():
    # Create SPI objects
    spi0 = spidev.SpiDev()
    spi1 = spidev.SpiDev()

    # Open up SPI buses on SPI0 that use CS0 and CS1 respectively
    spi0.open(0, 0)
    spi1.open(0, 1)

    # NeuroSky recommends 900kHz max, closest we can do is 488kHz and 976kHz--to high
    spi0.max_speed_hz = 488000
    spi1.max_speed_hz = 488000

    # NeuroSky : "The SPI master must be in SPI MODE0 (ie. clock polarity CPOL = 0 and clock phase CPHA =0)"
    spi0.mode = 0
    spi1.mode = 0

    # NeuroSky does not support 16-bit SPI :(
    spi0.bits_per_word = 8
    spi1.bits_per_word = 8

    return [spi0, spi1]

def csv_write_to_file(data = []):
    with open('test_file.csv', 'wb') as csvfile:
        test_file = csv.writer(csvfile)
        test_file.writerow(data)
    return

def gpio_init():
    # Pin Definitons:
    reset = 5 
    leadoff = 6

    # Pin Setup:
    GPIO.setmode(GPIO.BCM) # Broadcom pin-numbering scheme
    GPIO.setup(reset, GPIO.OUT) # LED pin set as output
    GPIO.setup(leadoff, GPIO.IN) # PWM pin set as output

    # Start by resetting the TGAT
    GPIO.output(reset, GPIO.LOW)
    time.sleep(3)
    GPIO.output(reset, GPIO.HIGH)
    time.sleep(1)
    return 


def BytesToHex(Bytes):
    return ''.join(["0x%02X " % x for x in Bytes]).strip()

def byte_to_16word(data = []):
    # Swap out the individual bytes and consolidate the list into 16 bit values over the expected byte input
    return

def test_debug(spi0, spi1):
    data = [1,2,3,4]
    csv_write_to_file(data)
    
    try:
        # while True:
            resp0 = spi0.xfer2([0x01, 0x02])
            resp1 = spi1.xfer2([0x01, 0x02])
            print BytesToHex(resp0)
            # print BytesToHex(resp1)

            time.sleep(1)
    except KeyboardInterrupt:
        spi0.close()
        spi1.close()
        exit()


def main():
    spi0, spi1 = spi_init()
    gpio_init()
    tgat.tgat_init(spi0, spi1)

    # Simply checks loop back functionality on SPI buses and writes to a CSV file. Comment out when unused.
    test_debug(spi0, spi1)

    try:
        while True:
            resp0 = spi0.xfer2([0x0a, 0x00, 0x9a, 0x72, 0x0a, 0x00])
            resp1 = spi1.xfer2([0x0a, 0x00, 0x9a, 0x72, 0x0a, 0x00])

            print 'Responses'
            print BytesToHex(resp0)
            print BytesToHex(resp1)
            print '---------'
            time.sleep(3)
            data = []
            tgat.tgat_get_data(spi0, data)
            print 'Returned data0'
            print data
            tgat.tgat_get_data(spi1, data)
            print 'Returned data1'
            print data            
            csv_write_to_file(data)
            pass

    except KeyboardInterrupt:
        GPIO.cleanup()
        spi0.close()
        spi1.close()



if __name__ == '__main__':
    main()
