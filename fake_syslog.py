#!/usr/bin/python3 -u
# Quick script to output on stdout what is read 
# on /dev/log.
# Used to make software like postfix work with "docker log"

import socket, os, re, configparser, signal



config = configparser.ConfigParser()
config.read('/etc/fake_syslog.ini')

socket_file = config['DEFAULT']['socket_file']


def exit_handler(signum, frame):
  print()
  print("Shutting down...")
  server.close()
  os.remove(socket_file)

def syslog_body(msg):
  # message body is right after the first > encoutered
  return msg[msg.index('>')+1:]

def handleMsg(msg):
  try:
     msg = datagram.decode('ascii')
     log(syslog_body(msg))
  except UnicodeDecodeError:
     print("<Non-ASCII string received>")

def log(msg):
  print(msg)

if __name__ == "__main__":
  signal.signal(signal.SIGTERM, exit_handler)
  print("Opening log socket %s" % socket_file)
  server = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM )
  server.bind(socket_file)
  
  print("Listening on %s" % socket_file)
  try:
    while True:
      datagram = server.recv( 2048 )
      if not datagram:
        break
      else:
        handleMsg(datagram)
  except (KeyboardInterrupt, SystemExit, IOError):
    exit_handler(None, None)
