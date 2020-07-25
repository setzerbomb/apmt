# Almost Persistent Mining Turtle

This project tries to create a Persistent Mining Turtle with [ComputerCraft](http://www.computercraft.info/wiki/Main_Page), a modification to create programmable entities (computers and turtles) for Minecraft™. Check the [post](http://www.computercraft.info/forums2/index.php?/topic/29648-apmt-almost-persistent-mining-turtle) on CC Forum.

## Getting Started

These instructions will get you a copy of the project up and running on your turtle for development, testing and block mining purposes.

### Prerequisites

This project was designed to run on ComputerCraft 1.7.5 at Minecraft 1.7.10 version or superior

```
* Minecraft 1.7.10
* ComputerCraft 1.7.5
* Minecraft Forge compatible with 1.7.10 version
```

### Installing

The easy way, direct to your turtle. [Thanks to Bomb Bloke](http://www.computercraft.info/forums2/index.php?/user/15121-bomb-bloke/)

```
pastebin get cUYTGbpb bbpack
bbpack mount https://github.com/setzerbomb/apmt/tree/master install
cp install\turtle turtle
cp install\gps gps
mv turtle\startup startup
reboot
```

The hard way:

- 1: Clone the repo on your machine and put the turtle folder at a folder related to a turtle on your minecraft world
- 2: Move the startup file inside the turtle folder to the previous folder (the folder related to your turtle)
- 3: Reboot your turtle and put some fuel [coal/lava] at any slot

```
git clone git@github.com:setzerbomb/apmt.git
cp .../apmt/turtle turtle_folder_location
```

## Running the tests

This code is a bit old, it comes from a time that I wasn't familiar with automated testing. Feel free to execute all funcionalities that it provides and if you find a bug, report it here or share your fix with us.

## Contributing

Feel free to contribute with the project, these are the guidelines:

* Create and run some tests to ensure that your code works as you espect
* The code uses prototypes and some OO concepts, make sure that your code is written similar or better

## Next Goals

- Improve the documentation

## Versioning

This project uses some core [Semantic Versioning](https://semver.org/) principles

## Authors

* **Set** - *All work until now* - [setzerbomb](https://github.com/setzerbomb)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
