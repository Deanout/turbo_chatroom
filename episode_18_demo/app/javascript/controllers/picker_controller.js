import { Controller } from "@hotwired/stimulus";
import { createPicker } from "https://unpkg.com/picmo@5.0.0/dist/index.js";
import { createPopup } from "https://unpkg.com/@picmo/popup-picker@5.0.0/dist/index.js";

// Connects to data-controller="picker"
export default class extends Controller {
  connect() {
    const container = document.querySelector(".pickerContainer");
    const trigger = document.querySelector(".emoji-button");

    trigger.addEventListener("click", () => {
      alert("Clickereed");
      const picker = createPopup({
        referenceElement: trigger,
        triggerElement: trigger,
        rootElement: container,
      });
    });

    // const picker = createPopup({
    //   referenceElement: trigger,
    //   triggerElement: trigger,
    // });
    console.log("Picker Connected");
  }
}
