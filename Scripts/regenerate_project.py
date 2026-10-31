"""Regenerate resources while preserving the app target's current signing overrides.
Bundle identity stays in Configuration/Release.xcconfig, the owner-approved source.
"""
import json
import subprocess
from pathlib import Path

path = Path('project.yml')
source = path.read_text()
data = json.loads(subprocess.check_output(['plutil', '-convert', 'json', '-o', '-', 'Ignacio.xcodeproj/project.pbxproj']))
objects = data['objects']
target = next(v for v in objects.values() if v.get('isa') == 'PBXNativeTarget' and v.get('name') == 'Ignacio')
block = '      configs:\n'
for identifier in objects[target['buildConfigurationList']]['buildConfigurations']:
    config = objects[identifier]
    block += '        ' + config['name'] + ':\n'
    for key, value in config['buildSettings'].items():
        if key.startswith(('CODE_SIGN', 'PROVISIONING_PROFILE')) or key == 'DEVELOPMENT_TEAM':
            block += '          ' + key + ': ' + json.dumps(value) + '\n'
start = source.index('      configs:', source.index('  Ignacio:'))
end = source.index('  IgnacioTests:', start)
path.write_text(source[:start] + block + source[end:])
subprocess.run(['xcodegen', 'generate'], check=True)
