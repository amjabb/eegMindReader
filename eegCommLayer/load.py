from sklearn.externals import joblib
import numpy as np
import scipy as sp
import pandas as pd
import scipy.io
from sklearn.cluster import KMeans
import warnings
import serial
import time
import os
import glob
import RPi.GPIO as IO
import gc

import argparse
import cPickle as picklex
import json
import sys
import open_bci_v3 as open_bci
import socket
import time

##################################################################################################
##########################################ARGUMENTS###############################################
##################################################################################################

parser = argparse.ArgumentParser(description='Run a UDP client listening for streaming OpenBCI data.')
parser.add_argument(
    '--host',
    help='The host to listen on.',
    default='127.0.0.1')
parser.add_argument(
    '--port',
    help='The port to listen on.',
    default='8888')

parser.add_argument(
    '--no-read',
    action='store_false',
    help='Pass no read to stop reading data')
parser.add_argument(
    '--file',
    default='KNN_model.sav',
    help='Trained model full path + file name')

##################################################################################################
##########################################UDPCLIENT###############################################
##################################################################################################

class UDPClient(object):

  def __init__(self, ip, port, model_file_name, buffer_size=1024):

    self._ip = ip
    self._port = port
    self._addr = (self._ip, self._port)
    self._buffer_size = buffer_size
    self._model_file_name = model_file_name
    # @MAYBE wrong
    self._loaded_model = None
    
    # Create a TCP/IP client 
    self._socket_client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    self._setup_dict = {  '_socket_client_connect': self._socket_client_connect,
                          '_load_processed_model': self._load_processed_model,
                          '_read' : self._read,
                        }
    self._sequencer_list = ['_socket_client_connect', '_load_processed_model', '_read']

    
  def _load_processed_model(self):
         self._loaded_model = joblib.load(self._model_file_name)
         
  def _socket_client_connect(self):
         self._socket_client.bind(self._addr)
                
  def _socket_client_close(self):
         self._socket_client.close()
             
  def _read(self, condition=True):

          print self._setup_dict
          while condition:
                data, addr = self._socket_client.recvfrom(self._buffer_size)
                sample = json.loads(data)

                prediction = self._loaded_model.predict([sample])
                print typeof(prediction)
        

  def _setup_sequence(self, condition=False):
          
          for func_name in self._sequencer_list:
                print("Calling {func_name}...".format(func_name=func_name))
                self._setup_dict[func_name]()               


##################################################################################################
########################################START_EXECUTION###########################################
##################################################################################################

args = parser.parse_args()
UDPclient_sock = UDPClient(ip=args.host, port=int(args.port), model_file_name=args.file)
UDPclient_sock._setup_sequence()

