"""Local packaging checks; does not validate Apple signing or contact Apple."""
import plistlib
import sys
from pathlib import Path

archive = Path(sys.argv[1])
app = archive / 'Products/Applications/Ignacio.app'
info = plistlib.loads((app / 'Info.plist').read_bytes())
assert info.get('CFBundleIdentifier') == 'com.ignaciomustacho.shadowbasketball', 'Unexpected bundle identifier'
assert info.get('CFBundleShortVersionString'), 'Missing marketing version'
assert info.get('CFBundleVersion'), 'Missing build number'
assert info.get('UIDeviceFamily') == [1], 'Expected an iPhone-only archive'
assert info.get('IgnacioLeaderboardID'), 'Leaderboard identifier not packaged'
assert '$(' not in info['IgnacioLeaderboardID'], 'Unresolved leaderboard build setting'
assert info.get('UISupportedInterfaceOrientations') == ['UIInterfaceOrientationPortrait']
assert info.get('CFBundleIcons', {}).get('CFBundlePrimaryIcon', {}).get('CFBundleIconName') == 'AppIcon'
assert (app / 'Assets.car').exists(), 'Missing compiled asset catalog'
assert (app / 'PrivacyInfo.xcprivacy').exists(), 'Missing privacy manifest'
assert (archive / 'dSYMs/Ignacio.app.dSYM').exists(), 'Missing archive symbols'
awards = info.get('IgnacioAchievementIDs', {})
assert set(awards) == {'10', '23', '33', '50', '81', '100'}
assert len(set(awards.values())) == 6
assert all(value and '$(' not in value for value in awards.values())
assert info.get('UILaunchStoryboardName') == 'LaunchScreen'
assert (app / 'LaunchScreen.storyboardc').exists()
print('Packaging verified:', info['CFBundleIdentifier'], info['CFBundleShortVersionString'], '(' + info['CFBundleVersion'] + ')')
print('Leaderboard:', info['IgnacioLeaderboardID'])
print('Signing and App Store Connect validation are separate; this check does not certify upload readiness.')
