# Dockerfile for binder
# References:
# - https://mybinder.readthedocs.io/en/latest/dockerfile.html#preparing-your-dockerfile
# - https://github.com/sagemath/sage-binder-env/blob/master/Dockerfile

FROM sagemath/sagemath:9.0-py3
RUN sage -pip install jupyterlab
RUN sage -pip install RISE
RUN sage -jupyter nbextension install rise --py --sys-prefix
RUN sage -jupyter nbextension enable rise --py --sys-prefix

# Copy the contents of the repo in ${HOME}
COPY --chown=sage:sage . ${HOME}
