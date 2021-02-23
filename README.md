# Bulls

## TODO

Support multiple concurrent games:

- [ ] When a user first visits your site, they should be able to enter a game name.
- [ ] Users who select different game names should be able to play completely independent games of Bulls and Cows concurrently.
- [ ] There should be a UI element that lets players leave a game and get back to the game name entry screen.

Support multiple concurrent users of each game. This changes the game flow as follows:

- [ ] Arriving user enters game name and user name.
- [ ] Games start in setup mode, where multiple users can join before play starts.
- [ ] In setup mode, each user can chose to either be a player or an observer and if they are a player they can toggle if they’re ready.
- [ ] Once all players are ready, the game starts.
- [ ] Anyone who joins after the game starts is an observer.
- [ ] Observers can see what’s happening, but can’t play.
- [ ] Guessing happens in turns. In each turn, first all players make a guess concurrently, and then all guesses, who made them, and their bulls/cows scores are
- [ ] shown to everyone.
- [ ] Players should be able to “Pass”, or make no guess for a turn.
- [ ] Players have 30 seconds to make a guess or they automatically pass.
- [ ] Whoever guesses the right number first wins. Multiple winners can happen if multiple players guess the answer on the same turn.
- [ ] Once someone wins, the game goes back to setup mode, displaying who the last winners were and the win/loss count of each user.
- [ ] At least four players should be supported, with unlimited observers.
- [ ] Players should be able to leave a game and rejoin by simply entering the same name.
- [ ] Win/loss counts last until the server restarts.
- [ ] Mechanics inconsistent with this flow from the single player version - like losing after 8 bad guesses - don’t carry over.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
