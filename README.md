# About
A BrainF**K compiler written in Racket. Created by following [this tutorial](https://www.hashcollision.org/brainfudge/index.html) by [Dan Yoo](https://github.com/dyoo). His implementation, exactly as it appears in the tutorial, can be found [on GitHub](https://github.com/dyoo/brainfudge).

I've changed up some variable names, and also plan to make additional changes. I didn't fork his implemenation, since I wanted to re-write it by hand.

## Installing the Package
I didn't push up my package to the PLaneT package registry, and instead just opted to manually rebuild the package, and reference it by file. To make this simpler to work with, you can just run the included powershell script.

## Using the Package
After installing the package by file, you can simple include the reference to it at the top of your Dr. Racket file.

```
#lang planet mmacauley/bf
```
