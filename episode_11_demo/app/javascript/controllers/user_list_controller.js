import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="room-list"
export default class extends Controller {
  initialize() {
    console.log("This was called?");
    const users = document.getElementById("users");
    this.initialModifyUsers(users);
    this.mutationObserver(users);
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
          const sortedList = sortByLastMessage(targetNode);

          modifyUsers(sortedList, targetNode, observer, config);
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
  initialModifyUsers(users) {
    const sortedList = sortByLastMessage(users);
    users.innerHTML = "";
    sortedList.forEach((user) => {
      users.appendChild(user);
    });
  }
}

function modifyUsers(userList, targetNode, observer, config) {
  observer.disconnect();
  console.log("Modifying users");
  targetNode.innerHTML = "";
  userList.forEach((user) => {
    targetNode.appendChild(user);
  });
  observer.observe(targetNode, config);
}

/**
 * Method that sorts the room list by the last-message timestamp
 */
function sortByLastMessage(users) {
  const userList = users.querySelectorAll(".user");

  const sortedList = Array.from(userList).sort((a, b) => {
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
