arDrone = require("ar-drone")
client = arDrone.createClient()

@offsetAccelX = 0
@offsetAccelY = 0
@offsetAccelZ = 0

Myo = require("myo")
myMyo = Myo.create()
console.log Myo.myos

Myo.on "connected", ->
  console.log "connected: ", this

Myo.on "arm_lost", ->
  console.log "hello"
  client.land()

roll_mode = false

move_mode = false

myMyo.on "pose", (pose, edge) =>
  if pose == "wave_out" && edge
#    myMyo.zeroOrientation()
    client.disableEmergency()
    client.takeoff()

    imu = myMyo.lastIMU
    @offsetAccelX = imu.accelerometer.x;
    @offsetAccelY = imu.accelerometer.y;
    @offsetAccelZ = imu.accelerometer.z;
  else if pose == "wave_in" && edge
    client.land()

  else if pose == "fingers_spread" && edge
    move_mode = true
  else if pose == "fingers_spread" && !edge
    move_mode = false


  else if pose == "fist" && edge
    roll_mode = true
  else if pose == "fist" && !edge
    roll_mode = false
  else
    client.stop()



#
myMyo.on "imu", (data) =>
  console.log "\n\n\n\n\n\n\n\n\n\n\n"
  roll = Math.atan2(2.0 * (data.orientation.w * data.orientation.x + data.orientation.y * data.orientation.z), 1.0 - 2.0 * (data.orientation.x * data.orientation.x + data.orientation.y * data.orientation.y))
  pitch = Math.asin(Math.max(-1.0, Math.min(1.0, 2.0 * (data.orientation.w * data.orientation.y - data.orientation.z * data.orientation.x))))
  yaw = Math.atan2(2.0 * (data.orientation.w * data.orientation.z + data.orientation.x * data.orientation.y), 1.0 - 2.0 * (data.orientation.y * data.orientation.y + data.orientation.z * data.orientation.z))
  
  console.log "Quat: #{Math.round(data.orientation.x*100)} #{Math.round(data.orientation.y*100)} #{Math.round(data.orientation.z*100)} #{Math.round(data.orientation.w*100)}"
  console.log "Roll: #{Math.round(roll*100)}"
  console.log "Pitch: #{Math.round(pitch*100)}"
  console.log "Yaw: #{Math.round(yaw*100)}"
  #console.log "Gyro: #{parseFloat(data.gyroscope.x).toPrecision(4)}\t\t#{data.gyroscope.y}\t\t#{data.gyroscope.z}"
  console.log "AccelX: #{Math.round((data.accelerometer.x - @offsetAccelX)*100)} : #{Math.round((data.accelerometer.x)*100)}"
  console.log "AccelY: #{Math.round((data.accelerometer.y - @offsetAccelY)*100)} : #{Math.round((data.accelerometer.y)*100)}"
  console.log "AccelZ: #{Math.round((data.accelerometer.z - @offsetAccelZ)*100)} : #{Math.round((data.accelerometer.z)*100)}"
  # console.log data
  if roll < -0.5
    # if 
    # drone_rotate = "left"
    console.log "left"
    client.counterClockwise(0.5) if roll_mode
    client.front(0.1) if move_mode

  else if roll > 0.5
    client.clockwise(0.5) if roll_mode
    # client.front(0.1) if move_mode
    console.log "right"
  else 
    client.stop()
    console.log "nothing"


# assume logo facing up, logo base facing body, palm facing down, tests done with left arm with a fist, reset with palm down
#         roll, pitch, yaw -  quaternian        accelerometer -20
# up      = -50, +10, +50  - +50 +50 -30 -15  -  +90   0 -50
# down    = -10, -10, +20  - -15 -20 -10 +10  -  -90   0 -50
# left    = +40, -10, +10  - -15 -10 -50 -30  -    0 +30   0
# right   = +10, +10, +30  - +10 +25 +15 +50  -    0 +40   0
# roll l  =   0, -10, -50  - +30 -30  +5  -5  -  -10 -50 -50
# roll r  = -40, +20, -20  - -30 +40 -15 +25  -    0 +90   0
