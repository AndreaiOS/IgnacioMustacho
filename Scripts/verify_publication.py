"""Check publication assets against the app configuration; never contacts Apple."""
import json
import re
import struct
from html.parser import HTMLParser
from pathlib import Path

root = Path(__file__).resolve().parents[1]
metadata = json.loads((root / 'AppStore/Metadata-en.json').read_text())
for key, limit in [('name', 30), ('subtitle', 30), ('promotionalText', 170), ('description', 4000)]:
    assert 0 < len(metadata[key]) <= limit, key
assert len(metadata['keywords'].encode('utf-8')) <= 100
assert metadata['price'] == 'Free'
assert metadata['copyrightOwner'] and metadata['reviewContact']['email']
config = dict(re.findall(r'^([A-Z0-9_]+)\s*=\s*(.+)$', (root / 'Configuration/Release.xcconfig').read_text(), re.M))
assert metadata['bundleIdentifier'] == config['PRODUCT_BUNDLE_IDENTIFIER']
leaderboard = json.loads((root / 'AppStore/GameCenter/Leaderboard-en.json').read_text())
assert leaderboard['id'] == config['IGNACIO_LEADERBOARD_ID']
assert leaderboard['type'] == 'Classic' and leaderboard['sortOrder'] == 'High to Low'
awards = json.loads((root / 'AppStore/GameCenter/Achievements-en.json').read_text())['achievements']
assert len(awards) == len({a['id'] for a in awards}) == 6
assert {a['inGameThreshold'] for a in awards} == {10, 23, 33, 50, 81, 100}
assert sum(a['gameCenterPointValue'] for a in awards) <= 1000

def png(path, size):
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    w, h, bits, color, *_ = struct.unpack('>IIBBBBB', data[16:29])
    assert (w, h) == size and bits == 8 and color == 2, (path, w, h, color)

for award in awards:
    assert award['id'] == config[f"IGNACIO_ACHIEVEMENT_{award['inGameThreshold']}"]
    assert 0 < award['gameCenterPointValue'] <= 100
    png(root / 'AppStore/GameCenter' / award['image'], (1024, 1024))
shots = list((root / 'AppStore/Screenshots').glob('*.png'))
assert len(shots) == 4
for shot in shots:
    png(shot, (1320, 2868))
png(root / 'AppStore/Icons/AppIcon-1024.png', (1024, 1024))

class LocalLinks(HTMLParser):
    def handle_starttag(self, tag, attrs):
        assert tag not in {'script', 'iframe'}, 'Unexpected external content/tracking surface'
        for key, value in attrs:
            if key in {'href', 'src'} and not value.startswith(('https://', 'mailto:', '#')):
                assert (root / 'docs' / value).is_file(), value

for filename in ['index.html', 'support.html', 'privacy.html']:
    body = (root / 'docs' / filename).read_text()
    assert metadata['reviewContact']['email'] in body
    assert not re.search(r'TODO|PLACEHOLDER|\[INSERT', body)
    LocalLinks().feed(body)
assert metadata['supportURL'].endswith('/support.html')
assert metadata['privacyPolicyURL'].endswith('/privacy.html')
print('Verified: metadata limits, bundle/GC identifiers, 6 awards, 4 screenshots, icon, public contacts and local website links.')
print('Still external: Pages activation/public HTTP checks, owner declarations, Apple records, Game Center online tests and distribution validation.')
