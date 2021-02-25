import React, { useState, useEffect } from 'react';
import { ch_join, ch_push, setChannel, connectChannel } from "./socket"
import '../css/Game.scss'

const Controls = ({resetGame, guess}) => {
  const [input, setInput] = useState("");

  const catchEnter = (e) => {
    if (e.key === "Enter") {
      submitGuess(input);
    }
  };

  const submitGuess = (input) => {
    guess(input);
    setInput("");
  }

  return (
      <div className="row">
        <div className="column column-10">
          <h3>Input:</h3>
        </div>
        <div className="column column-20">
          <input type="text" value={input} onChange={e => setInput(e.target.value)} onKeyPress={catchEnter} maxLength="4"/>
        </div>
        <div className="column column-25">
          <button className="button" onClick={() => submitGuess(input)}>Guess</button>
          <button className="button" onClick={resetGame}>Reset</button>
        </div>
      </div>
  );
}

const Error = ({errString}) => {
  if (errString === "") {
    return null;
  } else {
    return (
      <div id="errorRow" className="row">
        <div className="column column-33">
          <b>{errString}</b>
        </div>
      </div>
    );
  }
}

const Outcome = ({won, reset}) => {
  let endMsg = won ? "You won!" : "You lost!";
  return (
    <div className="container">
      <div className="row">
        <div className="column column-50">
          <h2>{endMsg}</h2>
        </div>
      </div>
      <div className="row">
        <div className="column column-25">
          <button className="button" onClick={reset}>Reset Game</button>
        </div>
      </div>
    </div>
  );
}

const NavBar = ({gameName, playerName, playerType, ready}) => {
  const [game, setGame] = useState("");
  const [username, setUsername] = useState("");

  const setupPlayer = () => {
    console.log('setting up')
    // new Promise((resolve, reject) => {
    //   return setChannel(game, username)
    // }).then(() => {
    //   return connectChannel();
    // }).then(() => {
    //   return ch_push({username: username}, 'info')
    // })

    setChannel(game, username);
    connectChannel(username);
    // ch_push({username: username}, 'info')

    
    
    // setTimeout(() => {
    //   console.log("ASLKNSDKJNSDKJ")
    //   ch_push({username: username}, 'info')
    // }, 8000)
    // ch_push({username: username}, 'info');

  }

  const joinAsPlayer = () => {
    ch_push('', 'become_player');
  }

  const becomeObserver = () => {
    ch_push('', 'become_observer');
  }

  const leaveGame = () => {
    // gameChannel = socket.channel('game:lobby', {});
    ch_push('', 'logout');
  }

  const handleReadyCheck = () => {
    ch_push('', 'toggle_ready');
  }

  if (playerType == "observer" || playerType == "player") {
    return (
      <span>
      <div id="navbar" className="row">
        <div className="column">
          <span>Current Game: {gameName}</span>
        </div>
        <div className="column">
          <span>Current Username: {playerName}</span>
        </div>
      </div>
        <div className="row-center">
          {(playerType == "observer") &&
            <button className="button" onClick={joinAsPlayer}>Join As Player</button>
          }
          {(playerType == "player") &&
            <button className="button" onClick={becomeObserver}>Become Observer</button>
          }
          {(playerType == "player") &&
            <span>Ready?
              <input type="checkbox"
                checked={ready}
                onChange={handleReadyCheck}
            /></span>
          }
        <button className="button" onClick={leaveGame}>Leave Game</button>
        </div>
      </span>
    );
  } else {
    return (
      <span>
      <div id="navbar" className="row">
        <div className="column">
          <label htmlFor="game">Game:</label>
          <input type="text" id="game" onChange={e => setGame(e.target.value)}/>
        </div>
        <div className="column">
          <label htmlFor="username">Username:</label>
          <input type="text" id="username" onChange={e => setUsername(e.target.value)}/>
        </div>
      </div>
        <div className="row-center">
          <button className="button" id="login-button" onClick={setupPlayer}>Login</button>
        </div>
      </span>
    );
  }
}

const Game = () => {
  // setup to be called later
  const [state, setState] = useState({
    user: "",
    game: "",
    results: [],
    errString: "",
    gameWon: false,
    type: null
  })

  useEffect(() => {
    ch_join(setState);
  })

  const resetGame = () => {
    ch_push('', 'reset');
  }

  const guess = (guess) => {
    ch_push(guess, 'guess');
  }

  const isGameWon = state.gameWon;
  const isGameLost = !state.gameWon; //Fixme: New rules for won vs lost due to new game rules

  // yes ik this is ugly but functionality first beauty later \o/
  let mainContent = null;

  if (state.running) {
    mainContent =
      <div className="container">
        <div className="row">
          <div className="column column-33">
            <h2>Guesses Remaining: {state.remaining}</h2>
          </div>
        </div>
        <Error errString={state.errString}/>
        <Controls resetGame={resetGame} guess={guess}/>
        <div className="row">
          <div className="column column-10"></div>
          <div className="column column-20"><h4>Guess</h4></div>
          <div className="column column-25"><h4>Result</h4></div>
        </div>
        {state.results.map((result, index) => {
          return (
            <div className="row" key={index}>
              <div className="column column-10"></div>
              <div className="column column-20"><b>{result.guess}</b></div>
              <div className="column column-25"><b>{`${result.bulls} bulls, ${result.cows} cows`}</b></div>
            </div>
          );
        })}
      </div>
  } else if (!state.type) {
    // not in a game
    mainContent =
      <div className="container">
        <div className="row">
          <h2>Please join a game.</h2>
        </div>
      </div>
  } else if (!state.running && !state.ready) {
    // game not started and user needs to ready up
    mainContent =
      <div className="container">
        <div className="row">
          <h2>Game has not started. Please ready up!</h2>
        </div>
      </div>
  } else if (!state.running) {
    // waiting for other users
    mainContent =
      <div className="container">
        <div className="row">
          <h2>Waiting for other players to ready up.</h2>
        </div>
      </div>
  } else if (isGameWon) {
    mainContent = <Outcome won={true} reset={resetGame}/>
  } else if (isGameLost) {
    mainContent = <Outcome won={false} reset={resetGame}/>
  }

  return (
    <div className="App">
      <NavBar playerType={state.type} gameName={state.game} playerName={state.user} ready={state.ready}/>
      {mainContent}
    </div>
  );
}

export default Game;
