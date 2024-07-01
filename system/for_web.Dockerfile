################# Variables ################
ARG ELIXIR_VERSION=1.16.2
ARG OTP_VERSION=26.2.3
ARG DEBIAN_VERSION=bullseye-20240130-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

ARG CORE_APP=swai_core
ARG SVC_APP=swai
ARG WEB_APP=swai_web
ARG APIS_APP=apis

RUN apt-get update -y && \
    apt-get install -y build-essential git npm esbuild  && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*


# prepare build dir
WORKDIR /build_space

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ARG MIX_ENV=prod
ENV MIX_ENV=prod

ENV OTPROOT=/usr/lib/erlang
ENV ERL_LIBS=/usr/lib/erlang/lib

# copy umbrella apps
COPY apps/${SVC_APP} apps/${SVC_APP}/
COPY apps/${CORE_APP} apps/${CORE_APP}/
COPY apps/${WEB_APP} apps/${WEB_APP}/
COPY apps/${APIS_APP} apps/${APIS_APP}/



COPY config/config.exs config/prod.exs config/runtime.exs  config/

COPY mix.exs mix.lock ./

# install mix dependencies
RUN MIX_ENV="prod" mix do deps.get --only "prod", deps.compile

# build assets
 COPY apps/${WEB_APP} ./apps/${WEB_APP}
# COPY apps/${WEB_APP}/assets/package.json apps/${WEB_APP}/assets/package-lock.json ./apps/${WEB_APP}/assets/
# COPY apps/${WEB_APP}/priv apps/${WEB_APP}/priv/
# COPY apps/${WEB_APP}/priv ./priv
# COPY apps/${WEB_APP}/assets ./assets


# # COPY apps/${WEB_APP}/assets apps/${WEB_APP}/assets/
RUN npm install -y --prefix ./apps/${WEB_APP}/assets

RUN npm --prefix ./apps/${WEB_APP}/assets ci --progress=false --no-audit --loglevel=error

RUN npm run --prefix ./apps/${WEB_APP}/assets deploy


# RUN cd ./apps/${WEB_APP}/ 

RUN mix phx.digest.clean --all && \
    mix phx.digest 

RUN mix assets.deploy

# RUN MIX_ENV="prod" mix ecto.drop && \
#     MIX_ENV="prod" mix ecto.create && \
#     MIX_ENV="prod" mix ecto.migrate

# RUN mix do deps.get, deps.compile, 
RUN MIX_ENV="prod" mix compile && \
    MIX_ENV="prod" mix release for_web

# RUN cd ../../

########### RUNTIME ###############
# prepare release image
FROM ${RUNNER_IMAGE} AS for_web

ARG SVC_APP=swai
ARG WEB_APP=swai_web

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates  && \
    apt-get clean && rm -f /var/lib/apt/lists/*_* 

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

RUN echo ${SWAI_DB_URL}

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /system

# USER root

RUN chown nobody /system


COPY --from=builder --chown=nobody /build_space/_build/prod/rel/for_web .

COPY apps/${WEB_APP}/rel/overlays/bin/migrate ./bin/migrate
COPY apps/${WEB_APP}/rel/overlays/bin/server ./bin/server
COPY apps/${WEB_APP}/rel/overlays/bin/start ./bin/start

USER nobody

ENV HOME=/system
# ENV DATABASE_PATH=/system/agrex_db
ENV MIX_ENV="prod"
ENV SWAI_SECRET_KEY_BASE="VSPmDkSEzRV15zRVBe5gPhOanomTMTvrjgNeKQTzcSd5N+YnUTNRT9C0xTrZzMK0"

EXPOSE 4000

ENTRYPOINT ["/system/bin/start"]