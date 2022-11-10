const LiveDevices = require('./liveDevices');
const SocketResponse = require('./socketResponse');

const notifyRestart = (device) => {
  try {
    let socket = LiveDevices.getSocket(device._id);
    if (socket) {
      socket.send(new SocketResponse({ data: { restart: true } , status: "success"}).toString());
    }else{
        console.log("Device " + device.name + " not notified of restart");
    }
  } catch (e) {
    console.log('Error Notifying Restart: ', e);
  }
};

module.exports.notifyRestart = notifyRestart;
