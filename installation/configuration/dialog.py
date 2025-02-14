#!/usr/bin/env python3

# Display text-based dialogs

import curses
import textwrap


class Dialog:
    def __init__(self, description=None, values=None, default=None):
        self.description = description
        self.values = values if values and values[0] else [""]
        self.default = default or self.values[0]


    @staticmethod
    def input(description, value=None, default=None):
        dialog = Dialog(description, [value], default)
        result = Dialog._process_text(dialog)

        return [ result, dialog.status ]

    @staticmethod
    def select(description, values, default=None):
        dialog = Dialog(description, values, default)
        result = Dialog._process_select(dialog)

        return [ result, dialog.status ]


    @staticmethod
    def show(description):
        dialog = Dialog(description)
        result = Dialog._process_display(dialog)

        return [ result, dialog.status ]


    def _process_text(self):
        return curses.wrapper(self._text_form)


    def _process_select(self):
        return curses.wrapper(self._select_form)


    def _process_display(self):
        return curses.wrapper(self._display_form)


    def _text_form(self, stdscr):
        self._setup_form(stdscr)

        input_field = self.input_field

        while True:
            self.display_description()
            self._display_field(self.end_description, 2, self.values[input_field], self.last_input_position,
                                self.current_field == input_field, "input")
            self._display_field(self.button_y, self.button_x_cancel, "Cancel",
                                self.cancel_button_field, self.current_field == self.cancel_button_field, "button")
            self._display_field(self.button_y, self.button_x_ok, "Ok",
                                self.okay_button_field, self.current_field == self.okay_button_field, "button")
            self.win.refresh()

            result = self._get_input("input")

            if (self.status == "Done") or (self.status == "Aborted"):
                return result


    def _select_form(self, stdscr):
        self._setup_form(stdscr)

        while True:
            self.display_description()

            last_pos = 5

            for i, value in enumerate(self.values):
                self._display_field(self.end_description, last_pos, value, last_pos,
                                    self.last_selected_field == i, "select")

                last_pos += len(value) + 5

            self._display_field(self.button_y, self.button_x_cancel, "Cancel",
                                self.cancel_button_field, self.current_field == self.cancel_button_field, "button")
            self._display_field(self.button_y, self.button_x_ok, "Ok",
                                self.okay_button_field, self.current_field == self.okay_button_field, "button")
            self.win.refresh()

            result = self._get_input("select")

            if (self.status == "Done") or (self.status == "Aborted"):
                return result


    def _display_form(self, stdscr):
        self._setup_form(stdscr)
        self.current_field = self.okay_button_field

        while True:
            self.display_description()
            self._display_field(self.button_y, self.button_x_cancel, "Cancel",
                                self.cancel_button_field, self.current_field == self.cancel_button_field, "button")
            self._display_field(self.button_y, self.button_x_ok, "Ok",
                                self.okay_button_field, self.current_field == self.okay_button_field, "button")
            self.win.refresh()

            result = self._get_input("show")

            if (self.status == "Done") or (self.status == "Aborted"):
                return result


    def _setup_form(self, stdscr):
        curses.curs_set(0)  # Hide cursor
        stdscr.clear()
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLUE)  # Normal background
        curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_YELLOW)  # Highlighted input
        curses.init_pair(3, curses.COLOR_RED + 8, curses.COLOR_BLUE)  # Normal buttons
        curses.init_pair(4, curses.COLOR_RED + 8, curses.COLOR_YELLOW)  # Highlighted buttons

        self.color_normal = curses.color_pair(1)
        self.color_highlighted = curses.color_pair(2)
        self.color_normal_button = curses.color_pair(3)
        self.color_highlighted_button = curses.color_pair(4)
        self.term_height, self.term_width = stdscr.getmaxyx()
        self.height = min(10, self.term_height - 2)
        self.width = min(50, self.term_width - 2)
        self.start_y = max((self.term_height // 2) - (self.height // 2), 0)
        self.start_x = max((self.term_width // 2) - (self.width // 2), 0)  # ✅ Fixed Incorrect Calculation
        self.win = curses.newwin(self.height, self.width, self.start_y, self.start_x)

        self.win.bkgd(self.color_normal)  # Set background color
        self.win.box()
        self.win.keypad(True)

        self.input_field = 0
        self.current_field = self.input_field
        self.last_selected_field = self.current_field
        self.values[self.input_field] = self.default
        self.last_input_position = len(self.values[self.input_field]) if self.values else 0
        self.cancel_button_field = len(self.values)
        self.okay_button_field = len(self.values) + 1
        self.button_y = self.height - 2
        self.button_x_cancel = self.width - 22
        self.button_x_ok = self.width - 10


    def display_description(self):
        self.win.clear()
        self.win.bkgd(self.color_normal)
        self.win.box()

        desc_lines = textwrap.wrap(self.description, self.width - 4)
        self.end_description = 1

        for i, line in enumerate(desc_lines):
            self.win.addstr(self.end_description, 2, line, self.color_normal)
            self.end_description += 1

        self.end_description += 1


    def _display_field(self, y, x, value, input_pos, selected=False, field_type="input"):
        match field_type:
            case "input":
                if selected:
                    self.win.addstr(y, x, "< " + value[:input_pos] + "_" + value[input_pos:] + " >",
                                    self.color_highlighted)
                else:
                    self.win.addstr(y, x, "[ " + value[:input_pos] + "_" + value[input_pos:] + " ]", self.color_normal)
            case "select":
                if selected:
                    self.win.addstr(y, input_pos, "< " + value.upper() + " >", self.color_highlighted)
                else:
                    self.win.addstr(y, input_pos, "[ " + value + " ]", self.color_normal)
            case "button":
                if selected:
                    self.win.addstr(y, x, "< " + value.upper() + " >", self.color_highlighted_button)
                else:
                    self.win.addstr(y, x, "[ " + value + " ]", self.color_normal_button)


    def _get_input(self, field_type="input"):
        result = None
        self.status = "Continue"
        key = self.win.getch()

        if key == 9:  # Tab
            if self.current_field < self.okay_button_field:
                if self.current_field < self.cancel_button_field:
                    self.current_field += 1
                    self.last_selected_field = self.current_field
                elif self.current_field < self.okay_button_field:
                    self.current_field += 1
                elif field_type == "input":
                    self.current_field = self.input_field
                elif field_type == "select":
                    self.current_field = 0
                    self.last_selected_field = self.current_field
            elif field_type == "show":
                self.current_field = self.cancel_button_field
            elif field_type == "input":
                self.current_field = self.input_field
            elif field_type == "select":
                self.current_field = 0
                self.last_selected_field = self.current_field
        elif key == curses.KEY_DOWN:  # Down Arrow (Cycle Input -> Cancel -> OK)
            if (self.current_field < self.cancel_button_field) and (field_type != "show"):
                self.current_field = self.cancel_button_field
        elif key == curses.KEY_UP:
            if (self.current_field >= self.cancel_button_field) and (field_type != "show"):
                self.current_field = self.input_field
                self.last_selected_field = self.input_field
        elif key == curses.KEY_LEFT:  # Move cursor left in input
            if (field_type == "input") and (self.current_field == self.input_field):
                self.last_input_position = max(0, self.last_input_position - 1)
            else:
                if (self.current_field < self.cancel_button_field) and (self.current_field > 0):
                    self.current_field -= 1
                    self.last_selected_field = self.current_field
                elif self.current_field == self.okay_button_field:
                    self.current_field = self.cancel_button_field
        elif key == curses.KEY_RIGHT:  # Move cursor right in input
            if (field_type == "input") and (self.current_field == self.input_field):
                self.last_input_position = min(len(self.values[self.input_field]),
                                               self.last_input_position + 1)
            else:
                if self.current_field < (self.cancel_button_field - 1):
                    self.current_field += 1
                    self.last_selected_field = self.current_field
                elif self.current_field == self.cancel_button_field:
                    self.current_field = self.okay_button_field
        elif key == 10:  # Enter Key; return input
            self.status = "Done"

            if self.current_field == self.cancel_button_field:
                self.status = "Aborted"
            elif field_type == "input":
                result = self.values[self.input_field]
            elif field_type == "select":
                result = self.values[self.last_selected_field]
        elif key == 27:  # Escape Key
            self.status = "Aborted"
        elif (32 <= key <= 126) and (self.current_field == self.input_field) and (
                field_type == "input"):  # Typable characters in input
            value = self.values[self.input_field]
            input_pos = self.last_input_position
            value = value[:input_pos] + chr(key) + value[input_pos:]
            input_pos += 1
            self.values[self.input_field] = value
            self.last_input_position = input_pos
        elif (key in {curses.KEY_BACKSPACE, 127}) and (self.current_field == self.input_field) and (
                field_type == "input"):  # Backspace handling
            value = self.values[self.input_field]
            input_pos = self.last_input_position

            if input_pos > 0:
                value = value[:input_pos - 1] + value[input_pos:]

            input_pos -= 1
            self.values[self.input_field] = value
            self.last_input_position = input_pos

        return result
