import consumer from "channels/consumer";

let resetFunc;
let timer = 0;
window.consumer = consumer;
consumer.subscriptions.create(
  { channel: "AppearanceChannel" },
  {
    initialized() {},
    connected() {
      console.log("connected");
      resetFunc = () => this.resetTimer(this.uninstall);
      this.install();
      window.addEventListener("turbo:load", () => this.resetTimer());
    },
    disconnected() {
      console.log("disconnected");
      this.uninstall();
    },
    rejected() {
      console.log("rejected");
      this.uninstall();
    },
    online() {
      console.log("online");
      this.perform("online");
    },
    away() {
      console.log("away");
      this.perform("away");
    },
    uninstall() {
      const shouldRun = document.getElementById("appearance_channel");
      if (!shouldRun) {
        clearTimeout(timer);
        this.perform("offline");
      }
    },
    install() {
      console.log("install");
      window.removeEventListener("load", resetFunc);
      window.removeEventListener("DOMContentLoaded", resetFunc);
      window.removeEventListener("click", resetFunc);
      window.removeEventListener("keydown", resetFunc);

      window.addEventListener("load", resetFunc);
      window.addEventListener("DOMContentLoaded", resetFunc);
      window.addEventListener("click", resetFunc);
      window.addEventListener("keydown", resetFunc);
      this.resetTimer();
    },
    resetTimer() {
      this.uninstall();
      const shouldRun = document.getElementById("appearance_channel");

      if (!!shouldRun) {
        this.online();
        clearTimeout(timer);
        const timeInSeconds = 5;
        const milliseconds = 1000;
        const timeInMilliseconds = timeInSeconds * milliseconds;
        timer = setTimeout(this.away.bind(this), timeInMilliseconds);
      }
    },
  }
);
