import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "stamp"

  connect() {
    super.connect()
    this.notifyBridgeOfConnect()
  }

  disconnect() {
    super.disconnect()
    this.send("disconnect")
  }

  notifyBridgeOfConnect() {
    this.send("connect", this.bridgeElement.getStamp())
  }
}
