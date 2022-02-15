//example for whitecatboard, bme280 and mqtt

import gpio
import i2c
import bme280
import net
import mqtt
import encoding.json
import device
import pubsub

V3S       ::= 27 //gpio turn on i2c in whitecat board
CLIENT_ID ::= "wc-1"
HOST      ::= "167.86.87.117"
PORT      ::= 1883
TOPIC     ::= "/toit/wc-1"

t := 0
h := 0
p := 0

main:
  v3s := gpio.Pin V3S --output
  v3s.set 1  //turn on i2c (only whitecatboard)
  bus := i2c.Bus
    --sda=gpio.Pin 33 //21
    --scl=gpio.Pin 32 //22

  device := bus.device bme280.I2C_ADDRESS
  driver := bme280.Driver device
  
  socket := net.open.tcp_connect HOST PORT
  // Connect the Toit MQTT client to the broker
  client := mqtt.Client
    CLIENT_ID
    mqtt.TcpTransport socket

  // The client is now connected.
  print "Connected to MQTT Broker @ $HOST:$PORT"
  
  //read sensor
  t = driver.read_temperature
  h = driver.read_humidity
  p = driver.read_pressure/100
  print "t=$t C"
  print "h=$h %"
  print "p=$p hPa"

  //publish in broker
  publish client t h p
  
  sleep --ms=100 //necessary??

// funcitons
publish client/mqtt.Client payload_t/float payload_h/float payload_p:
  // Publish message to topic
  timeStamp := Time.now.local//add timestamp to message
  client.publish
    TOPIC
    json.encode {
      "tS": "$timeStamp",
      "t" : payload_t,
      "h" : payload_h,
      "p" : payload_p
    }
  print "Published message on '$TOPIC'"  

