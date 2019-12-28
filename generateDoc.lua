local lfs = require("lfs")

print("Creating directories")
lfs.mkdir("build")
lfs.mkdir("build/docs")

local file = io.open("build/docs/index.html", "w")

print("Writing html files")
file:write(
    "<html>",
    "<head>",
    "<title>TPF2 Balancing</title>",
    "</head>",
    "<body>",
    "<p>Generated by Lua</p>",
    "</body>",
    "</html>"
)

file:close()