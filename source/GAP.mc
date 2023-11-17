import Toybox.Lang;
import Toybox.System;

// https://medium.com/strava-engineering/an-improved-gap-model-8b07ae8886c3
const GRADE_ADJUSTMENT as Array<Array<Numeric>> = [
    [-0.3, 1.5], [-0.28, 1.4], [-0.24, 1.2], [-0.2, 1.1], [-0.18, 1], [-0.16, 0.9], [-0.1, 0.85], [-0.04, 0.9],
    [0, 1], [0.04, 1.1], [0.06, 1.2], [0.08, 1.3], [0.1, 1.5], [0.12, 1.6], [0.14, 1.8], [0.17, 2], [0.2, 2.3],
    [0.24, 2.6], [0.28, 3], [0.32, 3.4]
];


function adjustPaceForGrade(pace, grade) {
    if (grade <= GRADE_ADJUSTMENT[0][0]) {
        var slope = (GRADE_ADJUSTMENT[1][1] - GRADE_ADJUSTMENT[0][1]) / (GRADE_ADJUSTMENT[1][0] - GRADE_ADJUSTMENT[0][0]);
        var adjustment = GRADE_ADJUSTMENT[0][1] + slope * (grade - GRADE_ADJUSTMENT[0][0]);
        return pace / adjustment;
    }

    var size = GRADE_ADJUSTMENT.size();
    for (var i = 1; i < size; i++) {
        if (grade <= GRADE_ADJUSTMENT[i][0]) {
            var prev = GRADE_ADJUSTMENT[i - 1];
            var next = GRADE_ADJUSTMENT[i];

            var slope = (next[1] - prev[1]) / (next[0] - prev[0]);
            var adjustment = prev[1] + slope * (grade - prev[0]);

            return pace / adjustment;
        }
    }

    var slope = (GRADE_ADJUSTMENT[size - 1][1] - GRADE_ADJUSTMENT[size - 2][1]) / (GRADE_ADJUSTMENT[size - 1][0] - GRADE_ADJUSTMENT[size - 2][0]);
    var adjustment = GRADE_ADJUSTMENT[size - 1][1] + slope * (grade - GRADE_ADJUSTMENT[size - 1][0]);

    return pace / adjustment;
}