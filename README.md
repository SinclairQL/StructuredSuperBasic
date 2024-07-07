# Structured Super Basic
Structured SuperBASIC -- SSB -- by Timothy Swenson, is a system for writing S*BASIC programs without using line numbers.

Tim's involvement effectively stopped at version 2.7.2 as the program had "everything and more" that Tim wanted. I (Norman Dunbar) have added a few changes that I wanted for myself, and also, the Spanish translation supplied by @badaman on the Sinclair QL Forum.

Tim has given his blessing for future development to take place via GitHub, so here we are!


## Code Development

SSB is written in S*BASIC and has been used to compile itself. This *must* continue to be the case. It is compiled with the Turbo compiler.

**WARNING** The source files are using the QL's character set. **DO NOT** edit these files on a PC or laptop, in Windows of Linux! You will corrupt things. All development should be done on a QL system. Normally, the process will be:

* Clone the repository `git clone https://github.com/SinclairQL/StructuredSuperBasic.git`
* Copy the *source files* to a QL/Emulator.
* Copy the files to `ram1_` and make your changes.
* Generate the `_bas` files from the `_ssb` files using the *current version* of the SSB "compiler".
* Test.

Repeat as necessary until it seems to be working. We are ready to compile itself!

## Compiling itself!

SSB has to be able to compile itself. IN the development process, we have used the existing current version to create the new version. For the same of example, `ssb272c` is current and `ssb272d` is the nw desired version.

* Compile the sources with `ssb272c` to create `ssb272d`.
* Note the size of the generated `ssb272_bas` file. Preferably, take a copy of the file.
* Compile `ssb272_bas` with Turbo to create `ssb272_exe`.
* Compile the sources again, with the new `ssb272_exe`.
* Compare the generated size of the `_bas` file with the noted version. They should be the same.
   * If not, run a `diff` to find out what the changes are. They could be valid depending on the amendments made for the new version.
   * Fix anything untoward, and start again from a compilation with the `ssb272c` compiler.
* Compile the newly generated `ssb272_bas` with Turbo to create `ssb272_exe`, which is version 2.7.2d compiled with itself.
* Test the new compiler on any other test files that you may have.

When you are happy, proceed to update the repository.

* Save the files from `ram1_` to your `win1_`. It's always good to have a backup copy!
* Copy the *source Files* back to the PC/Laptop where you cloned the repository.
* Execute `git status`; `git add`; `git commit -m "..."`; `git push` as appropriate. Pleas use meaningful messages for `commit` action.
* Tag the new version as described below.

Then, back in the QL environment, 

* Zip up the new executable and the new or existing docs. Create the file as ssbXYZv_zip". XYZ is the version and v is the minor version letter. For example, `ssb272d_zip`.
* Copy to the PC/Laptop as `ssbXYZv.zip` or it won't upload to GitHub.
* On the GitHub page for the repository, create a new release from the newly tagged version just pushed.
* Add the zip file as an additional release file.
* Publish the release.


## Tagging New Versions

When you have updated and tested a change, commit your changes and push them to GitHub. Once done, tag the version with the correct tag. For example, to tag a new release "2.7.3a" you would:

```
git tag -a "2.7.3a"
git push --tags
```

This way, future developers can checkout a specific tagged version:

```
git checkout tags/"2.7.2b"
```

However, it is *not advisable* to make changes in this state. You have two options:

* Look around, read files, but don't make changes.
* Look around, make changes. Commit them. 

If you choose the latter, then you have a further two choices:

* Bin the new commits `git switch -` which takes you back to the latest state of the code.
* Save the commits in a new branch `git switch -c new-branch-name`. 

If you choose the latter yiou still have two mnore choices:

* Leave them in the new branch. *Recommended*.
* Merge into the `main` branch. * Not Recommended*.


## Documentation

Currently, the documentation is written in *Quill* format. This *must* continue so that everyone with a QL can see what's going on and how to use the program. Worry not, you users of PCs and laptops, if you use Norman's *QStripper* application, you will be able to export the Quill document to:

* PDF.
* Libre Office ODF.
* Plain Text.
* ReStructured Text (RST).
* AsciiDoctor (ADOC).
* DocBook XML.
* HTML.

Norman Dunbar  
7 July 2024.
