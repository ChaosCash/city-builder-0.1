components {
  id: "tile"
  component: "/main/game/tiles/tile.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"forest tile\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/tiles.atlas\"\n"
  "}\n"
  ""
}
