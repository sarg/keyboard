bool is_thumb_key(keyrecord_t *record) {
    return record->event.key.row % 3 == 0;
}

bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {
    return is_thumb_key(record);
}

bool get_hold_on_other_key_press(uint16_t keycode, keyrecord_t *record) {
    return is_thumb_key(record);
}
