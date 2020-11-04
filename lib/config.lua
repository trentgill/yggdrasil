config = {}

config["settings"] = {
  ["version_major"] = 1,
  ["version_minor"] = 0,
  ["version_patch"] = 0,
  ["root"] = 0,
  ["scale"] = 47,
  ["octaves"] = 11,
  ["save_path"] =  _path.data .. "yggdrasil/",
  ["default_tracks"] = 8,
  ["default_depth"] = 8,
  ["default_clade"] = "SYNTH",
  ["max_tracks"] = 50
}

config["page_titles"] = {
  "TRACKER",
  "TRACKER + HUD",
  "MIXER",
  "CLADES"
}

return config