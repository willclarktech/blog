---
layout: post
title: "Command Line Intro"
description: "Command Line Interface introduction: learn the most common terminal commands you need for beginner web development. Get coding fast on Mac and Linux."
category: coding
tags: [command line, introduction, code fast]
---
{% include JB/setup %}

If using apps on your computer is like talking to a friend from a foreign country via an interpreter, using the command line is like learning their language and talking to them directly. The interpreter might be faster at getting the point across, and probably has a more elegant turn of phrase than you do, but there are many contexts where communication is just easier without the addition of a middleman.

This is a post for anyone who's getting started with web development and wants to know which commands to focus on right away: here are the commands that I find myself using all the time. There are of course many other commands you will need to know as you progress with programming, but knowing these will get you up and running. These instructions are based on using a Mac, but most of it will be directly transferable to Linux. PC users: sorry, I just don't know anything about that (but check out the [command line crash course][learn cli the hard way] at learncodethehardway.org).

I'm assuming you know how to open a Terminal window (or [iTerm2] if you've followed [my recommendation][recommended]) and type in commands. If not, maybe get started with the [command line crash course][learn cli the hard way] at learncodethehardway.org.

## IMPORTANT: Be careful

* Never blindly type a command into the Terminal if it's from a source you don't trust. The command line is a very powerful tool, but that means you have to be careful too. In particular, never type `sudo rm -rf /`. Apparently there are people out there who troll beginners by giving them this command when they ask for help. It will delete everything on your computer. Not just your documents and music etc, but the operating system and EVERYTHING until it's so broken it can't delete any more.

* You can normally confirm that a command will do what you think it will with a quick Google search, and it'll probably lead you to official documentation or [Stack Overflow], where answers with lots of upvotes can be trusted.

* You can also use the `man` command to check what a command does. It's not always the easiest material to read, but it's a good defence against trolls. E.g. try the following and you'll see the manual for the `rm` command.

        $ man rm

## General tips

* Use tab to autocomplete commands and paths or double tab to see available completions.

* When specifying a path, `..` signifies the parent directory (the enclosing folder). So `../folder_name` is a path to a folder at the same level as your current directory and `../..` is a path to the parent directory of the parent directory (i.e. two steps up).

* If you have a directory whose name has a space in it, like "Application Support", you have to escape the space, otherwise Terminal thinks it's reached the end of the path. To escape the space, use a backward slash like this: `cd Library/Application\ Support/Google/`.

## Frequently used commands

### Navigation

* `pwd`: ["Print working directory"][pwd] tells you which folder you're in.
* `ls`: ["List"][ls] tells you the contents of a folder.
* `ls -A`: Includes hidden files.
* `cd`: ["Change directory"][cd] moves you into another folder

### Files and folders

* `touch`: ["Touch"][touch] creates an empty file. (It has many other uses though.)
* `mkdir`: ["Make directory"][mkdir] creates an empty folder.
* `mkdir -p`: Creates folders along the path you specify if they don't exist already. (Without the `-p` option you can't create a folder within a folder that doesn't exist.)
* `mv`: ["Move"][mv] changes the location of a file/folder and/or the name of that file/folder. (Humans tend to think of renaming files and moving them from one folder to another as different actions, but to a computer they're actually kind of the same, so `mv` does both.)
* `cp`: ["Copy"][cp] copies a file/folder to another location.
* `rm`: ["Remove"][rm] deletes a file. (Be careful, it doesn't end up in the trash, it's permanently deleted!)
* `rm -r`: Recursive removal (deletes a folder and all files/folders inside it).
* `rmdir`: ["Remove directory"][rmdir] deletes a folder (but not if it has anything inside it).

### Editing etc

* `open`: Opens a file (obviously).
* `open -a "Sublime Text"`: Opens a file with [Sublime Text]. (Sublime Text is my [recommended text editor][recommended].)
* `less`: ["Less"][less] lets you read a file's contents in the Terminal and then hide them with `q` (unlike `more` which shows you the contents and then leaves them there, which is only really useful for incredibly small files).
* `cat` and pipes: ["Concatenation"][cat] and ["redirection"][pipes] let you easily direct text into, out of, and between files and other places.
* `emacs`: Emacs is probably the most beginner-friendly command line text editor available. Yes, there are more powerful command line text editors available, but they generally come with a steep learning curve, and as a beginner there are very few situations where you can't use a normal text editor like Sublime.

### Info

* `which`: Tells you the location of the executable. E.g. if you have different projects using different installations of Python, `which python` will tell you which one you're using right now.
* `echo`: Prints something to the Terminal. Mostly useful for finding values of environment variables.
* `curl`: There's a lot you can do with this, but if you just give it a URL it will resolve it and give you the response.
* `ifconfig`: Tells you lots of information about your network.

## More

* For beginner tutorials on many of these commands plus a few others I recommend the [command line crash course][learn cli the hard way] at learncodethehardway.org.
* There's also the [command line course][codecademy cli] at Codecademy.


[learn cli the hard way]: http://cli.learncodethehardway.org/book/
[codecademy cli]: https://www.codecademy.com/en/courses/learn-the-command-line
[recommended]: pages/coding/coding-setup.html
[iTerm2]: https://www.iterm2.com/
[Sublime Text]: http://www.sublimetext.com/3
[Stack Overflow]: http://stackoverflow.com/
[pwd]: http://cli.learncodethehardway.org/book/ex2.html
[ls]: http://cli.learncodethehardway.org/book/ex6.html
[cd]: http://cli.learncodethehardway.org/book/ex5.html
[touch]: http://cli.learncodethehardway.org/book/ex9.html
[mkdir]: http://cli.learncodethehardway.org/book/ex4.html
[mv]: http://cli.learncodethehardway.org/book/ex11.html
[cp]: http://cli.learncodethehardway.org/book/ex10.html
[rm]: http://cli.learncodethehardway.org/book/ex14.html
[rmdir]: http://cli.learncodethehardway.org/book/ex7.html
[less]: http://cli.learncodethehardway.org/book/ex12.html
[cat]: http://cli.learncodethehardway.org/book/ex13.html
[pipes]: http://cli.learncodethehardway.org/book/ex15.html
