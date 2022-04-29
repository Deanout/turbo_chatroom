import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="room-list"
export default class extends Controller {
  initialize() {
    const rooms = document.getElementById("rooms");
    this.initialModifyRooms(rooms);
    this.mutationObserver(rooms);
  }
  mutationObserver(rooms) {
    // Options for the observer (which mutations to observe)
    const config = { attributes: true, childList: true, subtree: true };

    // Callback function to execute when mutations are observed
    const callback = (mutationsList, observer) => {
      // Use traditional 'for loops' for IE 11
      for (const mutation of mutationsList) {
        if (mutation.type === "childList") {
          console.log("A child node has been added or removed.");
          const sortedList = sortByLastMessage(rooms);

          modifyRooms(rooms, sortedList, observer, config);
        }
      }
    };
    // Create an observer instance linked to the callback function
    const observer = new MutationObserver(callback);

    // Start observing the target node for configured mutations
    observer.observe(rooms, config);
  }

  initialModifyRooms(rooms) {
    const sortedList = sortByLastMessage(rooms);
    rooms.innerHTML = "";
    sortedList.forEach((room) => {
      rooms.appendChild(room);
    });
  }
}

function modifyRooms(rooms, sortedList, observer, config) {
  observer.disconnect();
  rooms.innerHTML = "";
  sortedList.forEach((room) => {
    rooms.appendChild(room);
  });
  observer.observe(rooms, config);
}

/**
 * Method that sorts the room list by the last-message timestamp
 */
function sortByLastMessage(rooms) {
  const roomList = rooms.querySelectorAll(".room");

  const sortedList = Array.from(roomList).sort((a, b) => {
    const aLastMessage = a.querySelector(".last-message-time")?.dataset?.time;
    const bLastMessage = b.querySelector(".last-message-time")?.dataset?.time;

    if (aLastMessage === undefined) {
      return 1;
    } else if (bLastMessage === undefined) {
      return -1;
    } else {
      return aLastMessage > bLastMessage ? -1 : 1;
    }
  });
  return sortedList;
}
