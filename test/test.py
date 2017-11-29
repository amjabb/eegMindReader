#!/usr/bin/env python2.7
import argparse  # new in Python2.7
import os
import time
import string
import atexit
import threading
import logging
import sys

logging.basicConfig(level=logging.ERROR)

from yapsy.PluginManager import PluginManager

manager = PluginManager()

import open_bci_ganglion as bci

plugins_paths = ["plugins"]
manager.setPluginPlaces(plugins_paths)
manager.collectPlugins()

    
board = bci.OpenBCIBoard(port=None,
                             daisy=False,
                             filter_data=True,
                             scaled_output=True,
                             log=False,
                             aux=False)

plug_name = 'csv_collect'
plug_args = 'record.csv'
plug = manager.getPluginByName(plug_name)

plug_list = []
callback_list = []
if plug == None:
    # eg: if an import fail inside a plugin, yapsy skip it
    print ("Error: [ " + plug_name + " ] not found or could not be loaded. Check name and requirements.")
else:
    print ("\nActivating [ " + plug_name + " ] plugin...")
if not plug.plugin_object.pre_activate(plug_args, sample_rate=board.getSampleRate(), eeg_channels=board.getNbEEGChannels(), aux_channels=board.getNbAUXChannels(), imp_channels=board.getNbImpChannels()):
    print ("Error while activating [ " + plug_name + " ], check output for more info.")
else:
    print ("Plugin [ " + plug_name + "] added to the list")
    plug_list.append(plug.plugin_object)
    callback_list.append(plug.plugin_object)

if len(plug_list) == 0:
    fun = None
