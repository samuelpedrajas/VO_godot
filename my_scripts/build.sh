#!/bin/bash

# config
GODOT_REPO=/Users/vegames/Projects/vegan_odyssey/VO_godot/
VO_REPO=/Users/vegames/Projects/vegan_odyssey/Vegan-Odyssey
GODOT_OUTPUT=/Users/vegames/Projects/vegan_odyssey/output/vegan_odyssey.a


# custom cd function
mycd() {
  cd "$1"
}

is_updated() {
	mycd $1
	printf "Fetching changes from remote branch $2...\n"
	eval "git fetch"
	eval "git checkout $2"

	res="$(git log $2..origin/$2)"
	printf "NEW COMMITS:\n$res\n"
	if [ ! -z "$res" ]
	then
	    return 1
	else
		return 0
	fi
}

build_templates() {
	#printf "Building debug\n"
	#eval "scons p=iphone target=release_debug tools=no arch=arm bits=32 -j4"
	#eval "scons p=iphone target=release_debug tools=no arch=arm64 bits=64 -j4"
	#eval "lipo -create bin/libgodot.iphone.opt.debug.arm.a bin/libgodot.iphone.opt.debug.arm64.a -output bin/godot_ios_xcode/libgodot.iphone.debug.fat.a"

	# if simulator is true
	if [ "$1" = true ]
	then
		printf "Building simulator\n"
		eval "scons p=iphone target=debug tools=no arch=x86 bits=32 -j4"
		eval "scons p=iphone target=debug tools=no arch=x86_64 bits=64 -j4"
		eval "lipo -create bin/libgodot.iphone.debug.x86.a bin/libgodot.iphone.debug.x86_64.a -output bin/godot_ios_xcode/libgodot.iphone.debug.simulator.fat.a"
		printf "Copying compiled templates..."
		eval "cp bin/godot_ios_xcode/libgodot.iphone.debug.simulator.fat.a $GODOT_OUTPUT"
	else
		printf "Building release\n"
		eval "scons p=iphone target=release tools=no arch=arm bits=32 -j4"
		eval "scons p=iphone target=release tools=no arch=arm64 bits=64 -j4"
		eval "lipo -create bin/libgodot.iphone.opt.arm.a bin/libgodot.iphone.opt.arm64.a -output bin/godot_ios_xcode/libgodot.iphone.release.fat.a"
		printf "Copying compiled templates..."
		eval "cp bin/godot_ios_xcode/libgodot.iphone.release.fat.a $GODOT_OUTPUT"
	fi
}

# parse parameter
simulation=false
game_branch=""
godot_branch=""
game_force=false
godot_force=false
while [ $# -gt 0 ]; do
  case "$1" in
    --simulation=*)
      simulation="${1#*=}"
      ;;
    --game_branch=*)
      game_branch="${1#*=}"
      ;;
    --game_force=*)
      game_force="${1#*=}"
      ;;
    --godot_branch=*)
      godot_branch="${1#*=}"
      ;;
    --godot_force=*)
      godot_force="${1#*=}"
      ;;
    *)
      printf "* Error: Invalid argument.*\n"
      exit 1
  esac
  shift
done

something_changed=false

# update game
if [ ! -z "$game_branch" ]
then 
	is_updated "$VO_REPO" "$game_branch"
	return_val="$?"
	if [ "$return_val" -eq 1 ] || [ $game_force = true ]
	then
		printf "Pulling changes to game...\n"
		eval "git pull origin $game_branch"

		something_changed=true
		printf "Done.\n"
	else
		printf "No game changes to pull in branch $game_branch.\n"
	fi
else
	printf "Not updating game.\n"
fi

# update game
if [ ! -z "$godot_branch" ]
then 
	is_updated "$GODOT_REPO" "$godot_branch"
	return_val="$?"
	if [ "$return_val" -eq 1 ] || [ $godot_force = true ]
	then
		printf "Pulling changes to godot...\n"
		eval "git pull origin $godot_branch"

		printf "Removing godot_ios_xcode content..."
		eval "rm -rf bin/godot_ios_xcode/*"

		printf "Compiling templates..."
		build_templates "$simulation"

		something_changed=true
		printf "Done.\n"
	else
		printf "No godot changes to pull in branch $godot_branch.\n"
	fi
else
	printf "Not updating godot.\n"
fi

if $something_changed
then
	eval "afplay /Users/vegames/Projects/vegan_odyssey/resources/finished.mp3"
fi
