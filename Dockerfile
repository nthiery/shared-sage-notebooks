# Dockerfile for binder
# References:
# - https://mybinder.readthedocs.io/en/latest/dockerfile.html#preparing-your-dockerfile
# - https://github.com/sagemath/sage-binder-env/blob/master/Dockerfile

FROM sagemath/sagemath:8.4
RUN sage -pip install jupyterlab
RUN sage -pip install RISE
RUN echo "jupyter-nbextension install rise --py --sys-prefix" | sage -sh
RUN echo "jupyter-nbextension enable rise --py --sys-prefix" | sage -sh

# Copy the contents of the repo in ${HOME}
COPY --chown=sage:sage . ${HOME}
