Docker Container that updates your GOG Downloads.
Based on https://github.com/Kalanyr/gogrepoc

Usage: 
use docker-compose.yaml to create a working container. When you start the container it will log in to GOG, update the known games and after that download all of them in the folder provided.

Known issue: The manifest will always be freshly generated once the container resets because it is inside the container.

For Information about the possible configuration, check https://github.com/Kalanyr/gogrepoc