else:
    fun = callback_list


    print("\n-------------BEGIN---------------")
    # Init board state
    # s: stop board streaming; v: soft reset of the 32-bit board (no effect with 8bit board)
    s = 'sv'
    # Tell the board to enable or not daisy module
    if board.daisy:
        s = s + 'C'
    else:
        s = s + 'c'
    # d: Channels settings back to default
    s = s + 'd'

    while(s != "/exit"):
        # Send char and wait for registers to set
        if (not s):
            pass
        elif("help" in s):
            print ("View command map at: \
http://docs.openbci.com/software/01-OpenBCI_SDK.\n\
For user interface: read README or view \
https://github.com/OpenBCI/OpenBCI_Python")

        elif board.streaming and s != "/stop":
            print ("Error: the board is currently streaming data, please type '/stop' before issuing new commands.")
        else:
            # read silently incoming packet if set (used when stream is stopped)
            flush = False

            if('/' == s[0]):
                s = s[1:]
                rec = False  # current command is recognized or fot

                if("T:" in s):
                    lapse = int(s[string.find(s, "T:")+2:])
                    rec = True
                elif("t:" in s):
                    lapse = int(s[string.find(s, "t:")+2:])
                    rec = True
                else:
                    lapse = -1

                if('startimp' in s):
                    if board.getBoardType() == "cyton":
                        print ("Impedance checking not supported on cyton.")
                    else:
                        board.setImpedance(True)
                        if(fun != None):
                            # start streaming in a separate thread so we could always send commands in here
                            boardThread = threading.Thread(target=board.start_streaming, args=(fun, lapse))
                            boardThread.daemon = True # will stop on exit
                            try:
                                boardThread.start()
                            except:
                                    raise
                        else:
                            print ("No function loaded")
                        rec = True
                    
                elif("start" in s):
                    board.setImpedance(False)
                    if(fun != None):
                        # start streaming in a separate thread so we could always send commands in here
                        boardThread = threading.Thread(target=board.start_streaming, args=(fun, lapse))
                        boardThread.daemon = True # will stop on exit
                        try:
                            boardThread.start()
                        except:
                                raise
                    else:
                        print ("No function loaded")
                    rec = True

                elif('test' in s):
                    test = int(s[s.find("test")+4:])
                    board.test_signal(test)
                    rec = True
                elif('stop' in s):
                    board.stop()
                    rec = True
                    flush = True
                if rec == False:
                    print("Command not recognized...")

            elif s:
                for c in s:
                    if sys.hexversion > 0x03000000:
                        board.ser_write(bytes(c, 'utf-8'))
                    else:
                        board.ser_write(bytes(c))
                    time.sleep(0.100)

            line = ''
            time.sleep(0.1) #Wait to see if the board has anything to report
            # The Cyton nicely return incoming packets -- here supposedly messages -- whereas the Ganglion prints incoming ASCII message by itself
            if board.getBoardType() == "cyton":
              while board.ser_inWaiting():
                  c = board.ser_read().decode('utf-8', errors='replace') # we're supposed to get UTF8 text, but the board might behave otherwise
                  line += c
                  time.sleep(0.001)
                  if (c == '\n') and not flush:
                      print('%\t'+line[:-1])
                      line = ''
            elif board.getBoardType() == "ganglion":
                  while board.ser_inWaiting():
                      board.waitForNotifications(0.001)

            if not flush:
                print(line)

        # Take user input
        #s = input('--> ')
        if sys.hexversion > 0x03000000:
            s = input('--> ')
        else:
            s = raw_input('--> ')


    print("\n-------------BEGIN---------------")
    # Init board state
    # s: stop board streaming; v: soft reset of the 32-bit board (no effect with 8bit board)
    s = 'sv'
    # Tell the board to enable or not daisy module
    if board.daisy:
        s = s + 'C'
    else:
        s = s + 'c'
    # d: Channels settings back to default
    s = s + 'd'

    while(s != "/exit"):
        # Send char and wait for registers to set
        if (not s):
            pass
        elif("help" in s):
            print ("View command map at: \
http://docs.openbci.com/software/01-OpenBCI_SDK.\n\
For user interface: read README or view \
https://github.com/OpenBCI/OpenBCI_Python")

        elif board.streaming and s != "/stop":
            print ("Error: the board is currently streaming data, please type '/stop' before issuing new commands.")
        else:
            # read silently incoming packet if set (used when stream is stopped)
            flush = False

            if('/' == s[0]):
                s = s[1:]
                rec = False  # current command is recognized or fot

                if("T:" in s):
                    lapse = int(s[string.find(s, "T:")+2:])
                    rec = True
                elif("t:" in s):
                    lapse = int(s[string.find(s, "t:")+2:])
                    rec = True
                else:
                    lapse = -1

                if('startimp' in s):
                    if board.getBoardType() == "cyton":
                        print ("Impedance checking not supported on cyton.")
                    else:
                        board.setImpedance(True)
                        if(fun != None):
                            # start streaming in a separate thread so we could always send commands in here
                            boardThread = threading.Thread(target=board.start_streaming, args=(fun, lapse))
                            boardThread.daemon = True # will stop on exit
                            try:
                                boardThread.start()
                            except:
                                    raise
                        else:
                            print ("No function loaded")
                        rec = True
                    
                elif("start" in s):
                    board.setImpedance(False)
                    if(fun != None):
                        # start streaming in a separate thread so we could always send commands in here
                        boardThread = threading.Thread(target=board.start_streaming, args=(fun, lapse))
                        boardThread.daemon = True # will stop on exit
                        try:
                            boardThread.start()
                        except:
                                raise
                    else:
                        print ("No function loaded")
                    rec = True

                elif('test' in s):
                    test = int(s[s.find("test")+4:])
                    board.test_signal(test)
                    rec = True
                elif('stop' in s):
                    board.stop()
                    rec = True
                    flush = True
                if rec == False:
                    print("Command not recognized...")

            elif s:
                for c in s:
                    if sys.hexversion > 0x03000000:
                        board.ser_write(bytes(c, 'utf-8'))
                    else:
                        board.ser_write(bytes(c))
                    time.sleep(0.100)

            line = ''
            time.sleep(0.1) #Wait to see if the board has anything to report
            # The Cyton nicely return incoming packets -- here supposedly messages -- whereas the Ganglion prints incoming ASCII message by itself
            if board.getBoardType() == "cyton":
              while board.ser_inWaiting():
                  c = board.ser_read().decode('utf-8', errors='replace') # we're supposed to get UTF8 text, but the board might behave otherwise
                  line += c
                  time.sleep(0.001)
                  if (c == '\n') and not flush:
                      print('%\t'+line[:-1])
                      line = ''
            elif board.getBoardType() == "ganglion":
                  while board.ser_inWaiting():
                      board.waitForNotifications(0.001)

            if not flush:
                print(line)

        # Take user input
        #s = input('--> ')
        if sys.hexversion > 0x03000000:
            s = input('--> ')
        else:
            s = raw_input('--> ')

