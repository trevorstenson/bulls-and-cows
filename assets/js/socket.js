import {Socket} from "phoenix";

let socket = new Socket("/socket", {params: {token: window.userToken}});

// Finally, connect to the socket:
socket.connect();

let gameChannel = null;

const setChannel = (gameName, userName) => {
  gameChannel = socket.channel(`game:${gameName}`, {username: userName});
};

const connectChannel = (userName) => {
  gameChannel.join()
             .receive("ok", state_update)
             .receive("error", resp => {
               console.log("Unable to join", resp);
             });

  gameChannel.on("update", state_update);
  gameChannel.on("game_over", state_update);
};

let state = {
  user: "",
  game: "",
  results: [],
  remaining: 8,
  errString: "",
  gameWon: false,
  type: null
};

let callback = null;

const state_update = (st) => {
  console.log(Date.now())
  console.log('new state', st);
  state = st;
  if (callback) {
    callback(st);
  }
};

const ch_join = (cb) => {
  callback = cb;
  callback(state);
};

const ch_push = (data, type) => {
  gameChannel.push(type, data)
             .receive("ok", state_update)
             .receive("error", resp => {
               console.log("Unable to push", resp);
             });
};

export {ch_join, ch_push, setChannel, connectChannel};

// export default socket;
