FROM elixir:1.6

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs config/ /app

RUN mix deps.get

VOLUME ./ /app

CMD mix run --no-halt
