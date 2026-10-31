"""Read-only image analysis; writes crop/foot-anchor metadata, never changes PNG pixels.
Generated atlases do not guarantee exact equal-cell registration. Recover each
connected opaque figure so runtime cropping does not cut shoes or raised hands.
Requires the local tooling environment's Pillow, numpy and OpenCV, not the app.
"""
import json
from pathlib import Path
import cv2
import numpy as np
from PIL import Image

root = Path(__file__).resolve().parents[1] / 'Sources' / 'Art'
result = []
for move in ['dribble', 'between', 'behind', 'shoot', 'flex', 'shrug', 'bench', 'clap', 'bow', 'triumph']:
    name = 'ignacio-dribble-side-12' if move == 'dribble' else 'ignacio-' + move + '-12'
    rgba = np.asarray(Image.open(root / (name + '.png')).convert('RGBA'))
    mask = (rgba[:, :, 3] >= 64).astype(np.uint8)
    count, labels, stats, centers = cv2.connectedComponentsWithStats(mask, 8)
    candidates = sorted(range(1, count), key=lambda i: stats[i, cv2.CC_STAT_AREA], reverse=True)[:12]
    assert len(candidates) == 12 and min(stats[i, cv2.CC_STAT_AREA] for i in candidates) > 1000
    candidates.sort(key=lambda i: centers[i][1])
    ordered = []
    for row in range(4):
        ordered.extend(sorted(candidates[row * 3:row * 3 + 3], key=lambda i: centers[i][0]))
    # Reviewed side-dribble poses: high palm -> downward press -> recovery.
    # Reorder the drawn in-betweens to avoid a second dip during recovery.
    if move == 'dribble':
        ordered = [ordered[index] for index in [1, 2, 8, 9, 0, 7, 4, 5, 6, 3, 10, 11]]
    frames = []
    for i in ordered:
        x, y, w, h, area = map(int, stats[i])
        feet = np.where(labels[y + int(h * .85):y + h, x:x + w] == i)[1]
        anchor_x = x + (int(feet.min()) + int(feet.max())) / 2
        x0, y0 = max(0, x - 2), max(0, y - 2)
        x1, y1 = min(rgba.shape[1], x + w + 2), min(rgba.shape[0], y + h + 2)
        crop_labels = labels[y0:y1, x0:x1]
        neighboring = ((crop_labels != 0) & (crop_labels != i) & (stats[crop_labels, cv2.CC_STAT_AREA] > 1000)).astype(np.uint8)
        fragments, _, fragment_stats, _ = cv2.connectedComponentsWithStats(neighboring, 8)
        exclusions = []
        for fragment in range(1, fragments):
            ex, ey, ew, eh, _ = map(int, fragment_stats[fragment])
            assert not np.any(crop_labels[ey:ey + eh, ex:ex + ew] == i), 'Exclusion would clip this character'
            exclusions.append([ex, ey, ew, eh])
        frames.append({'rect': [x0, y0, x1 - x0, y1 - y0], 'anchor': [anchor_x - x0, y + h - y0], 'exclusions': exclusions})
    result.append({'asset': name, 'neutralHeight': int(stats[ordered[0], cv2.CC_STAT_HEIGHT]), 'frames': frames})
    print(move, len(frames), 'frames', 'neutral height', result[-1]['neutralHeight'])
(root / 'SpriteLayout.json').write_text(json.dumps(result, indent=2) + '\n')
