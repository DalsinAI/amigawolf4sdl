# Amiga port intake: Wolf4SDL

- Port Atlas: [g-wolf4sdl](https://www.amicradle.com/ports/#g-wolf4sdl)
- Priority: `P2`
- Atlas decision: `evaluate`
- Upstream source: `https://github.com/mozzwald/wolf4sdl`
- Atlas source pin: `Unverified`
- Imported commit: `5387b99d32fc5bac39c87defcb0abbf1018d8083`
- Rights state: `review`

## Target contract

Primary target: AmigaOS 3.x / AmiCradle AC090 / Motorola 68040 + FPU.

Use the OPEN platform libraries where applicable: OpenGPU, OpenAudio/OpenAHI, OpenInput, OpenSocket and measured OpenMulticore work. Preserve a correct 68040 fallback and do not assume Roadshow.

No build, runtime, playability or release claim is made by this source-intake commit. Upstream submodules are not initialised. Original commercial game data remains external.

## Rights and data boundary

review; Confirm source/data licences before release.

## Build (AmigaOS 3.x, 68040 + FPU, on acsdl12)

    make -f amiga/Makefile.amigaos \
        STOVE=/path/to/openamigagcc-16.2.0-open4-x86_64-linux \
        NDK=/path/to/gfopensdk/OpenNDK/Include_H \
        ACSDL=/path/to/amicradle-guest/gameports/acsdl12

acsdl12 (amicradle-guest `gameports/acsdl12`, built with its own
`Makefile.amigaos`) is SDL 1.2 on ACGame and AHI. This gives
`build/amigaos/wolf3d` for the shareware episode (the `.WL1` files);
`VARIANT=full` builds it for the full game (`.WL6`). Run it from a drawer that
holds the game's data; the data is not in this repository. 320x200 in 256
colours, AGA or RTG (`ENV:ACGame/Display`). Help is Pause.

The game's data is little-endian. Under `WOLF_BIG_ENDIAN` every load swaps what
it reads (the page file's header and sprite headers, the graphics dictionary,
picture sizes, fonts, map headers, audio offsets, the music, the PC speaker
sound headers) and the in-memory sound files are written little-endian.
Sprite columns and the demos were already read a byte at a time.

State (3 November 2026): runs in an AmiCradle lab instance (OpenKick ROM, 68040
+ FPU) on AGA and RTG with the shareware v1.4 data: sign-on, title, menus, a new
game, walking, turning, firing, music and effects reaching AHI, quitting back to
Shell. On RTG the view changes about 25 times a second, with the emulated 68040
nearly always busy. AGA is much slower, most of all in the palette fades. Not
yet run on a real 68040; expect it to be slow there.

