---
layout: post
title: "Command Line Intro"
description: "Command Line Interface introduction: learn the most common terminal commands you need for beginner web development. Get coding fast on Mac and Linux."
category: coding
tags: [command line, introduction, code fast]
---
{% include JB/setup %}

If using apps on your computer is like talking to a friend from a foreign country via an interpreter, using the command line is like learning their language and talking to them directly. The interpreter might be faster at getting the point across, and probably has a more elegant turn of phrase than you do, but there are many contexts where communication is just easier without the addition of a middleman.

This is a post for anyone who's getting started with web development and wants to know which commands to focus on right away: here are the commands that I find myself using all the time. There are of course many other commands you will need to know as you progress with programming, but knowing these will get you up and running. These instructions are based on using a Mac, but most of it will be directly transferable to Linux. PC users: sorry, I just don't know anything about that (but check out the links at the bottom of the page).

I'm assuming you know how to open a Terminal window (or [iTerm2] if you've followed [my recommendation]) and type in commands. If not, maybe get started with one of the links at the bottom.

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

`pwd`: "Print working directory" - use on its own to show you which directory (folder) you're in.

    $ pwd
    /Users/Will

`ls`: "List directory contents" (but I think of it as taking a "looksie") - use on its own to see what's in the current directory, or use with a path to another directory to see what's in there.

    $ ls
    Applications    Library     projects
    Desktop         Movies      Public
    Documents       Music
    Downloads       Pictures
    $ ls projects/
    archive         current     learning
    $ ls ../
    Guest           Shared      Will

`ls -A`: The `-A` option means that hidden files get listed too.

    $ ls -A
    .DS_Store         .config         Downloads
    .Trash            .emacs.d        Library
    .bash_history     .gitconfig      Movies
    .bash_profile     .virtualenvs    Music
    .bash_sessions    Applications    Pictures
    .bashrc           Desktop         projects
    .cache            Documents       Public
    

`cd`: "Change directory" - use with a path to another directory to change into it, or without a path to change into your home folder.

    $ pwd
    /Users/Will
    $ cd projects/
    $ pwd
    /Users/Will/projects
    $ cd current/
    $ pwd
    /Users/Will/projects/current
    $ cd ../
    $ pwd
    /Users/Will/projects
    $ cd ../../Guest
    $ pwd
    /Users/Guest
    $ cd
    $ pwd
    /Users/Will

### Files and folders

`touch`: use with a filename (with or without a path) to create an empty file with that filename - don't forget the file extension.

    $ ls
    Applications    Library     projects
    Desktop         Movies      Public
    Documents       Music
    Downloads       Pictures
    $ touch xxx_new_file.txt
    $ ls
    Applications    Library     projects
    Desktop         Movies      Public
    Documents       Music       xxx_new_file.txt
    Downloads       Pictures

`mv`: humans tend to think of renaming files and moving them from one folder to another as different actions, but to a computer they're actually kind of the same, so `mv` does both. You specify the file/folder you want to move first and then where you want it to end up.

    $ touch xxx_new_file.txt
    $ ls
    Applications    Library     projects
    Desktop         Movies      Public
    Documents       Music       xxx_new_file.txt
    Downloads       Pictures
    $ mv xxx_new_file.txt 



[my recommendation]: pages/coding/coding-setup.html
[iTerm2]: https://www.iterm2.com/
[Stack Overflow]: http://stackoverflow.com/