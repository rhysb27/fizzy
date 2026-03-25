// Web components for the ActionPack::Passkey Ruby helpers.
//
// <rails-passkey-creation-button> — wraps a registration ceremony form
// <rails-passkey-sign-in-button>  — wraps an authentication ceremony form
//
// The Ruby form helpers render the component markup including the inner form,
// hidden fields, button, and error messages. The components handle the WebAuthn
// ceremony lifecycle (challenge refresh, credential creation/authentication,
// form submission) and error state toggling.
//
// Custom events (all bubble):
//   passkey:start   — ceremony begun
//   passkey:success — credential obtained, form about to submit
//   passkey:error   — ceremony failed; detail: { error, cancelled }
//
// Attributes (rendered by the Ruby form helpers):
//   creation-options — JSON WebAuthn creation options (on rails-passkey-creation-button)
//   request-options  — JSON WebAuthn request options (on rails-passkey-sign-in-button)
//   challenge-url    — endpoint to refresh the challenge nonce (on both)
//   mediation        — WebAuthn mediation hint, e.g. "conditional" (on rails-passkey-sign-in-button)

import { register, authenticate } from "lib/action_pack/webauthn"

class PasskeyCreationButton extends HTMLElement {
  connectedCallback() {
    this.button.addEventListener("click", this.#create)
  }

  disconnectedCallback() {
    this.button.removeEventListener("click", this.#create)
    this.button.disabled = false
    delete this.dataset.passkeyErrorState
  }

  get button() {
    return this.querySelector("[data-passkey='create']")
  }

  get form() {
    return this.querySelector("form")
  }

  get creationOptions() {
    return JSON.parse(this.getAttribute("creation-options"))
  }

  get challengeUrl() {
    return this.getAttribute("challenge-url")
  }

  // Arrow function to preserve `this` binding for addEventListener/removeEventListener.
  #create = async () => {
    this.button.disabled = true
    this.button.dispatchEvent(new CustomEvent("passkey:start", { bubbles: true }))

    try {
      if (!passkeysAvailable()) throw new Error("Passkeys are not supported by this browser")
      if (!this.creationOptions) throw new Error("Missing passkey creation options")

      const options = this.creationOptions
      await refreshChallenge(options, this.challengeUrl)
      const passkey = await register(options)

      this.button.dispatchEvent(new CustomEvent("passkey:success", { bubbles: true }))
      fillCreateForm(this.form, passkey)
      this.form.submit()
    } catch (error) {
      this.button.disabled = false
      this.#handleError(error)
    }
  }

  #handleError(error) {
    const cancelled = error.name === "AbortError" || error.name === "NotAllowedError"
    this.dataset.passkeyErrorState = cancelled ? "cancelled" : "error"
    this.button.dispatchEvent(new CustomEvent("passkey:error", { bubbles: true, detail: { error, cancelled } }))
  }
}

class PasskeySignInButton extends HTMLElement {
  connectedCallback() {
    this.button.addEventListener("click", this.#signIn)

    if (this.mediation === "conditional") this.#attemptConditionalMediation()
  }

  disconnectedCallback() {
    this.button.removeEventListener("click", this.#signIn)
    this.button.disabled = false
    delete this.dataset.passkeyErrorState
  }

  get button() {
    return this.querySelector("[data-passkey='sign_in']")
  }

  get form() {
    return this.querySelector("form")
  }

  get requestOptions() {
    return JSON.parse(this.getAttribute("request-options"))
  }

  get challengeUrl() {
    return this.getAttribute("challenge-url")
  }

  get mediation() {
    return this.getAttribute("mediation")
  }

  // Arrow function to preserve `this` binding for addEventListener/removeEventListener.
  #signIn = async () => {
    this.button.disabled = true
    this.button.dispatchEvent(new CustomEvent("passkey:start", { bubbles: true }))

    try {
      if (!passkeysAvailable()) throw new Error("Passkeys are not supported by this browser")
      if (!this.requestOptions) throw new Error("Missing passkey request options")

      const options = this.requestOptions
      await refreshChallenge(options, this.challengeUrl)
      const passkey = await authenticate(options)

      this.button.dispatchEvent(new CustomEvent("passkey:success", { bubbles: true }))
      fillSignInForm(this.form, passkey)
      this.form.submit()
    } catch (error) {
      this.button.disabled = false
      this.#handleError(error)
    }
  }

  async #attemptConditionalMediation() {
    if (await this.#conditionalMediationAvailable()) {
      const options = this.requestOptions

      this.form.dispatchEvent(new CustomEvent("passkey:start", { bubbles: true }))

      try {
        await refreshChallenge(options, this.challengeUrl)
        const passkey = await authenticate(options, { mediation: this.mediation })

        this.form.dispatchEvent(new CustomEvent("passkey:success", { bubbles: true }))
        fillSignInForm(this.form, passkey)
        this.form.submit()
      } catch (error) {
        this.#handleError(error)
      }
    }
  }

  async #conditionalMediationAvailable() {
    return this.requestOptions &&
           passkeysAvailable() &&
           await window.PublicKeyCredential.isConditionalMediationAvailable?.()
  }

  #handleError(error) {
    const cancelled = error.name === "AbortError" || error.name === "NotAllowedError"
    this.dataset.passkeyErrorState = cancelled ? "cancelled" : "error"
    this.button.dispatchEvent(new CustomEvent("passkey:error", { bubbles: true, detail: { error, cancelled } }))
  }
}

customElements.define("rails-passkey-creation-button", PasskeyCreationButton)
customElements.define("rails-passkey-sign-in-button", PasskeySignInButton)

// -- Shared helpers ----------------------------------------------------------

function passkeysAvailable() {
  return !!window.PublicKeyCredential
}

async function refreshChallenge(options, challengeUrl) {
  if (!challengeUrl) throw new Error("Missing passkey challenge URL")
  const token = document.querySelector('meta[name="csrf-token"]')?.content

  const response = await fetch(challengeUrl, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": token,
      "Accept": "application/json"
    }
  })

  if (!response.ok) throw new Error("Failed to refresh challenge")

  const { challenge } = await response.json()
  options.challenge = challenge
}

function fillCreateForm(form, passkey) {
  form.querySelector('[data-passkey-field="client_data_json"]').value = passkey.client_data_json
  form.querySelector('[data-passkey-field="attestation_object"]').value = passkey.attestation_object

  const template = form.querySelector('[data-passkey-field="transports"]')
  for (const transport of passkey.transports) {
    const input = template.cloneNode()
    input.value = transport
    template.before(input)
  }
  template.remove()
}

function fillSignInForm(form, passkey) {
  form.querySelector('[data-passkey-field="id"]').value = passkey.id
  form.querySelector('[data-passkey-field="client_data_json"]').value = passkey.client_data_json
  form.querySelector('[data-passkey-field="authenticator_data"]').value = passkey.authenticator_data
  form.querySelector('[data-passkey-field="signature"]').value = passkey.signature
}
