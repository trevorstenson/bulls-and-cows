import React, { useState, useEffect } from 'react';
import { ch_join, ch_push } from "./socket"
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

const NavBar = ({loggedIn}) => {
  const [game, setGame] = useState("");
  const [username, setUsername] = useState("");

  const setupPlayer = () => {
    ch_push({username: username, game: game}, 'new_player');
  }

  return (
    <div id="navbar">
      <input type="text" onChange={e => setGame(e.target.value)}/>
      <input type="text" value={"will style later"} onChange={e => setUsername(e.target.value)}/>
      <button className="button" onClick={setupPlayer}>Login</button>
    </div>
  )
}

const Game = () => {
  // setup to be called later
  const [state, setState] = useState({
    results: [],
    errString: "",
    gameWon: false
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

  if (isGameWon) {
    mainContent = <Outcome won={true} reset={resetGame}/>
  } else if (isGameLost) {
    mainContent = <Outcome won={false} reset={resetGame}/>
  } else {
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
  }

  return (
    <div className="App">
      <NavBar/>
      {mainContent}
    </div>
  );
}

export default Game;
