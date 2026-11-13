# verl + Spacemacs: the verl image with the editor folder added. Nothing else.
#
# Everything about the editor is decided in docker/ubuntu24 (spacemacs-u24).
# This file only composes: one folder, one PATH entry. No apt packages, no
# settings, no order rules. verl's own python, uv and .venv are left alone.
#
#   docker build -t verl-spacemacs docker/verl
#   docker run --rm -it --gpus all verl-spacemacs      # then: emacs
ARG VERL=verlai/verl:uv.cu130.dev5
ARG SPACEMACS=spacemacs-u24:latest
FROM ${SPACEMACS} AS spacemacs
FROM ${VERL}
COPY --from=spacemacs /opt/spacemacs /opt/spacemacs
ENV PATH=/opt/spacemacs/bin:$PATH
