

# @param the SPI objects that map onto a TGAT module
def tgat_init(spi0, spi1):
    print 'Initializing TGAT modules'
    # Set up config registers here
    return

# @param spi  The SPIDEV bus to be queried
def tgat_get_data(spi, data = []):
    # Reg 0x20 gives the following:
    # Bit [7:1] : Bytes remaining in buffer
    # Bit [ 0 ] : Ignore
    # Don't bother retrieving until at least 16 bytes are present (== 8 actual readings (16 bit data))
    reg_remaining_bytes = 0x20
    reg_burst_read      = 0x21
    data = (spi.xfer([reg_remaining_bytes]))
    bytes_remaining     = data[0] >> 1
    print data
    print bytes_remaining
    # Enough data is present to deem a worthwhile transfer
    if (bytes_remaining > 16):
        # Send out OpCode 0x21, indicating a burst read of 'bytes_remaining' bytes
        spi.writebytes([reg_burst_read])

        # Create a dummy list; we need to do 'bytes_remaining' number of byte transfers
        dummy = [0] * bytes_remaining
        data.extend(spi.xfer2(dummy))

    # Assume we successfully read data if there was in fact data to be read
    return bytes_remaining > 16
