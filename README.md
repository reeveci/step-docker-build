# Reeve CI / CD - Pipeline Step: Docker Build

This is a [Reeve](https://github.com/reeveci/reeve) step for building and publishing Docker images.

The step performs a test by default to check if an image with the requested tag already exists.
This prevents accidental overwriting of existing images.

The test can either be performed by checking the image's manifest (default), which doesn't require the image to be downloaded, or by performing a pull.

## Configuration

See the environment variables mentioned in [Dockerfile](Dockerfile).
