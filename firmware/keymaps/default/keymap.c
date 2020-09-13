/* Copyright 2020 Sergey Trofimov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include QMK_KEYBOARD_H

// Defines names for use in layer keycodes and the keymap
enum layer_names {
    _BASE, _DIGITS
};

// Defines the keycodes used by our macros in process_record_user
enum custom_keycodes {
    QMKBEST = SAFE_RANGE,
    QMKURL
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
/*
 * QWERTY
 * ,-----------------------------------------.                    ,-----------------------------------------.
 * | ESC  |   Q  |   W  |   E  |   R  |   T  |                    |   Y  |   U  |   I  |   O  |   P  | Bspc |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | Tab  |   A  |   S  |   D  |   F  |   G  |-------.    ,-------|   H  |   J  |   K  |   L  |   ;  |  '   |
 * |------+------+------+------+------+------|       |    |       |------+------+------+------+------+------|
 * |LShift|   Z  |   X  |   C  |   V  |   B  |-------|    |-------|   N  |   M  |   ,  |   .  |   /  |RShift|
 * `-----------------------------------------/       /     \      \-----------------------------------------'
 *                   | LAlt | LWIN |LCTRL | /Enter  /       \Space \  |RCTRL | RWIN | RAlt |
 *                   |      |      |      |/       /         \      \ |      |      |      |
 *                   `---------------------------'           '------''--------------------'
 */
    [_BASE] = LAYOUT( \
        KC_ESC,  KC_Q,    KC_W,    KC_E,     KC_R,   KC_T,              KC_Y,    KC_U,    KC_I,    KC_O,   KC_P,    KC_BSPC, \
        KC_LSFT, LGUI_T(KC_A),    LALT_T(KC_S),    LCTL_T(KC_D),   LSFT_T(KC_F),   KC_G,              KC_H,    LSFT_T(KC_J),    LCTL_T(KC_K),    LALT_T(KC_L),   LGUI_T(KC_SCLN), KC_QUOT, \
        KC_TAB,  KC_Z,    KC_X,    KC_C,     KC_V,   KC_B,              KC_N,    KC_M,    KC_COMM, KC_DOT, KC_SLSH, KC_RSFT, \
        KC_ENT,  KC_LGUI, MO(1),   KC_LCTRL, KC_ENT,                    KC_SPC,  KC_RALT, KC_RGUI, KC_RALT, KC_ENT  \
    ),

    [_DIGITS] = LAYOUT( \
        KC_ESC,  KC_NO,    KC_MINUS,    KC_1,     KC_2,   KC_3,              KC_Y,    KC_U,    KC_I,    KC_O,   KC_P,    KC_BSPC, \
        KC_LSFT, KC_NO,    KC_0,    KC_4,     KC_5,   KC_6,              KC_H,    KC_J,    KC_K,    KC_L,   KC_SCLN, KC_QUOT, \
        KC_TAB,  KC_NO,    KC_NO,    KC_7,     KC_8,   KC_9,              KC_N,    KC_M,    KC_COMM, KC_DOT, KC_SLSH, KC_RSFT, \
        KC_ENT,  KC_LGUI, KC_TRNS,   KC_LCTRL, KC_SPC,                    KC_ENT,  KC_RALT, KC_RGUI, KC_RALT, KC_ENT  \
    ),
};

/*
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case QMKBEST:
            if (record->event.pressed) {
                // when keycode QMKBEST is pressed
                SEND_STRING("QMK is the best thing ever!");
            } else {
                // when keycode QMKBEST is released
            }
            break;
        case QMKURL:
            if (record->event.pressed) {
                // when keycode QMKURL is pressed
                SEND_STRING("https://qmk.fm/\n");
            } else {
                // when keycode QMKURL is released
            }
            break;
    }
    return true;
}
*/

/*
void matrix_init_user(void) {

}

void matrix_scan_user(void) {

}

bool led_update_user(led_t led_state) {
    return true;
}
*/

void encoder_update_user(uint8_t index, bool clockwise) {
    // 0 - left encoder
    // 1 - right encoder
    //if (index == 0) { /* First encoder */
        if (clockwise) {
            tap_code(KC_PGDN);
        } else {
            tap_code(KC_PGUP);
        }
    //}
}
