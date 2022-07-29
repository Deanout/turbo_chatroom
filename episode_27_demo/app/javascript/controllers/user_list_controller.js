import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="user-list"
export default class extends Controller {
  initialize() {
    const users = document.getElementById("users");
    this.initialModifyUsers(users);
    this.mutationObserver(users);
  }
  mutationObserver(users) {
    // Options for the observer (which mutations to observe)
    const config = { attributes: true, childList: true, subtree: true };

    // Callback function to execute when mutations are observed
    const callback = (mutationsList, observer) => {
      // Use traditional 'for loops' for IE 11
      for (const mutation of mutationsList) {
        if (mutation.type === "childList") {
          console.log("A child node has been added or removed.");
          const sortedList = sortByLastMessage(users);

          modifyUsers(users, sortedList, observer, config);
        }
      }
    };
    // Create an observer instance linked to the callback function
    const observer = new MutationObserver(callback);

    // Start observing the target node for configured mutations
    observer.observe(users, config);
  }

  initialModifyUsers(users) {
    const sortedList = sortByLastMessage(users);
    users.innerHTML = "";
    sortedList.forEach((user) => {
      users.appendChild(user);
    });
  }
}

function modifyUsers(users, sortedList, observer, config) {
  observer.disconnect();
  users.innerHTML = "";
  sortedList.forEach((user) => {
    users.appendChild(user);
  });
  observer.observe(users, config);
}

/**
 * Method that sorts the user list by the last-message timestamp
 */
function sortByLastMessage(users) {
  const userList = users.querySelectorAll(".user");

  const sortedList = Array.from(userList).sort((a, b) => {
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
