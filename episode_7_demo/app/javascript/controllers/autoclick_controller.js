import { Controller } from "@hotwired/stimulus";
import { useIntersection } from "stimulus-use";

// Connects to data-controller="autoclick"
export default class Autoclick extends Controller {
  options = {
    threshold: 0,
  };
  static messagesContainer;
  static topMessage;
  static throttling = false;

  connect() {
    console.log("Connected to Autoclick!");
    useIntersection(this, this.options);
  }

  /**
   * On appear, click the element and scroll to the previous top of the message container.
   */
  appear(entry) {
    if (!Autoclick.throttling) {
      Autoclick.messagesContainer =
        document.getElementById("messages-container");
      Autoclick.topMessage = Autoclick.messagesContainer.children[0];
      Autoclick.throttling = true;
      Autoclick.throttle(this.element.click(), 300);
      setTimeout(() => {
        Autoclick.topMessage.scrollIntoView({
          behavior: "auto",
          block: "end",
        });
        console.log("Scrolling");
        Autoclick.throttling = false;
      }, 250);
    }
  }

  /**
   * Throttle the click function.
   * @param {Function} func The function to throttle.
   * @param {Number} wait The time to wait before executing the function.
   */
  static throttle(func, wait) {
    var timeout = null;
    var previous = 0;

    var later = function () {
      previous = Date.now();
      timeout = null;
      func();
    };

    return function () {
      var now = Date.now();
      var remaining = wait - (now - previous);
      if (remaining <= 0 || remaining > wait) {
        if (timeout) {
          clearTimeout(timeout);
        }

        later();
      } else if (!timeout) {
        //null timeout -> no pending execution

        timeout = setTimeout(later, remaining);
      }
    };
  }
}
