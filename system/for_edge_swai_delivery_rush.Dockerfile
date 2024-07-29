################# Variables ################
ARG ELIXIR_VERSION=1.17.2
ARG OTP_VERSION=27.0.1
ARG DEBIAN_VERSION=bullseye-20240722-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

################# BUILDER ################
FROM ${BUILDER_IMAGE} AS builder

ARG CORE_APP=swai_core
ARG APIS_APP=apis
ARG EDGE_APP=swai_edge_delivery_rush

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
COPY apps/${APIS_APP} apps/${APIS_APP}/
COPY apps/${CORE_APP} apps/${CORE_APP}/
COPY apps/${EDGE_APP} apps/${EDGE_APP}/

COPY config/config.exs config/prod.exs config/runtime.exs  config/
COPY mix.exs mix.lock ./
# install mix dependencies
RUN MIX_ENV="prod" mix do deps.get --only "prod", deps.compile
# build assets
COPY apps/${EDGE_APP} ./apps/${EDGE_APP}

RUN MIX_ENV="prod" mix compile && \
    MIX_ENV="prod" mix release for_edge

################ NORDVPN_IMAGE ################

FROM ${RUNNER_IMAGE} as nordvpn

RUN apt-get update && \
    apt-get install -y wget iputils-ping curl && \
    wget -O /tmp/nordrepo.deb https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb && \
    apt-get install -y /tmp/nordrepo.deb && \
    apt-get update && \
    apt-get install -y nordvpn=3.17.1 && \
    apt-get remove -y wget nordvpn-release && \
    rm /tmp/nordrepo.deb && \
    apt-get clean

# ENTRYPOINT /etc/init.d/nordvpn start && sleep 5 && /bin/bash -c "$@"
# CMD systemctl enable --now nordvpnd




########### RUNTIME ###############
# prepare release image
# FROM nordvpn as for_edge
FROM ${RUNNER_IMAGE} AS for_edge

ARG CORE_APP=swai_core
ARG EDGE_APP=swai_edge_delivery_rush
ARG APIS_APP=apis

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates curl systemd && \
    apt-get clean && rm -f /var/lib/apt/lists/*_* 



# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen



ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /system

RUN chown nobody /system

COPY --from=builder --chown=nobody /build_space/_build/prod/rel/for_edge .

COPY run-edge.sh .

RUN chmod +x run-edge.sh

# RUN which nordvpn

# RUN mkdir /run/nordvpn

# # RUN mkdir /var/log/nordvpn

# RUN chown nobody /etc/init.d/nordvpn

# RUN chown nobody /run/nordvpn

# RUN chown nobody /var/log/nordvpn

# RUN usermod -aG nordvpn nobody

USER nobody


ENV HOME=/system
ENV MIX_ENV="prod"

ENV SWAI_DB_URL="irrelevant"
ENV SWAI_SECRET_KEY_BASE="irrelevant"
ENV SWAI_SCAPE_ID="5693504a-89d6-4af3-bb70-2c2914913dc9"

# ENTRYPOINT [ "/bin/bash", "-c", "/etc/init.d/nordvpn start && sleep 20 && ./run-edge.sh" ]


# CMD ["/system/bin/for_edge", "start"]

CMD ["./run-edge.sh"]

