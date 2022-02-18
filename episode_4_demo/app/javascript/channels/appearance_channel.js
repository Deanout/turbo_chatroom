import consumer from "channels/consumer";

let timer = 1;
consumer.subscriptions.create(
  { channel: "AppearanceChannel" },
  {
    initialized() {
      this.install();
    },
    connected() {
      this.perform("subscribed");
    },
    disconnected() {
      this.uninstall();
    },
    rejected() {
      this.uninstall();
    },
    online() {
      this.perform("online");
    },
    away() {
      this.perform("away");
    },
    uninstall() {
      window.removeEventListener("load", this.resetTimer.bind(this));
      window.removeEventListener("mousedown", this.resetTimer.bind(this));
      window.removeEventListener("touchstart", this.resetTimer.bind(this));
      window.removeEventListener("touchmove", this.resetTimer.bind(this));
      window.removeEventListener("click", this.resetTimer.bind(this));
      window.removeEventListener("keydown", this.resetTimer.bind(this));
      this.perform("offline");
    },
    install() {
      this.perform("subscribed");
      this.online();
      window.addEventListener("load", this.resetTimer.bind(this));
      window.addEventListener("mousedown", this.resetTimer.bind(this));
      window.addEventListener("touchstart", this.resetTimer.bind(this));
      window.addEventListener("touchmove", this.resetTimer.bind(this));
      window.addEventListener("click", this.resetTimer.bind(this));
      window.addEventListener("keydown", this.resetTimer.bind(this));
    },
    resetTimer() {
      clearTimeout(timer);
      this.online();
      const timeInSeconds = 5;
      const milliseconds = 1000;
      const timeInMilliseconds = timeInSeconds * milliseconds;
      timer = setTimeout(this.away.bind(this), timeInMilliseconds);
    },
  }
);
