import { BridgeElement } from "@hotwired/hotwire-native-bridge"

BridgeElement.prototype.getButton = function() {
  return {
    title: this.title,
    icon: this.getIcon(),
    displayTitle: this.getDisplayTitle(),
    displayAsPrimaryAction: this.getDisplayAsPrimaryAction()
  }
}

BridgeElement.prototype.getStamp = function() {
  return {
    title: this.title,
    date: this.getDate(),
    by: this.getBy()
  }
}

BridgeElement.prototype.getIcon = function() {
  const url = this.bridgeAttribute("icon-url")

  if (url) {
    return { url }
  }

  return null
}

BridgeElement.prototype.getDate = function() {
  return this.bridgeAttribute("date") ?? null
}

BridgeElement.prototype.getBy = function() {
  return this.bridgeAttribute("by") ?? null
}

BridgeElement.prototype.getDisplayTitle = function() {
  return !!this.bridgeAttribute("display-title")
}

BridgeElement.prototype.getDisplayAsPrimaryAction = function() {
  return !!this.bridgeAttribute("display-as-primary-action")
}
