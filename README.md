# CustomMonsterScriptGenerator
This tool helps generate the scripts needed to create a custom monster mod for Cassette Beasts

# Requirements
* Set up the destination mod folder in your project directory (i.e. ```res://mods/Custom Monster/```) to hold the files for this mod.
* Create the configuration files described in [this guide](https://github.com/DeadlyEssence01/CB_example_monster/tree/main).

# Installation
* Download the files from this repository and place them inside the tools folder of your project. They should be located in ```res://tools/MonsterScriptTool/```.

# How to use
* Open the MainMenu.tscn scene in your godot editor then click Play Scene(F6).
* Enter the requested information in the pop up window and press Generate. The tool allows for up to 3 monster forms to be included in the mod at a time (will be updated later to allow for a less restrictive quantity) 

https://github.com/ninaforce13/CustomMonsterScriptGenerator/assets/68625676/2c18e9c1-f57d-4b68-aee3-3f207be7a5bb

* After a few seconds your editor will refresh and you should see new files in your mod folder

  ![image](https://github.com/ninaforce13/CustomMonsterScriptGenerator/assets/68625676/41fc38d4-4b73-49c6-a525-a29a7c9a12dd)

* The ```metadata.tres``` is created for you, but it will still need to be populated with ID, Name, Author, and Modified Files (Only applicable if your monster config file is located in the data folder.) 

  ![image](https://github.com/ninaforce13/CustomMonsterScriptGenerator/assets/68625676/273c1353-2d7b-4a00-b546-cc2df9c883d1)

