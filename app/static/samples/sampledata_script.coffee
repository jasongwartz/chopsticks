fs = require('fs')

filedata = {}
filedata[i.replace(".wav", "")] = "static/samples/" + i for i in fs.readdirSync(".") when i.indexOf(".wav") >= 0

console.log(JSON.stringify(filedata))


fs.writeFile("./sampledatatest.json", JSON.stringify(filedata), (err) ->
  if err
    return console.log(err)
  console.log("The file was saved!")
)