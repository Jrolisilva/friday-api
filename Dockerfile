FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

ENV APP_HOME=/rails \
    RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test"

WORKDIR ${APP_HOME}

# Pacotes de runtime mínimos
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libjemalloc2 \
      tzdata \
      ca-certificates \
      openssl \
      curl && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# ---- Fase de build (gems + bootsnap) ---------------------------------------
FROM base AS build

# Pacotes de compilação (removidos na imagem final)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      pkg-config && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Instalação das gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=4 --retry=3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Código da aplicação
COPY . .

# Pré-compila o bootsnap da app (Assets não são usados em API)
RUN bundle exec bootsnap precompile app/ lib/

# ---- Imagem final ----------------------------------------------------------
FROM base

# Copia gems e código já prontos
COPY --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build /rails /rails

# Usuário não-root
RUN groupadd --system --gid 1000 rails && \
    useradd  --system --uid 1000 --gid 1000 --home /rails --shell /usr/sbin/nologin rails && \
    chown -R rails:rails /rails ${BUNDLE_PATH}

USER rails:rails

# Puma expõe 3000
ENV PORT=3000
EXPOSE 3000

# Start
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
