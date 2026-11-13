# docker/

Three images. Each folder is named after the image it builds.

| Image | Base | What it is for | Config and packages |
|---|---|---|---|
| `spacemacs-dev` | Debian 13 | Develop and test this config without touching the host Emacs | Mounted from the host; packages are downloaded on first start |
| `spacemacs-u24` | Ubuntu 24.04 | The finished editor as one self-contained folder, `/opt/spacemacs` | Inside the image, made at build time; no network needed at start |
| `verl-spacemacs` | `verlai/verl:uv.cu130.dev5` | verl with the editor added | Copied from `spacemacs-u24` |

## File map

<table>
<tr><th>Folder (= image)</th><th>Part</th><th>File</th><th>Runs</th><th>What it does</th></tr>

<tr><td rowspan="2"><code>spacemacs-dev/</code></td><td rowspan="2">top</td>
    <td><code>Dockerfile</code></td><td>image build</td>
    <td>Debian 13 with Emacs 30 from Debian, uv, rustup, tmux. Holds no config and no packages.</td></tr>
<tr><td><code>run.sh</code></td><td>on the host</td>
    <td>Builds the image once, starts the container and attaches. Mounts this config at <code>/root/.spacemacs.d</code>, a volume at <code>/root/.emacs.d</code>, and <code>$REPOS</code> at <code>/work</code>.</td></tr>

<tr><td rowspan="8"><code>spacemacs-u24/</code></td><td rowspan="2">top</td>
    <td><code>Dockerfile</code></td><td>image build</td>
    <td>Three stages: compile Emacs 30.2 and make it relocatable; collect the tools; put everything in <code>/opt/spacemacs</code> and run <code>build/bake.sh</code>. Versions are pinned here.</td></tr>
<tr><td><code>run.sh</code></td><td>on the host</td>
    <td>Builds the image once, starts the container and opens a shell. <code>REPOS</code> mounts code at <code>/work</code>; <code>LIVE_CONFIG=1</code> mounts this config over the one in the image.</td></tr>
<tr><td rowspan="4"><code>build/</code><br>files the Dockerfile uses</td>
    <td><code>bundle-tools.sh</code></td><td>stage 2</td>
    <td>Copies rg, fd, jq and aspell (with its dictionary and libraries) out of Ubuntu packages into <code>/opt/spacemacs/tools</code>.</td></tr>
<tr><td><code>emacs-launcher.sh</code></td><td>every start</td>
    <td>Becomes <code>/opt/spacemacs/bin/emacs</code>. Sets the config path, the tool PATH and git's safe directory for Emacs only, then starts Emacs.</td></tr>
<tr><td><code>bake.sh</code></td><td>stage 3</td>
    <td>Installs all packages, checks a second start installs nothing, compiles packages to native code, runs a warm-up session, then checks the result. The build fails if any step fails.</td></tr>
<tr><td><code>native-compile-all.el</code></td><td>by <code>bake.sh</code></td>
    <td>Tells Emacs to native-compile every installed package and waits until it is done.</td></tr>
<tr><td rowspan="2"><code>test/</code><br>not in the image</td>
    <td><code>verify.sh</code></td><td>by hand, in a container</td>
    <td>Drives a real terminal Emacs through four repos in <code>/work</code> (verl, vllm, Megatron-LM, transformers) and a JSON file; logs each step and the reply time of Emacs every 0.3 s.</td></tr>
<tr><td><code>helpers.el</code></td><td>by <code>verify.sh</code></td>
    <td>Small Emacs functions the test calls: server state, diagnostics, hover, completion.</td></tr>

<tr><td><code>verl-spacemacs/</code></td><td>top</td>
    <td><code>Dockerfile</code></td><td>image build</td>
    <td><code>FROM</code> verl, one <code>COPY</code> of <code>/opt/spacemacs</code>, one <code>PATH</code> line. Nothing else.</td></tr>
</table>

One file outside this folder belongs here too: `../.dockerignore` keeps `docs/`,
`test/`, this README and the other two image folders out of the `spacemacs-u24`
build, so editing them does not trigger a rebuild.

## Commands

Run these from the `spacemacs/` directory.

| Goal | Command |
|---|---|
| Build the editor image | `docker build -t spacemacs-u24 -f docker/spacemacs-u24/Dockerfile .` |
| Build verl with the editor | `docker build -t verl-spacemacs docker/verl-spacemacs` |
| Start the editor container | `REPOS=/path/to/code docker/spacemacs-u24/run.sh emacs` |
| Start the development container | `REPOS=/path/to/code docker/spacemacs-dev/run.sh` |
| Test an image | Copy `docker/spacemacs-u24/test/` to `/work/_verify` in the container, then `bash /work/_verify/verify.sh <label>`. Logs go to `/work/_verify/logs/<label>/`. |

## Rules

- `spacemacs-u24` owns everything the editor needs. An image that takes the
  folder needs only `git`, and must keep the folder at `/opt/spacemacs`
  (native code is tied to that path).
- `verl-spacemacs` only composes. Do not add packages or settings there.
- x86_64 only.

How and why it was built this way: `../docs/spacemacs-u24-dev-notes.html`.
