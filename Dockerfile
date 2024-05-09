FROM node:20-slim AS builder
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /code
COPY . .
RUN --mount=type=cache,target=/pnpm/store,sharing=locked \
  pnpm install --frozen-lockfile
RUN --mount=type=cache,target=/code/.svelte-kit,sharing=locked \
  pnpm build
RUN pnpm prune --prod

FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /runtime
COPY --from=builder /code/build .
COPY --from=builder /code/node_modules ./node_modules
COPY --from=builder /code/package.json ./package.json
COPY --from=builder /code/static ./static
EXPOSE 3000
CMD ["index.js"]
