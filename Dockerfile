# Taken from https://github.com/sagemath/sage-binder-env/
FROM sagemath/sagemath:8.1
COPY --chown=sage:sage . ${HOME}
