// app/javascript/controllers/debounce_controller.js
import { Controller } from "@hotwired/stimulus";

export default class Debounce extends Controller {
  static form = document.getElementById("room_search_form");
  static input = document.getElementById("name_search");
  connect() {
    console.log("Debounce controller connected");
    this.clearParam(Debounce.input);
  }

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      Debounce.form.requestSubmit();
    }, 500);
  }
  // Clear name_search param if form is empty
  clearParam(input) {
    if (input.value === "") {
      const baseURL = location.origin + location.pathname;
      window.history.pushState("", "", baseURL);
    }
  }
}
