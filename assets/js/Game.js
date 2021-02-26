import React, { useState, useEffect } from 'react';
import { ch_join, ch_push, setChannel, connectChannel } from "./socket"
import _ from "lodash";
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

const NavBar = ({gameName, playerName, playerType, ready, running}) => {
  const [game, setGame] = useState("");
  const [username, setUsername] = useState("");

  const setupPlayer = () => {
    setChannel(game, username);
    connectChannel(username);
    console.log("All connected")
    ch_push({username: username}, 'info')
  }

  const joinAsPlayer = () => {
    ch_push('', 'become_player');
  }

  const becomeObserver = () => {
    ch_push('', 'become_observer');
  }

  const leaveGame = () => {
    ch_push('', 'logout');
  }

  const handleReadyCheck = () => {
    ch_push('', 'toggle_ready');
  }

  if (playerType === "observer" || playerType === "player") {
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
          {(playerType === "observer") &&
            <button className="button" disabled={running} onClick={joinAsPlayer}>Join As Player</button>
          }
          {(playerType == "player") &&
            <button className="button" disabled={running} onClick={becomeObserver}>Become Observer</button>
          }
          {(playerType == "player" && !running) &&
            <span>
              Ready?
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
    console.log("EFFECT")
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
  let playerGuesses = [];
  if (!_.isEmpty(state.players) && state.type == "player") {
    console.log('state user: ', state.user)
    console.log('state players: ', state.players)
    playerGuesses = state.players[state.user].results;
  }
  console.log('player guesses: ', playerGuesses)

  let mainContent = null;


  if (state.winners) {
    if (state.type == "player") {
      mainContent =
        <div className="container">
          <div className="row">
            <div className="column column-33">
              <h2>Current Turn: {state.turn}</h2>
            </div>
          </div>
          <div className="row">
            {(state.winners.indexOf(state.user) >= 0) ?
              <h2>You were a winner!</h2> : <h2>You lost the game :(</h2>
            }
          </div>
        </div>
    } else {
      mainContent =
      <div className="container">
        <div className="row">
          <div className="column column-33">
            <h2>Current Turn: {state.turn}</h2>
          </div>
        </div>
        <div className="row">
          <h2>The winners are:</h2>

          <ul>
            {state.winners.map(winner => {
              return (
                <li>
                  <span>{winner}</span>
                </li>
              )
            })}
          </ul>
        </div>
      </div>
    }
    // game over
  } else if (state.running) {
    mainContent =
      <div className="container">
        <div className="row">
          <div className="column column-33">
            <h2>Current Turn: {state.turn}</h2>
          </div>
        </div>
        {(state.type == "player") &&
        <span>
          <Error errString={state.players[state.user].errString}/>
          <Controls resetGame={resetGame} guess={guess}/>
          <div className="row">
            <div className="column column-10"></div>
            <div className="column column-20"><h4>Guess</h4></div>
            <div className="column column-25"><h4>Result</h4></div>
          </div>
        </span>
        }
        {(state.type == "player") &&
          playerGuesses.map((result, index) => {
            return (
              <div className="row" key={index}>
                <div className="column column-10"></div>
                <div className="column column-20"><b>{result.guess}</b></div>
                <div className="column column-25"><b>{`${result.bulls} bulls, ${result.cows} cows`}</b></div>
              </div>
            );
          })
        }
        <div className="row">OTHER GUESSES</div>
        <div className="row">
          <div className="column column-10">Turn</div>
          <div className="column column-15">Username</div>
          <div className="column column-10"><h4>Guess</h4></div>
          <div className="column column-25"><h4>Result</h4></div>
        </div>
        {
          state.guesses.filter(g => g.user != state.user).map((guess, index) => {
            return (
              <div className="row" key={index}>
                <div className="column column-10">{guess.turn}</div>
                <div className="column column-15">{guess.user}</div>
                <div className="column column-10"><b>{guess.guess}</b></div>
                <div className="column column-25"><b>{`${guess.bulls} bulls, ${guess.cows} cows`}</b></div>
              </div>
            )
          })
        }
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
      <NavBar playerType={state.type} gameName={state.game} playerName={state.user} ready={state.ready} running={state.running}/>
      {mainContent}
    </div>
  );
}

export default Game;
