import consumer from "channels/consumer";

consumer.subscriptions.create(
  { channel: "AppearanceChannel" },
  {
    initialized() {
      this.perform("subscribed");
      this.awayTimer();
    },
    connected() {},
    disconnected() {
      this.perform("unsubscribed");
    },
    rejected() {
      this.perform("unsubscribed");
    },
    update() {
      this.documentIsActive ? this.online() : this.away();
    },
    online() {
      this.perform("online");
    },
    away() {
      this.perform("away");
    },
    awayTimer() {
      let timer;
      window.onload = resetTimer;
      //window.onmousemove = resetTimer;
      window.onmousedown = resetTimer; // catches touchscreen presses as well
      window.ontouchstart = resetTimer; // catches touchscreen swipes as well
      window.ontouchmove = resetTimer; // required by some devices
      window.onclick = resetTimer; // catches touchpad clicks as well
      window.onkeydown = resetTimer;

      const setAwayStatus = function () {
        this.away();
      }.bind(this);

      const setOnlineStatus = function () {
        this.online();
      }.bind(this);

      function resetTimer() {
        clearTimeout(timer);
        setOnlineStatus();
        // const timeInSeconds = 300; // 5 minutes
        const timeInSeconds = 5; // 30 seconds
        const milliseconds = 1000;
        const timeInMilliseconds = timeInSeconds * milliseconds;
        timer = setTimeout(setAwayStatus, timeInMilliseconds); // time is in milliseconds
      }
    },
  }
);
