# Taken from https://github.com/sagemath/sage-binder-env/
FROM sagemath/sagemath:8.2
COPY --chown=sage:sage . ${HOME}
