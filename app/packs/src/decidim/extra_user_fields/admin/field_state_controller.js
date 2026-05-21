import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["enabled", "required", "subfields", "row"]
  static values = {
    enabledState: { type: String, default: "optional" },
    disabledState: { type: String, default: "disabled" }
  }

  connect() {
    this.sync()
  }

  toggleEnabled() {
    if (!this.enabledTarget.checked) {
      if (this.hasRequiredTarget) {
        this.requiredTarget.checked = false
        this.requiredTarget.disabled = true
      }
    } else {
      if (this.hasRequiredTarget) {
        this.requiredTarget.disabled = false
      }
    }

    this.updateRow()
    this.updateSubfields()
  }

  toggleRequired() {
    this.updateRow()
  }

  sync() {
    const enabled = this.enabledTarget.checked

    if (this.hasRequiredTarget) {
      this.requiredTarget.disabled = !enabled
    }

    this.updateRow()
    this.updateSubfields()
  }

  updateRow() {
    if (!this.hasRowTarget) return

    const row = this.rowTarget
    row.classList.remove("field-row--disabled", "field-row--required")

    const state = this.getState()
    if (state === this.disabledStateValue) {
      row.classList.add("field-row--disabled")
    } else if (state === "required") {
      row.classList.add("field-row--required")
    }
  }

  updateSubfields() {
    const enabled = this.enabledTarget.checked
    this.subfieldsTargets.forEach((el) => {
      el.hidden = !enabled
    })
  }

  getState() {
    const enabled = this.enabledTarget.checked
    
    if (!enabled) {
      return this.disabledStateValue
    }

    if (this.hasRequiredTarget && this.requiredTarget.checked) {
      return "required"
    }

    return this.enabledStateValue
  }
}
