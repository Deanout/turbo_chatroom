import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

// Broadcast Types
const JOIN_ROOM = "JOIN_ROOM";
const EXCHANGE = "EXCHANGE";
const REMOVE_USER = "REMOVE_USER";

// DOM Elements
let currentUser;
let localVideo;
let remoteVideoContainer;

// Objects
let pcPeers = {};
let localstream;

let connection;

// Ice Credentials
const ice = { iceServers: [{ urls: "stun:stun.l.google.com:19302" }] };

// Connects to data-controller="signaling-server"
export default class SignalingServer extends Controller {
  connect() {
    SignalingServer.setup();
  }
  static setup() {
    currentUser = document.getElementById("current-user").innerHTML;
    localVideo = document.getElementById("local-video");
    remoteVideoContainer = document.getElementById("remote-video-container");

    navigator.mediaDevices
      .getUserMedia({
        audio: true,
        video: true,
      })
      .then((stream) => {
        localstream = stream;
        localVideo.srcObject = stream;
        localVideo.muted = true;
      })
      .catch(this.logError);
  }
  handleJoinSession() {
    if (connection) {
      SignalingServer.setup();
      SignalingServer.broadcastData({
        type: JOIN_ROOM,
        from: currentUser,
      });
    } else {
      connection = consumer.subscriptions.create("SignalingServerChannel", {
        connected: () => {
          SignalingServer.broadcastData({
            type: JOIN_ROOM,
            from: currentUser,
          });
        },
        received: (data) => {
          if (data.from === currentUser) return;
          switch (data.type) {
            case JOIN_ROOM:
              return SignalingServer.joinRoom(data);
            case EXCHANGE:
              if (data.to !== currentUser) return;
              return SignalingServer.exchange(data);
            case REMOVE_USER:
              return SignalingServer.removeUser(data);
            default:
              return;
          }
        },
      });
    }
  }
  handleLeaveSession() {
    for (let user in pcPeers) {
      pcPeers[user].close();
    }
    pcPeers = {};

    remoteVideoContainer.innerHTML = "";

    SignalingServer.broadcastData({
      type: REMOVE_USER,
      from: currentUser,
    });
  }

  static joinRoom(data) {
    SignalingServer.createPC(data.from, true);
  }

  static removeUser(data) {
    let video = document.getElementById(`remoteVideoContainer+${data.from}`);
    video && video.remove();
    delete pcPeers[data.from];

    consumer.subscriptions
      .findAll("SignalingServerChannel")
      .forEach((channel) => {
        channel.unsubscribe();
      });

    consumer.subscriptions.remove(connection);
  }

  static createPC(userId, isOffer) {
    let pc = new RTCPeerConnection(ice);
    const element = document.createElement("video");
    element.id = `remoteVideoContainer+${userId}`;
    element.autoplay = "autoplay";
    remoteVideoContainer.appendChild(element);

    pcPeers[userId] = pc;

    for (const track of localstream.getTracks()) {
      pc.addTrack(track, localstream);
    }

    isOffer &&
      pc
        .createOffer()
        .then((offer) => {
          return pc.setLocalDescription(offer);
        })
        .then(() => {
          this.broadcastData({
            type: EXCHANGE,
            from: currentUser,
            to: userId,
            sdp: JSON.stringify(pc.localDescription),
          });
        })
        .catch(this.logError);

    pc.onicecandidate = (event) => {
      event.candidate &&
        SignalingServer.broadcastData({
          type: EXCHANGE,
          from: currentUser,
          to: userId,
          candidate: JSON.stringify(event.candidate),
        });
    };

    pc.ontrack = (event) => {
      if (event.streams && event.streams[0]) {
        element.srcObject = event.streams[0];
      } else {
        let inboundStream = new MediaStream(event.track);
        element.srcObject = inboundStream;
      }
    };

    pc.oniceconnectionstatechange = () => {
      if (pc.iceConnectionState == "disconnected") {
        this.broadcastData({
          type: REMOVE_USER,
          from: userId,
        });
      }
    };

    return pc;
  }
  static exchange(data) {
    let pc;

    if (!pcPeers[data.from]) {
      pc = SignalingServer.createPC(data.from, false);
    } else {
      pc = pcPeers[data.from];
    }

    if (data.candidate) {
      pc.addIceCandidate(new RTCIceCandidate(JSON.parse(data.candidate)))
        .then(() => console.log("Ice candidate added"))
        .catch(this.logError);
    }

    if (data.sdp) {
      const sdp = JSON.parse(data.sdp);
      pc.setRemoteDescription(new RTCSessionDescription(sdp))
        .then(() => {
          if (sdp.type === "offer") {
            pc.createAnswer()
              .then((answer) => {
                return pc.setLocalDescription(answer);
              })
              .then(() => {
                this.broadcastData({
                  type: EXCHANGE,
                  from: currentUser,
                  to: data.from,
                  sdp: JSON.stringify(pc.localDescription),
                });
              });
          }
        })
        .catch(this.logError);
    }
  }
  static broadcastData(data) {
    /**
     * Add CSRF protection: https://stackoverflow.com/questions/8503447/rails-how-to-add-csrf-protection-to-forms-created-in-javascript
     */
    const csrfToken = document.querySelector("[name=csrf-token]").content;
    const headers = new Headers({
      "content-type": "application/json",
      "X-CSRF-TOKEN": csrfToken,
    });

    window.data = data;

    // const queryString = window.location.search;
    // const urlParams = new URLSearchParams(queryString);
    // const id = urlParams.get("id");
    // const url = `/call${queryString}`;

    fetch("call", {
      method: "POST",
      body: JSON.stringify(data),
      headers,
    });
  }
  logError(error) {
    console.warn("Whoops! Error:", error);
  }
}
