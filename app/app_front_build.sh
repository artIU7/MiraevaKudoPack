#!/bin/bash
echo "clean front app build ..."
sudo rm -r Public
mkdir Public
cd frontend 
echo "build front app to buold ..."
npm run build
echo "copy front app build ..."
cd build
cp -r * ./../../Public
cd ..
cd ..
echo "finish ..."
