class LiveDevices {
  static wss = null;

  static setWss(wss) {
    LiveDevices.wss = wss;
    console.log('wss set');
  }

  static getSocket(deviceId) {
    if (LiveDevices.wss == null) {
      throw new Error('wss is not set');
    }

    const foundSocket = Array.from(LiveDevices.wss.clients).find((client) => {
      return client.deviceId && client.deviceId.toString() == deviceId.toString();
    });
    return foundSocket ;
  }
}

module.exports = LiveDevices
