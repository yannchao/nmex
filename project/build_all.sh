#!/bin/sh

haxelib run hxcpp Build.xml -Diphoneos
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7
haxelib run hxcpp Build.xml -Diphonesim
haxelib run hxcpp Build.xml -Dandroid
haxelib run hxcpp Build.xml
# haxelib run hxcpp Build.xml -DHXCPP_M64
# haxelib run hxcpp Build.xml -Dwebos
# haxelib run hxcpp Build.xml -Dblackberry
