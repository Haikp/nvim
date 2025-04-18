# My NVim Configs
This repo is from the primeagen, which I'm slowly modifying it to fit my needs. I've had this config for a while now, but now that I've made a decent amount of changes to the remapping, I believe that I should write something to track my changes for myself. I am no expert in nvim nor lua, just trying to make some shortcuts to the development process.

## CMake Adjustments
Something that I'm currently trying to do with CMake is define a structure that I want to follow, and I want to automate and make the whole testing process more dynamic to accomodate my crazy ideas for the "pitchfork" cmake organization. As a tldr, I wanted to be able to compile, make, and run dynamically based on the pwd. Using dispatch, the cwd is defaulted, and such i made some remaps and changes to CMakeLists.txt to try and make things more easier without having to quit vim repeatedly to compile the correct project. 

Future Note: this was a terrible idea, never do this again, going with dynamic CMake honestly feels terrible when there are multiple CMakeLists.txt, and recursively going back to pwd from cwd just will usually find you the wrong CMakeLists.txt unless you are in main, which in that point don't make it dynamic.
