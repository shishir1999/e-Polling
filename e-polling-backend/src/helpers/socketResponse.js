class SocketResponse {
  constructor({ data, status, message }) {
    if (['error', 'success'].indexOf(status) === -1) {
      throw new Error('Invalid status: ' + status);
    }
    this.data = data;
    this.status = status;
    this.message = message;
  }

  static success(data) {
    return new SocketResponse({
      data,
      status: 'success',
      message: null,
    });
  }

  static error(message) {
    return new SocketResponse({
      data: null,
      status: 'error',
      message,
    });
  }

  toString() {
    return JSON.stringify({ data: this.data, status: this.status, message: this.message });
  }
}

module.exports = SocketResponse;
