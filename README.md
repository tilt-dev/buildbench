# Docker-Golang Build Demos

Do you build in Docker for local development?

Here are tips and tricks for making your build 10x faster, with example code.

For more detail on how these tricks work, [read this blog post](https://medium.com/p/4cc618a43827).

## Usage

Install Docker and Python3. Run

```
make profile
```

to run a set of incremental docker builds with different build-optimization techniques.

When the builds finish, you should get results that look like this:

```
Make naive: 51.616401s
Make cachedeps: 25.491433s
Make cacheobjs: 12.217298s
Make tailybuild: 2.723723s
Make tailymount: 2.180016s
Make naked: 1.906474s
```

Numbers may vary based on hardware, operating system, and Docker version.

## License

Copyright 2018 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)
