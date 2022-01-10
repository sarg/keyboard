#include QMK_KEYBOARD_H

#ifdef ENCODER_ENABLE

bool encoder_update_user(uint8_t index, bool clockwise) {
    // 0 - left encoder
    // 1 - right encoder
    //if (index == 0) { /* First encoder */
        if (clockwise) {
            tap_code(KC_PGDN);
        } else {
            tap_code(KC_PGUP);
        }
    //}


    return true;
}

#endif
