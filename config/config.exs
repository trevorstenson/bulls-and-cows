# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :bulls_hw06, BullsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "E5bdnq2I+huiSeIxerSoG4Kvn42A1+3jh/eAwm/LH5tV95EM/dEZuaCoKz27hTBG",
  render_errors: [view: BullsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bulls.PubSub,
  live_view: [signing_salt: "naCP4vXy"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
