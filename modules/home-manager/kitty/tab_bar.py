from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import DrawData, ExtraData, TabBarData, draw_title, as_rgb
from kitty.utils import color_as_int


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    opts = get_options()

    BG_TRANSPARENT = 0
    BG_TAB = as_rgb(color_as_int(opts.color4))

    screen.cursor.bg = BG_TRANSPARENT
    screen.cursor.fg = BG_TAB
    if index == 1:
        screen.draw(" ")
    screen.draw("")
    screen.cursor.bg = BG_TAB

    draw_title(draw_data, screen, tab, index)

    screen.cursor.bg = BG_TRANSPARENT
    screen.cursor.fg = BG_TAB
    screen.draw("")
    if not is_last:
        screen.draw(" ")
    screen.cursor.bg = BG_TAB

    return screen.cursor.x
