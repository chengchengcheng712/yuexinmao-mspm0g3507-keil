/*
 * Copyright (c) 2021, Texas Instruments Incorporated
 * All rights reserved.
 */
#include "board.h"
#include "oled.h"
#include "salary_cat.h"

int main(void)
{
    u8 frame_idx = 0;
    u8 prev_idx = 0;
    u8 first_frame = 1;

    board_init();
    OLED_Init();
    OLED_Clear();

    while (1)
    {
        const u8 *cur = salary_cat_frames[frame_idx];

        if (first_frame)
        {
            OLED_LoadFramePage(cur);
            OLED_Refresh();
            first_frame = 0;
        }
        else
        {
            OLED_RefreshDiff(salary_cat_frames[prev_idx], cur);
        }

        prev_idx = frame_idx;
        frame_idx++;
        if (frame_idx >= SALARY_CAT_FRAME_COUNT)
        {
            frame_idx = 0;
        }

        delay_ms(SALARY_CAT_FRAME_DELAY_MS);
    }
}
