// test in ttgo oled lora board, with toitlang.org and jag.
// jnogues @rprimTech.

import gpio
import net
import mqtt
import encoding.json
import device
import esp32

CLIENT_ID ::= "ttgo"
HOST      ::= "test.mosquitto.org"
PORT      ::= 1883
TOPIC     ::= "/test/toit/ttgo/commands"

main:
  print("+++++++++++++++++++start++++++++++++++++++++++")
  led_blau := gpio.Pin 2 --output
  socket := net.open.tcp_connect HOST PORT
  // Connect the Toit MQTT client to the broker.
  client := mqtt.Client
    CLIENT_ID
    mqtt.TcpTransport socket

  // The client is now connected.
  print "Connected to MQTT Broker @ $HOST:$PORT"
  
  task::  // Start task for listening incomming commands.
    print "In Task 1"
    subscribe client
  
  task::
    print "In Task 2"
    while true:
      led_blau.set 1 
      sleep --ms=100
      led_blau.set  0
      sleep --ms=100

  i := 0
  while true:
    sleep --ms=10000
    yield
    i++
    run_time ::= Duration --us=esp32.total_run_time
    print "$run_time"
    //client.publish "/test/toit/ttgo/tic-tac" "$i".to_byte_array
    client.publish "/test/toit/ttgo/tic-tac" "$run_time".to_byte_array
    print "tic-tac $i"
    

subscribe client/mqtt.Client:
  topic ::= TOPIC
  client.subscribe topic --qos=0

  client.handle: | topic/string payload/ByteArray |
    // decoded := json.decode payload
    if payload.to_string == "ON":
      print "Command: ON"
    else if payload.to_string == "OFF":
      print "Command: OFF"
    else:
      print "Unknow Command"  
    print "Received value on '$topic': $payload.to_string_non_throwing"

  

  
