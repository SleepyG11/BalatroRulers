<img width="176" height="98" alt="image" src="https://github.com/user-attachments/assets/c374e7c0-3c6f-4582-b5fa-db580238f32b" />

Mod which adds rulers for measuring in-game sizes and distances in Balatro.

Requires [Lovely](https://github.com/ethangreen-dev/lovely-injector) and [DebugPlus](https://github.com/WilsontheWolf/DebugPlus) to work.

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

Toggle rulers visibility.

```text
-v BOOLEAN
-visible BOOLEAN
-show
-hide
```

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

<img width="365" height="202" alt="Default" src="https://github.com/user-attachments/assets/17f4b457-2fb9-4a54-927d-82c2e5e06f50" />

---

### Length

Set the rulers length.

```text
-l VALUE
-length VALUE
```

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

<img width="458" height="196" alt="Length" src="https://github.com/user-attachments/assets/f17c07ec-e2cc-480c-8640-71b187636e2e" />

---

### Line size

Set the rulers line size.

```text
-s VALUE
-size VALUE
```

- Set size equal to `1 pixel`

```text
rulers -s 1
```

- Reset value to default (`2 pixels`)

```text
rulers -s default
```

<img width="464" height="222" alt="Size" src="https://github.com/user-attachments/assets/a239b878-3aa8-41d5-bf9e-05eca411f133" />

---

### Steps

Set the sizes of the three ruler step levels.

```text
-st BIG,MEDIUM,SMALL
-steps BIG,MEDIUM,SMALL
```

<img width="386" height="190" alt="Steps - explanation" src="https://github.com/user-attachments/assets/c77f77bb-b34c-4d29-91f8-976ec4f103f8" />
<br/>

- Set values in game units

```text
rulers -st 2,1,0.25
```

- Set values in pixels

```text
rulers -st 50px,25px,5px
```

- Reset values to default (Big: `1 game unit`; Medium: `0.5 game units`; Small: `0.1 game units`)

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

<img width="412" height="172" alt="Steps - pixels" src="https://github.com/user-attachments/assets/09c8a399-c729-4141-a24c-2ada62798fb6" />

---

### Rotation

Set the clockwise rotation angle.

```text
-r ANGLE
-rotate ANGLE
```

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

<img width="613" height="225" alt="Rotation" src="https://github.com/user-attachments/assets/bf1fc82b-a086-4a79-8bbf-2692e61c7b17" />

---

### Colour

Set rulers colour.
Supplied value is passed to vanilla `HEX` function.

```text
-c HEX
-colour HEX
```

- Set colour to `red`

```text
rulers -c FF0000
rulers -c #FF0000
```

- Reset value to default (`00FFFF`)

```text
rulers -c default
```

<img width="358" height="136" alt="Colour" src="https://github.com/user-attachments/assets/e1dd7575-0b25-4ffa-90ff-e2fde9400b0f" />

---

### Directions

Select which ruler directions should be displayed.<br/>
_Note than it's relative to not rotated rulers: 90 degree rotated vertical will look like horizontal_

| Value | Direction                    |
| ----- | ---------------------------- |
| `v`   | Vertical                     |
| `h`   | Horizontal                   |
| `vh`  | Both vertical and horizontal |

```text
-d { v | h | vh }
-dir { v | h | vh }
-directions { v | h | vh }
```

```text
rulers -dir v
rulers -dir h
rulers -dir vh
```

<img width="368" height="134" alt="Directions" src="https://github.com/user-attachments/assets/f3fbf2d4-2839-4efc-884c-199d82d6b8dc" />

---

### Grid

Toggle grid display. Disabled by default.

```text
-g BOOLEAN
-grid BOOLEAN
```

```text
rulers -g off
rulers -g on
```

<img width="349" height="205" alt="Grid" src="https://github.com/user-attachments/assets/e952aa04-f4b9-4428-aebd-ed870f595ab9" />

---

### Numbers

Toggle ruler numbers display. Enabled by default.

```text
-n BOOLEAN
-numbers BOOLEAN
```

```text
rulers -n off
rulers -n on
```

<img width="248" height="152" alt="Numbers" src="https://github.com/user-attachments/assets/2fc2ef45-0a52-4380-9f76-adcca1a9f939" />

---

## Pin

`rulers -pin` to enter pin mode. Then, [Left Mouse] to place a persistent rulers on screen.<br/>[Right Mouse] or repeat command to cancel.</br><br/>
`rulers -unpin` to unpin pinned rulers.

---

### Reset the entire configuration

Reset all options to their default values.

```text
-reset
-default
```

```text
rulers -default
```

<!-- Image here: Default look -->

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

    -pin
        Enable pin mode: [Left Mouse] to place persistent rulers on screen
        [Right Mouse] or repeat command to cancel

    -unpin
        Unpin pinned rulers
```
