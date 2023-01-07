import { Controller } from "@hotwired/stimulus";
import Foundation from "foundation-sites";

export default class extends Controller {
  connect() {
    $(this.element).foundation();
    Foundation.MediaQuery._init();

    // Add support to open dropdowns using a data attribute
    $(this.element).find("[data-dropdown-initially-open='true']").foundation("open");
  }
}
