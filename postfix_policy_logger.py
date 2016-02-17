#!/usr/bin/python3
# by Julien BONACHERA <julien@bonachera.fr>
#
# Simple script acting as a policy server
# to log mail at the END_OF_DATA protocol state.
#
# To use it, launch the service, and put the in your postfix config:
#
# smtpd_end_of_data_restrictions =
#   check_policy_service inet:127.0.0.1:8000,
#   permit
#
# This script currently does not apply any policy or access control logic
# It will just output a single line containing informations on the mail
# currently processed. It's a poor man postfix logger.

import socketserver, sys

outputFormat = "[{queue_id}] {sender} -> {recipient} ({size} octets)"

class MyTCPHandler(socketserver.BaseRequestHandler):
  def handle(self):
    self.data = self.request.recv(1024).strip()
    self.request.sendall("action=OK\n\n".encode('utf-8'))
    parsed_msg = parse_msg(self.data.decode('utf-8'))
    if len(parsed_msg['queue_id']) > 0:
      print(outputFormat.format(
                                 queue_id=parsed_msg['queue_id'], 
                                 sender=parsed_msg['sender'], 
                                 client_address=parsed_msg['client_address'], 
                                 client_port=parsed_msg['client_port'], 
                                 recipient=parsed_msg['recipient'], 
                                 size=parsed_msg['size']))
      sys.stdout.flush()


def parse_msg(msg):
  parsed_msg = {}
  for line in msg.split('\n'):
    key, value = line.split('=')
    parsed_msg[key] = value

  return parsed_msg

if __name__ == "__main__":
    HOST, PORT = "127.0.0.1", 8000
    socketserver.TCPServer.allow_reuse_address = True
    server = socketserver.TCPServer((HOST, PORT), MyTCPHandler)
    server.serve_forever()

