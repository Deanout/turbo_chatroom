import consumer from "channels/consumer";

let timer = 1;
consumer.subscriptions.create(
  { channel: "AppearanceChannel" },
  {
    initialized() {
      console.log("init");
      this.perform("subscribed");
      this.install();
      this.online();
    },
    connected() {
      console.log("connectd");
      this.perform("subscribed");
      this.install();
      this.online();
    },
    disconnected() {
      console.log("disconnectd");
      this.uninstall();
      this.perform("offline");
    },
    rejected() {
      console.log("Rejected");
      this.uninstall();
      this.perform("offline");
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
    },
    install() {
      console.log(timer);
      window.addEventListener("load", this.resetTimer.bind(this));
      window.addEventListener("mousedown", this.resetTimer.bind(this));
      window.addEventListener("touchstart", this.resetTimer.bind(this));
      window.addEventListener("touchmove", this.resetTimer.bind(this));
      window.addEventListener("click", this.resetTimer.bind(this));
      window.addEventListener("keydown", this.resetTimer.bind(this));
    },
    resetTimer() {
      console.log("RESET TIMER");
      clearTimeout(timer);
      this.online();
      // const timeInSeconds = 300; // 5 minutes
      const timeInSeconds = 5; // 30 seconds
      const milliseconds = 1000;
      const timeInMilliseconds = timeInSeconds * milliseconds;
      timer = setTimeout(this.away.bind(this), timeInMilliseconds); // time is in milliseconds
    },
  }
);
