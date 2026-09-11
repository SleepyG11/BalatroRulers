<img width="176" height="98" alt="image" src="https://github.com/user-attachments/assets/c374e7c0-3c6f-4582-b5fa-db580238f32b" />

Small mod to display rulers for measuring in-game sizes in Balatro.

Requires Lovely and DebugPlus to work.

---

`rulers` command controls the appearance and behaviour of rulers.

```text
rulers [OPTIONS]
```

- Multiple options can be passed in command<br/>
- Each option updates only the corresponding property<br/>
- Properties that are not explicitly specified remain unchanged

For example, this command changes only the rulers length.

```text
rulers -l 200px
```

This command changes the numbers and grid settings while keeping all other properties untouched.

```text
rulers -n off -g on
```

## Options

### Help

Display the built-in command reference:

```text
rulers
rulers -h
rulers -help
```

---

### Visibility

```text
-v BOOLEAN
-visible BOOLEAN
-show
-hide
```

Toggle rulers visibility.

```text
rulers -show
rulers -v on
rulers -v true
rulers -v t
rulers -v yes
rulers -v y
rulers -v 1
```

```text
rulers -hide
rulers -v off
rulers -v false
rulers -v no
rulers -v 0
rulers -v any_input_which_is_not_true
```

---

### Length

```text
-l VALUE
-length VALUE
```

Set the rulers length.

- Set length equal to `10 game units`

```text
rulers -l 10
```

- Set length equal to `200 pixels`

```text
rulers -l 200px
```

- Reset value to default (`3 game units`)

```text
rulers -l default
```

<!-- Image here: Length -->

---

### Line size

```text
-s VALUE
-size VALUE
```

Set the rulers line size.

- Set size equal to `1 pixel`

```text
rulers -s 1
```

- Reset value to default (`2 pixels`)

```text
rulers -s default
```

<!-- Image here: Size -->

---

### Steps

_WIP description_

```text
-st BIG,MEDIUM,SMALL
-steps BIG,MEDIUM,SMALL
```

Set the sizes of the three ruler step levels.

<!-- Image here: Show which step is which -->

- Set values in game units

```text
rulers -st 2,1,0.25
```

- Set values in pixels

```text
rulers -st 50px,25px,5px
```

- Reset values to default (Big: `1 game unit`; Medium: `0.5 game units`; Small: `0.125 game units`)

```
rulers -st default
rulers -st default,default,default
```

- Combined

```text
rulers -st 2,default,10px
```

- Specify only one value, keeping other ones the same

```
rulers -st ,,0.125
```

---

### Rotation

```text
-r ANGLE
-rotate ANGLE
```

Set the clockwise rotation angle.

- Rotate `30 degrees` clockwise

```text
rulers -r 30
rulers -r 30deg
```

- Rotate `1 radian` clockwise

```text
rulers -r 30
```

- Reset value to default (`no rotation`)

```text
rulers -r default
```

<!-- Image here: Rotation -->

---

### Colour

```text
-c HEX
-colour HEX
```

Set rulers colour.
Supplied value is passed to vanilla `HEX` function.

- Set colour to `red`

```text
rulers -c FF0000
rulers -c #FF0000
```

- Reset value to default (`00FFFF`)

```text
rulers -c default
```

<!-- Image here: Colour -->

---

### Directions

```text
-d { v | h | vh }
-dir { v | h | vh }
-directions { v | h | vh }
```

Select which ruler directions should be displayed.<br/>
_Note than it's relative to not rotated rulers: 90 degree rotated vertical will look like horizontal_

| Value | Direction                    |
| ----- | ---------------------------- |
| `v`   | Vertical                     |
| `h`   | Horizontal                   |
| `vh`  | Both vertical and horizontal |

```text
rulers -dir v
rulers -dir h
rulers -dir vh
```

<!-- Image here: Directions -->

---

### Grid

```text
-g BOOLEAN
-grid BOOLEAN
```

Toggle grid display. Disabled by default.

```text
rulers -g off
rulers -g on
```

<!-- Image here: Grid -->

---

### Numbers

```text
-n BOOLEAN
-numbers BOOLEAN
```

Toggle ruler numbers display. Enabled by default.

```text
rulers -n off
rulers -n on
```

<!-- Image here: Numbers -->

---

### Reset the entire configuration

```text
-reset
-default
```

Reset all ruler options to their default values.

```text
rulers -default
```

<!-- Image here: Default look -->

---

## Examples

Display rulers:

```text
rulers -v on
```

Disable numbers and enable the grid:

```text
rulers -n off -g on
```

Set length in game units, rotation in degrees, and colour:

```text
rulers -l 10 -r 30 -c FFFF00
```

Set length in pixels, rotation in radians, and display only the vertical ruler:

```text
rulers -l 200px -r 1.5rad -dir v
```

Reset only the rulers length:

```text
rulers -l default
```

Set all three step levels:

```text
rulers -st 100px,0.5,0.125
```

Reset the big step, keep the medium step unchanged, and set the small step:

```text
rulers -st default,,0.125
```

---

## Quick reference

```text
rulers [OPTIONS]

Options:
    -h, -help
        Show this message

    -show
        Show rulers

    -hide
        Hide rulers

    -v, -visible BOOLEAN
        Toggle rulers visibility

    -l, -length VALUE
        Set rulers length: n - game units, npx - pixels

    -s, -size VALUE
        Set lines size: n - in pixels

    -st, -steps BIG,MEDIUM,SMALL
        Set line steps: n - game units, npx - pixels

    -r, -rotate ANGLE
        Set rotation angle (clockwise):
        n or ndeg - degrees, nrad - radians

    -c, -colour HEX
        Set colour (input passed to HEX function)

    -d, -dir, -directions v | h | vh
        Set directions to display:
        v - vertical, h - horizontal, vh - both

    -g, -grid BOOLEAN
        Toggle grid

    -n, -numbers BOOLEAN
        Toggle numbers display

    -reset, -default
        Reset all options to their default values
```
