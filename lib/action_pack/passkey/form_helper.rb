# View helpers for rendering passkey web components.
#
# Include this module in your helper or ApplicationHelper to get access to:
#
# - +passkey_creation_button+ — render a <rails-passkey-creation-button> web component with
#   a form, hidden fields, and error messages for the registration ceremony.
# - +passkey_sign_in_button+ — render a <rails-passkey-sign-in-button> web component with
#   a form, hidden fields, and error messages for the authentication ceremony.
module ActionPack::Passkey::FormHelper
  # Renders a +<rails-passkey-creation-button>+ web component containing a form with hidden
  # fields for the passkey registration ceremony and error messages. The form POSTs to +url+ and
  # includes hidden fields for +client_data_json+, +attestation_object+, and +transports+ —
  # populated by the web component after the browser credential API resolves.
  # Accepts a +label+ string or a block for button content.
  #
  # Options:
  # - +options+: WebAuthn creation options (JSON-serializable hash)
  # - +challenge_url+: endpoint to refresh the challenge nonce
  # - +param+: the form parameter namespace (default: +:passkey+)
  # - +error_message+: message shown on ceremony failure
  # - +cancelled_message+: message shown when ceremony is cancelled
  # - +form+: additional HTML attributes for the +<form>+ tag
  # - All other options are passed to the +<button>+ tag
  def passkey_creation_button(name = nil, url = nil, options:, challenge_url: nil, param: :passkey, error_message: "Something went wrong while registering your passkey.", cancelled_message: "Passkey registration was cancelled. Try again when you are ready.", form: {}, **button_options, &block)
    url, name = name, block ? capture(&block) : nil if block_given?
    form_options = form.reverse_merge(method: :post, action: url, class: "button_to")

    component_options = {
      "creation-options": options.to_json,
      "challenge-url": challenge_url || default_passkey_challenge_url
    }

    tag.send(:"rails-passkey-creation-button", **component_options) do
      form_tag = tag.form(**form_options) do
        hidden_field_tag(:authenticity_token, form_authenticity_token) +
          hidden_field_tag("#{param}[client_data_json]", nil, id: nil, data: { passkey_field: "client_data_json" }) +
          hidden_field_tag("#{param}[attestation_object]", nil, id: nil, data: { passkey_field: "attestation_object" }) +
          hidden_field_tag("#{param}[transports][]", nil, id: nil, data: { passkey_field: "transports" }) +
          tag.button(name, type: :button, data: { passkey: "create" }, **button_options)
      end

      form_tag + passkey_error_messages(error_message, cancelled_message)
    end
  end

  # Renders a +<rails-passkey-sign-in-button>+ web component containing a form with hidden
  # fields for the passkey authentication ceremony and error messages. The form POSTs to +url+
  # and includes hidden fields for +id+, +client_data_json+, +authenticator_data+, and +signature+.
  # Accepts a +label+ string or a block for button content.
  #
  # Options:
  # - +options+: WebAuthn request options (JSON-serializable hash)
  # - +challenge_url+: endpoint to refresh the challenge nonce
  # - +param+: the form parameter namespace (default: +:passkey+)
  # - +mediation+: WebAuthn mediation hint (e.g. +"conditional"+ for autofill-assisted sign in)
  # - +error_message+: message shown on ceremony failure
  # - +cancelled_message+: message shown when ceremony is cancelled
  # - +form+: additional HTML attributes for the +<form>+ tag
  # - All other options are passed to the +<button>+ tag
  def passkey_sign_in_button(name = nil, url = nil, options:, challenge_url: nil, param: :passkey, mediation: nil, error_message: "Something went wrong while signing in with your passkey.", cancelled_message: "Passkey sign in was cancelled. Try again when you are ready.", form: {}, **button_options, &block)
    url, name = name, block ? capture(&block) : nil if block_given?
    form_options = form.reverse_merge(method: :post, action: url, class: "button_to")

    component_options = {
      "request-options": options.to_json,
      "challenge-url": challenge_url || default_passkey_challenge_url
    }
    component_options[:mediation] = mediation if mediation

    tag.send(:"rails-passkey-sign-in-button", **component_options) do
      form_tag = tag.form(**form_options) do
        hidden_field_tag(:authenticity_token, form_authenticity_token) +
          hidden_field_tag("#{param}[id]", nil, id: nil, data: { passkey_field: "id" }) +
          hidden_field_tag("#{param}[client_data_json]", nil, id: nil, data: { passkey_field: "client_data_json" }) +
          hidden_field_tag("#{param}[authenticator_data]", nil, id: nil, data: { passkey_field: "authenticator_data" }) +
          hidden_field_tag("#{param}[signature]", nil, id: nil, data: { passkey_field: "signature" }) +
          tag.button(name, type: :button, data: { passkey: "sign_in" }, **button_options)
      end

      form_tag + passkey_error_messages(error_message, cancelled_message)
    end
  end

  private
    def default_passkey_challenge_url
      if challenge_url = Rails.configuration.action_pack.passkey.challenge_url
        instance_exec(&challenge_url)
      else
        passkey_challenge_path
      end
    end

    def passkey_error_messages(error_message, cancelled_message)
      tag.p(error_message, data: { passkey_error: "error" }, class: "txt-negative") +
        tag.p(cancelled_message, data: { passkey_error: "cancelled" }, class: "txt-subtle")
    end
end
