# Dockerfile for binder
# References:
# - https://mybinder.readthedocs.io/en/latest/dockerfile.html#preparing-your-dockerfile
# - https://github.com/sagemath/sage-binder-env/blob/master/Dockerfile

FROM sagemath/sagemath:8.1

# Copy the contents of the repo in ${HOME}
COPY --chown=sage:sage . ${HOME}
