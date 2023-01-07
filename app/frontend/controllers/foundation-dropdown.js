import { Controller } from "@hotwired/stimulus";
import Foundation from "foundation-sites";

export default class extends Controller {
  $element = null;
  dropdown = null;

  connect() {
    this.$element = $(this.element);
    this.dropdown = new Foundation.Dropdown(this.$element);

    // Add support for opening the dropdown when it initialises
    if (this.$element.is("[data-dropdown-initially-open='true']")) {
      this.open();
    }
  }

  open() {
    this.$element.foundation("open");
  }

  close() {
    this.$element.foundation("close");
  }

  disconnect() {
    this.$element.foundation("_destroy");
  }
}
