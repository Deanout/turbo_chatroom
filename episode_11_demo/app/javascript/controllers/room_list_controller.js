import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="room-list"
export default class extends Controller {
  initialize() {
    console.log("This was called?");
    const rooms = document.getElementById("rooms");
    this.initialModifyRooms(rooms);
    this.mutationObserver(rooms);
  }

  mutationObserver(targetNode) {
    // Options for the observer (which mutations to observe)
    const config = { attributes: true, childList: true, subtree: true };

    // Callback function to execute when mutations are observed
    const callback = function (mutationsList, observer) {
      // Use traditional 'for loops' for IE 11
      for (const mutation of mutationsList) {
        if (mutation.type === "childList") {
          console.log("A child node has been added or removed.");
          const rooms = document.getElementById("rooms");
          const sortedList = sortByLastMessage(rooms);

          modifyRooms(rooms, sortedList, observer, targetNode, config);
        } else if (mutation.type === "attributes") {
          console.log(
            "The " + mutation.attributeName + " attribute was modified."
          );
        }
      }
    };
    // Create an observer instance linked to the callback function
    const observer = new MutationObserver(callback);

    // Start observing the target node for configured mutations
    observer.observe(targetNode, config);
  }
  initialModifyRooms(rooms) {
    const sortedList = sortByLastMessage(rooms);
    rooms.innerHTML = "";
    sortedList.forEach((room) => {
      rooms.appendChild(room);
    });
  }
}

function modifyRooms(rooms, roomList, observer, targetNode, config) {
  observer.disconnect();
  console.log("Modifying rooms");
  rooms.innerHTML = "";
  roomList.forEach((room) => {
    rooms.appendChild(room);
  });
  observer.observe(targetNode, config);
}

/**
 * Method that sorts the room list by the last-message timestamp
 */
function sortByLastMessage(rooms) {
  console.log("SORTING");

  const roomList = rooms.querySelectorAll(".room");

  const sortedList = Array.from(roomList).sort((a, b) => {
    const aLastMessage = a.querySelector(".last-message-time")?.dataset?.time;
    const bLastMessage = b.querySelector(".last-message-time")?.dataset?.time;
    console.log("A: " + aLastMessage);
    console.log("B: " + bLastMessage);

    if (a.querySelector(".last-message-time")?.dataset?.time === undefined) {
      return 1;
    } else if (
      b.querySelector(".last-message-time")?.dataset?.time === undefined
    ) {
      return -1;
    } else {
      return aLastMessage > bLastMessage ? -1 : 1;
    }
  });
  return sortedList;
}
