import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="debounce"
export default class Debounce extends Controller {
  static form = document.getElementById("room_search_form");
  static input = document.getElementById("name_search");
  connect() {
    this.clearParam(Debounce.input);
  }

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      Debounce.form.requestSubmit();
    }, 500);
  }

  clearParam(input) {
    if (input.value === "") {
      const baseURL = location.origin + location.pathname;
      window.history.pushState("", "", baseURL);
    }
  }
}
