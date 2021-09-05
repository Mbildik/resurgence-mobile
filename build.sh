#!/bin/bash

# todo add version parameter

flutter clean
flutter build appbundle
nautilus ./build/app/outputs/bundle/release/
