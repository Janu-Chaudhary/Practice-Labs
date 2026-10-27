# Solution - 10-quiz-secret-env-file

## 1. See the leak
```bash
cd work
docker history --no-trunc lab10-payments:1.0 | grep ENV   # ENV DB_PASSWORD=Summer2024!  <- in the metadata
docker image inspect -f '{{json .Config.Env}}' lab10-payments:1.0   # [..., "DB_PASSWORD=Summer2024!"]
docker run --rm lab10-payments:1.0 cat /app/.env           # DB_PASSWORD=Summer2024!  <- COPY . . copied .env in
```
Two separate leaks: `ENV` writes the value into the image config (every layer step is listed by
`docker history`), and `COPY . .` with no `.dockerignore` copies `.env` into a layer.

## 2-3. Fix and rebuild
Edit `Dockerfile` (`code Dockerfile`) and delete the two `ENV DB_...` lines:
```dockerfile
FROM node:24-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```
```bash
printf '.env\nnode_modules\n.git\n' > .dockerignore   # keep these out of the build context
docker build -t lab10-payments:1.1 .                 # the "." context no longer contains .env
docker run --rm lab10-payments:1.1 cat /app/.env     # cat: can't open '/app/.env': No such file  (good)
```

## 4-5. Run with the config from the environment
```bash
docker run -d --name lab10-payments -p 127.0.0.1:8110:3000 --env-file .env lab10-payments:1.1
curl http://127.0.0.1:8110/health      # payments ok db=db.internal password=set
```
- `--env-file .env` reads every `KEY=value` line of the file on the **host** and sets them as
  environment variables of the container at start. The image stays secret-free and the same image
  can run with other settings (test DB, prod DB): one build, config in the environment (Factor III).
- Same result, longer: `-e DB_HOST=db.internal -e 'DB_PASSWORD=Summer2024!'`.

## 6. Remove the leaky tag
```bash
docker image rm lab10-payments:1.0     # Untagged: lab10-payments:1.0 / Deleted: sha256:...
docker image ls lab10-payments         # only 1.1
```

## Common wrong attempts
- Running 1.1 with no env flag -> `docker ps` is empty; `docker ps -a` shows `Exited (1)`;
  `docker logs lab10-payments` says `FATAL: DB_HOST and DB_PASSWORD must be set`. Then the name is
  taken: `docker rm lab10-payments` before the next `docker run`.
- `--env-file .env` placed **after** the image -> it becomes the command; the container exits.
- Only adding `.dockerignore` but keeping `ENV DB_PASSWORD=...` -> no file, but `docker history`
  and `docker image inspect` still show the password.
- Only deleting the `ENV` lines -> `docker run --rm lab10-payments:1.1 cat /app/.env` still prints it.
- Replacing `ENV` with `ARG DB_PASSWORD=...` -> build args are also recorded in `docker history`.
- Adding `RUN rm .env` after `COPY . .` -> the file is still in the earlier `COPY` layer. Layers are
  only added, never edited. Keep it out of the context instead.
- Writing `DB_PASSWORD="Summer2024!"` in the env file -> `--env-file` keeps the quotes as part of the
  value. Write plain `KEY=value` lines.
- `-e DB_PASSWORD=Summer2024!` inside double quotes in an interactive bash can trigger `!` history
  expansion in some positions; single quotes are always safe.
- `docker image rm lab10-payments:1.0` while a container still uses it -> `conflict: unable to
  delete ... image is being used by ...container`. Remove that container first.
- Note: `docker inspect lab10-payments` (the **container**) does show the password. That's expected:
  the container needs it. The goal is that the **image** you share doesn't contain it.
