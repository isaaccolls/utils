#!/usr/bin/env bash

echo "Start installing Discord 🚀"
url="https://discord.com/api/download?platform=linux&format=deb"
curl -L -o ./discord.deb $url
echo "Download complete! 🎉"
sudo apt-get install ./discord.deb
if [ $? -eq 0 ]; then
  echo "Discord installed successfully! 🎊"
else
  echo "Discord installation failed. Please check the error messages above. ❌"
fi
rm -f ./discord.deb
echo "Cleaning up... 🧹"
