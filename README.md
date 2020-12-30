# MakeColors

Converts a simple list of color definitions to asset catalogs for Xcode, resource XML for Android or an HTML preview.

## Input format

Each line in your input contains one color definition. That is a name followed by the actual color. We support RGB colors in a few formats similar to CSS:

```
Color/Color1 #fff
Color/Color2 #abcdeff0
Color/Color3 rgb(12, 13, 53)
Color/Color4 rgba(250, 250, 250, 128)
```

Colors can also reference other colors by prefixing them with an `@` sign:

```
ColorAlias @Color/Color1
```

## Output format

### Xcode Asset Catalogs (`--ios`)

The optional prefix followed by a `/` is added in front of the color name. Then for each part separate by / a new folder that provides namespace is inserted in the asset catalogs. Spaces are inserted between CamelCase words. Color references are inserted as copies of the original color.

### Android resource XML (`--android`)

The optional prefix, followed by a underscore is added in front of the name. Names are converted from CamelCase to snake_case and / is replaced by underscores as well. Color references the generated color resource also references the original color.

### HTML preview (`--html`)

Generates a simple HTML table with the color names, values and a sample.

## Future work

- Support other color formats (HSV, ...)
- Calculate derived colors (blend, change hue/saturation/brightness/alpha)
- Support for dark/light mode
- Improved error reporting in the parser
