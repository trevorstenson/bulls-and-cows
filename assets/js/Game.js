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
          <button className="button" onClick={e => submitGuess(input)}>Guess</button>
          <button className="button" onClick={resetGame}>Reset</button>
        </div>
      </div>
  );
}

const Error = ({errString}) => {
  if (errString  === "") {
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
          {/* <h2>{endMsg} The secret value was: {secret}</h2> */}
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

// const Game = () => {
//   const [state, setState] = useState({
//     secret: 3, // change back later
//     results: [],
//     remaining: 8,
//     errString: ""
//   })

//   const resetGame = () => {
//     setState({
//       secret: 3, // change back later
//       results: [],
//       remaining: 8,
//       errString: ""
//     })
//   }

//   const guess = (guess) => {
//     let nextResult = testSecret(guess, state.secret);
//     if (nextResult.errorMsg) {
//       setState({
//         ...state,
//         errString: nextResult.errorMsg
//       })
//     } else {
//       setState({
//         ...state,
//         results: [...state.results, nextResult],
//         remaining: state.remaining - 1,
//         errString: ""
//       })
//     }
//   }

//   const isGameWon = gameOver(state.secret, state.results);
//   const isGameLost = state.remaining === 0;
  
//   if (isGameWon) {
//     return <Outcome won={true} secret={state.secret} reset={resetGame}/>
//   } else if (isGameLost) {
//     return <Outcome won={false} secret={state.secret} reset={resetGame}/>
//   } else {
//     return (
//       <div className="App">
//         <div className="container">
//           <div className="row">
//             <div className="column column-33">
//               <h2>Guesses Remaining: {state.remaining}</h2>
//             </div>
//           </div>
//           <Error errString={state.errString}/>
//           <Controls resetGame={resetGame} guess={guess}/>
//           <div className="row">
//             <div className="column column-10"></div>
//             <div className="column column-20"><h4>Guess</h4></div>
//             <div className="column column-25"><h4>Result</h4></div>
//           </div>
//           {state.results.map((result, index) => {
//             return (
//               <div className="row" key={index}>
//                 <div className="column column-10"></div>
//                 <div className="column column-20"><b>{result.guess}</b></div>
//                 <div className="column column-25"><b>{result.hint}</b></div>
//               </div>
//             );
//           })}
//         </div>
//       </div>
//     );
//   }
// }

const Game = () => {

  

  const [state, setState] = useState({
    results: [],
    remaining: 8,
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
  const isGameLost = !state.gameWon && state.remaining === 0;
  
  if (isGameWon) {
    return <Outcome won={true} reset={resetGame}/>
  } else if (isGameLost) {
    return <Outcome won={false} reset={resetGame}/>
  } else {
    return (
      <div className="App">
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
                <div className="column column-25"><b>{result.hint}</b></div>
              </div>
            );
          })}
        </div>
      </div>
    );
  }
}

export default Game;