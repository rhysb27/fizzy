import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "stamp"
  static values = { scopeSelector: { type: String, default: "body" } }

  connect() {
    if (this.element.closest(this.scopeSelectorValue)) {
      super.connect()
      this.send("connect", this.#data)
    }
  }

  disconnect() {
    super.disconnect()
    this.send("disconnect")
  }

  get #data() {
    const bridgeElement = this.bridgeElement
    return {
      title: bridgeElement.title,
      description: bridgeElement.bridgeAttribute("description") ?? null
    }
  }
}
