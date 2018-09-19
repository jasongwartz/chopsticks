fs = require('fs')

filedata =  JSON.parse(fs.readFileSync("./sampledata.json"))
filedata[i.replace(".wav", "")] = {"file": "static/samples/" + i, "category": i.split("_")[0]} for i in fs.readdirSync("./samples") when i.indexOf(".wav") >= 0 && ! filedata[i.replace(".wav", "")]

fs.writeFile("./sampledatatest.json", JSON.stringify(filedata), (err) ->
  if err
    return console.log(err)
  console.log("The file was saved!")
)
