#include <stdio.h> // printf
#include <wchar.h> // wchar_t

#include <hidapi.h>
#include "keymap.h"

#define MAX_STR 255

int main(int argc, char* argv[])
{
    int res;
    wchar_t wstr[MAX_STR];
    hid_device *handle;
    int i;

    // Initialize the hidapi library
    res = hid_init();

    // Declare variables for enumeration and specific device identification
    struct hid_device_info *devs, *cur_dev;

    handle = NULL; // Initialize handle to NULL
    devs = hid_enumerate(0xfeed, 0x0);

    if (!devs) {
        hid_exit();
        return 1;
    }

    cur_dev = devs;
    while (cur_dev) {
        if (cur_dev->usage_page == 0xff60 && cur_dev->usage == 0x61) {
            // Attempt to open the device using its path
            handle = hid_open_path(cur_dev->path);
            if (handle) {
                break;
            }
        }
        cur_dev = cur_dev->next;
    }

    // Free the enumeration list
    hid_free_enumeration(devs);

    // Check if a device was successfully opened
    if (!handle) {
        printf("Unable to open device\n");
        hid_exit();
        return 1;
    }

    // Read the Manufacturer String
    res = hid_get_manufacturer_string(handle, wstr, MAX_STR);
    printf("Manufacturer String: %ls\n", wstr);

    // Read the Product String
    res = hid_get_product_string(handle, wstr, MAX_STR);
    printf("Product String: %ls\n", wstr);

    for (int i=0; i<sizeof(keys)/sizeof(KEY); i++) {
        const KEY key = keys[i];
        unsigned char buf[7] = {
            0x0, 0x05, key.layer, key.row, key.col, key.keycode >> 8, key.keycode & 0xFF
        };

        for (size_t j = 0; j < sizeof(buf); j++) {
            printf("%02X ", buf[j]);
        }

        res = hid_write(handle, buf, sizeof(buf));
        hid_read(handle, buf, sizeof(buf)-1);

        printf(" -> ");
        for (size_t j = 0; j < sizeof(buf)-1; j++) {
            printf("%02X ", buf[j]);
        }
        printf("\n");
    }

    for (int i=0; i<sizeof(encoders)/sizeof(ENCODER); i++) {
        const ENCODER enc = encoders[i];
        unsigned char buf[7] = {
            0x0, 0x15, enc.layer, enc.idx, enc.clockwise, enc.keycode >> 8, enc.keycode & 0xFF
        };

        for (size_t j = 0; j < sizeof(buf); j++) {
            printf("%02X ", buf[j]);
        }

        res = hid_write(handle, buf, sizeof(buf));
        hid_read(handle, buf, sizeof(buf)-1);

        printf(" -> ");
        for (size_t j = 0; j < sizeof(buf)-1; j++) {
            printf("%02X ", buf[j]);
        }
        printf("\n");
    }

    // Close the device
    hid_close(handle);

    // Finalize the hidapi library
    res = hid_exit();

    return 0;
}
