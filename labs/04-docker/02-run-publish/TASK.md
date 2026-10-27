# 02 - Run a container and publish a port (Drill)

**Context:** setup already built the image `greeter:1.0` (source in `work/greeter-src/`).
The server inside listens on port **3000** and replies `<GREETING> from greeter`.

**Task:**

1. Start a container from `greeter:1.0`:
   - in the background,
   - named `greeter-web`,
   - host port **8081** on **127.0.0.1 only** published to container port 3000,
   - with the environment variable `GREETING` set to `Hola`.
2. Check it with `docker ps` (look at the PORTS column) and `curl http://127.0.0.1:8081/`.

**Done when:** the container is running. Don't stop or remove it.

**Hints**
- Options (`-d`, `--name`, `-p`, `-e`) go **before** the image name. Anything after the image name
  is treated as the command to run inside the container.
- Port order is `HOST:CONTAINER`. The address prefix is `IP:HOST:CONTAINER`.
- Made a mistake? `docker rm -f greeter-web` and run again (the name must be free).

**What will be checked**
- container `greeter-web` is running from `greeter:1.0`
- port 3000/tcp is published to `127.0.0.1:8081`
- `GREETING=Hola` is set, and curl gets `Hola from greeter`
