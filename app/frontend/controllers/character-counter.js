import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "counter"];
  static values = { countdown: Boolean };

  initialize() {
    this.update = this.update.bind(this);
  }

  connect() {
    this.update();
    this.inputTarget.addEventListener("input", this.update);
  }

  disconnect() {
    this.inputTarget.removeEventListener("input", this.update);
  }

  update() {
    this.counterTarget.innerHTML = this.count.toString();
  }

  get count() {
    let value = this.inputTarget.value.length;

    if (this.hasCountdownValue) {
      if (this.maxLength < 0) {
        console.error(
          `[character-counter] You need to add a maxlength attribute on the input to use countdown mode. The current value is: ${this.maxLength}.`
        );
      }

      value = Math.max(this.maxLength - value, 0);
    }

    return value;
  }

  get maxLength() {
    return this.inputTarget.maxLength;
  }
}
