import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// Finally, connect to the socket:
socket.connect()

let channel = socket.channel("game:1", {});

let state = {
  results: [],
  remaining: 8,
  errString: "",
  gameWon: false
}

let callback = null;

const state_update = (st) => {
  console.log('new state', st)
  state = st;
  if (callback) {
    callback(st);
  }
}

export const ch_join = (cb) => {
  callback = cb;
  callback(state);
}

export const ch_push = (data, type) => {
  channel.push(type, data)
         .receive("ok", state_update)
         .receive("error", resp => { console.log("Unable to push", resp) });
}

channel.join()
       .receive("ok", state_update)
       .receive("error", resp => { console.log("Unable to join", resp) });

export default socket;
